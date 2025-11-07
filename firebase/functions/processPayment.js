// firebase/functions/processPayment.js
const functions = require('firebase-functions');
const admin = require('firebase-admin');
const Razorpay = require('razorpay');

admin.initializeApp();

exports.initiateUPIPayment = functions.https.onCall(async (data, context) => {
  if (!context.auth) throw new functions.https.HttpsError('unauthenticated', 'Unauthorized');

  const { userId, amount, upiId } = data;

  if (!userId || !amount || !upiId) {
    throw new functions.https.HttpsError('invalid-argument', 'Missing required parameters');
  }

  const razorpay = new Razorpay({
    key_id: functions.config().razorpay.key_id,
    key_secret: functions.config().razorpay.key_secret,
  });

  try {
    // Create order
    const order = await razorpay.orders.create({
      amount: Math.round(amount * 100), // Convert to paise
      currency: 'INR',
      receipt: `withdrawal_${userId}_${Date.now()}`,
    });

    // Save order in Firestore
    await admin.firestore().collection('orders').add({
      user_id: userId,
      razorpay_order_id: order.id,
      amount: amount,
      upi_id: upiId,
      status: 'pending',
      created_at: admin.firestore.FieldValue.serverTimestamp(),
    });

    return { orderId: order.id };
  } catch (error) {
    console.error('Payment error:', error);
    throw new functions.https.HttpsError('internal', 'Payment initiation failed');
  }
});
