// firebase/functions/calculateCommissions.js
const functions = require('firebase-functions');
const admin = require('firebase-admin');

exports.onTransactionCreate = functions.firestore
  .document('transactions/{transactionId}')
  .onCreate(async (snap, context) => {
    const transaction = snap.data();
    const sourceUserId = transaction.source_user_id;
    // Recursive commission calculation
    await calculateUplineCommissions(
      sourceUserId,
      transaction.amount,
      0
    );
  });

async function calculateUplineCommissions(userId, amount, level) {
  if (level >= 5) return; // Max 5 levels
  const user = await admin.firestore()
    .collection('users')
    .doc(userId)
    .get();
  if (!user.exists) return;
  const referrerId = user.data().referrer_uid;
  if (!referrerId) return;
  const commissionPercentages = [0.15, 0.08, 0.05, 0.02, 0.01];
  const commission = amount * commissionPercentages[level];
  // Record commission
  await admin.firestore().collection('commissions').add({
    user_id: referrerId,
    transaction_id: context.params.transactionId,
    commission_level: level,
    commission_amount: commission,
    status: 'approved',
    created_at: admin.firestore.FieldValue.serverTimestamp(),
  });
  // Update user balance
  await admin.firestore().collection('users').doc(referrerId).update({
    available_balance: admin.firestore.FieldValue.increment(commission),
    total_earnings: admin.firestore.FieldValue.increment(commission),
  });
  // Continue up the tree
  await calculateUplineCommissions(referrerId, amount, level + 1);
}
