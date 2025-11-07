const admin = require('firebase-admin');
const functions = require('firebase-functions');

const db = admin.firestore();

const COMMISSION_STRUCTURE = [
  { level: 0, percentage: 0.15 }, // Direct: 15%
  { level: 1, percentage: 0.08 }, // Level 1: 8%
  { level: 2, percentage: 0.05 }, // Level 2: 5%
  { level: 3, percentage: 0.02 }, // Level 3: 2%
  { level: 4, percentage: 0.01 }, // Level 4: 1%
];

exports.calculateCommissions = functions
  .region('asia-south1')
  .firestore.document('transactions/{transactionId}')
  .onCreate(async (snap, context) => {
    const transaction = snap.data();
    const sourceUserId = transaction.sourceuserId || transaction.userId;
    const transactionId = context.params.transactionId;

    try {
      functions.logger.info(
        `Processing commissions for transaction ${transactionId}`,
        {
          userId: sourceUserId,
          amount: transaction.amount,
        }
      );

      await calculateUplineCommissions(
        sourceUserId,
        transaction.amount,
        0,
        transactionId
      );

      await snap.ref.update({
        status: 'completed',
        processedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      functions.logger.info(
        `Commission calculation completed for transaction ${transactionId}`
      );
    } catch (error) {
      functions.logger.error(
        `Commission calculation error for transaction ${transactionId}`,
        { error: error.message, stack: error.stack }
      );

      await snap.ref.update({
        status: 'failed',
        errorMessage: error.message,
      });
    }
  });

async function calculateUplineCommissions(
  userId,
  amount,
  level,
  transactionId
) {
  if (level >= COMMISSION_STRUCTURE.length) {
    functions.logger.info(`Reached max commission level for userId: ${userId}`);
    return;
  }

  try {
    const userDoc = await db.collection('users').doc(userId).get();

    if (!userDoc.exists) {
      functions.logger.warn(`User not found: ${userId}`);
      return;
    }

    const userData = userDoc.data();
    const referrerId = userData.referrerUid;

    if (!referrerId) {
      functions.logger.info(
        `Reached top of referral chain for user: ${userId}`
      );
      return;
    }

    const commissionPercentage = COMMISSION_STRUCTURE[level].percentage;
    const commissionAmount = amount * commissionPercentage;

    // Record commission
    await db.collection('commissions').add({
      userId: referrerId,
      transactionId: transactionId,
      sourceUserId: userId,
      commissionLevel: level,
      commissionAmount: commissionAmount,
      transactionAmount: amount,
      status: 'approved',
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    functions.logger.debug(
      `Commission awarded to ${referrerId}: ${commissionAmount} at level ${level}`
    );

    // Update user balance
    await db.collection('users').doc(referrerId).update({
      availableBalance: admin.firestore.FieldValue.increment(commissionAmount),
      totalEarnings: admin.firestore.FieldValue.increment(commissionAmount),
      lastCommissionAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    // Continue up the chain
    await calculateUplineCommissions(referrerId, amount, level + 1, transactionId);
  } catch (error) {
    functions.logger.error(`Error in calculateUplineCommissions at level ${level}`, {
      userId: userId,
      error: error.message,
      stack: error.stack,
    });
    throw error;
  }
}
