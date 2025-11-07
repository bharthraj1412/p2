const admin = require('firebase-admin');
const functions = require('firebase-functions');
const crypto = require('crypto');

const db = admin.firestore();

// Get config values
const getConfig = () => {
  const config = functions.config();
  return {
    keyId: config.razorpay?.key_id,
    keySecret: config.razorpay?.key_secret,
  };
};

function verifyRazorpaySignature(orderId, paymentId, signature) {
  try {
    const { keySecret } = getConfig();

    if (!keySecret) {
      functions.logger.error('Razorpay key secret not configured');
      return false;
    }

    const expectedSignature = crypto
      .createHmac('sha256', keySecret)
      .update(`${orderId}|${paymentId}`)
      .digest('hex');

    const isValid = expectedSignature === signature;

    if (!isValid) {
      functions.logger.warn('Razorpay signature verification failed', {
        orderId,
        paymentId,
      });
    }

    return isValid;
  } catch (error) {
    functions.logger.error('Signature verification error', {
      error: error.message,
      stack: error.stack,
    });
    return false;
  }
}

exports.initiateUPIPayment = functions
  .region('asia-south1')
  .https.onCall(async (data, context) => {
    if (!context.auth) {
      throw new functions.https.HttpsError(
        'unauthenticated',
        'User must be authenticated'
      );
    }

    const userId = context.auth.uid;
    const { amount, upiId } = data;

    try {
      // Validate input
      if (!amount || amount < 100) {
        throw new functions.https.HttpsError(
          'invalid-argument',
          'Minimum withdrawal amount is ₹100'
        );
      }

      if (!upiId || !isValidUPI(upiId)) {
        throw new functions.https.HttpsError(
          'invalid-argument',
          'Invalid UPI ID format'
        );
      }

      const userDoc = await db.collection('users').doc(userId).get();

      if (!userDoc.exists) {
        throw new functions.https.HttpsError('not-found', 'User not found');
      }

      const userData = userDoc.data();

      if (userData.availableBalance < amount) {
        throw new functions.https.HttpsError(
          'failed-precondition',
          'Insufficient balance'
        );
      }

      // Create order
      const orderRef = await db.collection('orders').add({
        userId: userId,
        amount: amount,
        upiId: upiId,
        status: 'pending',
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        expiresAt: new Date(Date.now() + 30 * 60 * 1000),
      });

      functions.logger.info('Payment order created', {
        orderId: orderRef.id,
        userId: userId,
        amount: amount,
      });

      return { orderId: orderRef.id, amount: amount, status: 'pending' };
    } catch (error) {
      functions.logger.error('Payment initiation error', {
        userId: userId,
        error: error.message,
        stack: error.stack,
      });

      if (error instanceof functions.https.HttpsError) {
        throw error;
      }

      throw new functions.https.HttpsError('internal', 'Payment initiation failed');
    }
  });

exports.confirmUPIPayment = functions
  .region('asia-south1')
  .https.onCall(async (data, context) => {
    if (!context.auth) {
      throw new functions.https.HttpsError(
        'unauthenticated',
        'User must be authenticated'
      );
    }

    const { orderId, paymentId, signature } = data;

    try {
      const orderDoc = await db.collection('orders').doc(orderId).get();

      if (!orderDoc.exists) {
        throw new functions.https.HttpsError('not-found', 'Order not found');
      }

      const orderData = orderDoc.data();

      // Verify signature
      const isValid = verifyRazorpaySignature(orderId, paymentId, signature);

      if (!isValid) {
        functions.logger.warn('Invalid payment signature', { orderId });

        await db.collection('orders').doc(orderId).update({
          status: 'failed',
          reason: 'Invalid signature',
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });

        throw new functions.https.HttpsError(
          'failed-precondition',
          'Invalid payment signature'
        );
      }

      // Update order
      await db.collection('orders').doc(orderId).update({
        status: 'completed',
        paymentId: paymentId,
        signature: signature,
        confirmedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      // Update user balance
      await db.collection('users').doc(orderData.userId).update({
        availableBalance: admin.firestore.FieldValue.increment(
          -orderData.amount
        ),
        withdrawnAmount: admin.firestore.FieldValue.increment(orderData.amount),
        lastWithdrawal: admin.firestore.FieldValue.serverTimestamp(),
      });

      // Record transaction
      await db.collection('transactions').add({
        userId: orderData.userId,
        type: 'withdrawal',
        amount: orderData.amount,
        status: 'completed',
        upiId: orderData.upiId,
        paymentId: paymentId,
        orderId: orderId,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      functions.logger.info('Payment confirmed successfully', {
        orderId: orderId,
        userId: orderData.userId,
        amount: orderData.amount,
      });

      return {
        success: true,
        message: 'Payment processed successfully',
        transactionId: orderId,
      };
    } catch (error) {
      functions.logger.error('Payment confirmation error', {
        orderId: orderId,
        error: error.message,
        stack: error.stack,
      });

      if (error instanceof functions.https.HttpsError) {
        throw error;
      }

      throw new functions.https.HttpsError('internal', 'Payment confirmation failed');
    }
  });

function isValidUPI(upiId) {
  const upiRegex = /^[a-zA-Z0-9.\-_]+@[a-zA-Z]+$/;
  return upiRegex.test(upiId);
}

