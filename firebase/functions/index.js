import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import cors from "cors";
admin.initializeApp();
const db = admin.firestore();

// Export all functions

const COMMISSION_STRUCTURE = [
  { level: 0, percentage: 0.15 }, // Direct 15%
  { level: 1, percentage: 0.08 }, // Level 1: 8%
  { level: 2, percentage: 0.05 }, // Level 2: 5%
  { level: 3, percentage: 0.02 }, // Level 3: 2%
  { level: 4, percentage: 0.01 }, // Level 4: 1%
];

// COMMISSION CALCULATION
export const calculateCommissions = functions
  .region("asia-south1")
  .firestore.document("transactions/{transactionId}")
  .onCreate(async (snap, context) => {
    const transaction = snap.data();
    const sourceUserId = transaction.sourceuserid || transaction.userid;
    try {
      functions.logger.info(
        "Processing commissions for transaction",
        context.params.transactionId,
        "userId",
        sourceUserId,
        "amount",
        transaction.amount
      );
      await calculateUplineCommissions(sourceUserId, transaction.amount, 0, context.params.transactionId);
      await snap.ref.update({
        status: "completed",
        processedat: admin.firestore.FieldValue.serverTimestamp(),
      });
      functions.logger.info("Commission calculation completed");
    } catch (error) {
      functions.logger.error("Commission calculation error", error);
      await snap.ref.update({
        status: "failed",
        errormessage: error.message,
      });
    }
  });

async function calculateUplineCommissions(userId, amount, level, transactionId) {
  if (level > 5) return; // Max 5 levels
  try {
    const userDoc = await db.collection("users").doc(userId).get();
    if (!userDoc.exists) {
      functions.logger.warn("User", userId, "not found");
      return;
    }
    const userData = userDoc.data();
    const referrerId = userData.referreruid;
    if (!referrerId) {
      functions.logger.info("Reached top of referral chain for user", userId);
      return;
    }
    const commissionPercentage = COMMISSION_STRUCTURE[level]?.percentage || 0;
    const commissionAmount = amount * commissionPercentage;
    // Record commission
    await db.collection("commissions").add({
      userid: referrerId,
      transactionid: transactionId,
      sourceuserid: userId,
      commissionlevel: level,
      commissionamount: commissionAmount,
      transactionamount: amount,
      status: "approved",
      createdat: admin.firestore.FieldValue.serverTimestamp(),
    });
    // Update user balance atomically
    await db.collection("users").doc(referrerId).update({
      availablebalance: admin.firestore.FieldValue.increment(commissionAmount),
      totalearnings: admin.firestore.FieldValue.increment(commissionAmount),
      lastcommissionat: admin.firestore.FieldValue.serverTimestamp(),
    });
    // Log for audit trail
    await db.collection("auditlogs").add({
      action: "commission_awarded",
      userid: referrerId,
      amount: commissionAmount,
      level: level,
      fromuser: userId,
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
    });
    // Continue up the chain
    await calculateUplineCommissions(referrerId, amount, level + 1, transactionId);
  } catch (error) {
    functions.logger.error("Error processing upline commissions", error);
    throw error;
  }
}

// PAYMENT PROCESSING
const corsHandler = cors({ origin: true });

export const initiateUPIPayment = functions
  .region("asia-south1")
  .https.onCall(async (data, context) => {
    if (!context.auth) throw new functions.https.HttpsError("unauthenticated", "User must be authenticated");
    const userId = context.auth.uid;
    const { amount, upiId } = data;
    try {
      if (!amount || amount < 100) throw new functions.https.HttpsError("invalid-argument", "Minimum withdrawal amount is 100");
      if (!upiId || !isValidUPI(upiId)) throw new functions.https.HttpsError("invalid-argument", "Invalid UPI ID");
      const userDoc = await db.collection("users").doc(userId).get();
      if (!userDoc.exists) throw new functions.https.HttpsError("not-found", "User not found");
      const userData = userDoc.data();
      if (userData.availablebalance < amount) throw new functions.https.HttpsError("failed-precondition", "Insufficient balance");
      const orderRef = await db.collection("orders").add({
        userid: userId,
        amount,
        upiid: upiId,
        status: "pending",
        createdat: admin.firestore.FieldValue.serverTimestamp(),
        expiresat: new Date(Date.now() + 30 * 60 * 1000),
      });
      functions.logger.info("Payment order created", "orderId", orderRef.id, "userId", userId, "amount", amount);
      return { orderId: orderRef.id, amount, status: "pending" };
    } catch (error) {
      functions.logger.error("Payment initiation error", error);
      throw new functions.https.HttpsError("internal", "Payment initiation failed");
    }
  });

export const confirmUPIPayment = functions
  .region("asia-south1")
  .https.onCall(async (data, context) => {
    if (!context.auth) throw new functions.https.HttpsError("unauthenticated", "Must be authenticated");
    const { orderId, paymentId, signature } = data;
    try {
      const orderDoc = await db.collection("orders").doc(orderId).get();
      if (!orderDoc.exists) throw new functions.https.HttpsError("not-found", "Order not found");
      const orderData = orderDoc.data();
      // In production, verify payment signature with Razorpay
      const isValid = verifyRazorpaySignature(orderId, paymentId, signature, process.env.RAZORPAY_KEY_SECRET);
      if (!isValid) {
        functions.logger.warn("Payment signature verification failed");
        throw new functions.https.HttpsError("failed-precondition", "Invalid payment signature");
      }
      await db.collection("orders").doc(orderId).update({
        status: "completed",
        paymentid: paymentId,
        signature,
        confirmedat: admin.firestore.FieldValue.serverTimestamp(),
      });
      await db.collection("users").doc(orderData.userid).update({
        availablebalance: admin.firestore.FieldValue.increment(-orderData.amount),
        withdrawnamount: admin.firestore.FieldValue.increment(orderData.amount),
        lastwithdrawal: admin.firestore.FieldValue.serverTimestamp(),
      });
      await db.collection("transactions").add({
        userid: orderData.userid,
        type: "withdrawal",
        amount: orderData.amount,
        status: "completed",
        upiid: orderData.upiid,
        paymentid: paymentId,
        createdat: admin.firestore.FieldValue.serverTimestamp(),
      });
      functions.logger.info("Payment confirmed", "orderId", orderId, "userId", orderData.userid, "amount", orderData.amount);
      return { success: true, message: "Payment processed successfully" };
    } catch (error) {
      functions.logger.error("Payment confirmation error", error);
      throw new functions.https.HttpsError("internal", "Payment confirmation failed");
    }
  });

function verifyRazorpaySignature(orderId, paymentId, signature, keySecret) {
  // In production: import crypto and verify
  // const crypto = require('crypto');
  // const expectedSignature = crypto.createHmac('sha256', keySecret).update(orderId + '|' + paymentId).digest('hex');
  // return expectedSignature === signature;
  // For development:
  return true;
}
function isValidUPI(upiId) {
  const upiRegex = /^[a-zA-Z0-9.\-_]+@[a-zA-Z]+$/;
  return upiRegex.test(upiId);
}

// USER MANAGEMENT
export const onUserCreated = functions
  .region("asia-south1")
  .auth.user()
  .onCreate(async (user) => {
    try {
      await db.collection("users").doc(user.uid).set({
        email: user.email,
        phone: user.phoneNumber || "",
        createdat: admin.firestore.FieldValue.serverTimestamp(),
        role: "user",
      });
      functions.logger.info("User created", "userId", user.uid);
    } catch (error) {
      functions.logger.error("Error creating user document", error);
    }
  });

export const onUserDeleted = functions
  .region("asia-south1")
  .auth.user()
  .onDelete(async (user) => {
    try {
      await db.collection("users").doc(user.uid).delete();
      // Archive transactions
      const transactions = await db.collection("transactions").where("userid", "==", user.uid).get();
      const batch = db.batch();
      for (const doc of transactions.docs) {
        batch.update(doc.ref, { archived: true, archivedat: admin.firestore.FieldValue.serverTimestamp() });
      }
      await batch.commit();
      functions.logger.info("User deleted", "userId", user.uid);
    } catch (error) {
      functions.logger.error("Error deleting user", error);
    }
  });

// STATISTICS & REPORTING
export const generateDailyStats = functions
  .region("asia-south1")
  .pubsub.schedule("every day 00:00")
  .timeZone("Asia/Kolkata")
  .onRun(async (context) => {
    try {
      const today = new Date();
      today.setHours(0, 0, 0, 0);
      const tomorrow = new Date(today);
      tomorrow.setDate(tomorrow.getDate() + 1);
      const transactions = await db
        .collection("transactions")
        .where("createdat", ">", admin.firestore.Timestamp.fromDate(today))
        .where("createdat", "<", admin.firestore.Timestamp.fromDate(tomorrow))
        .get();
      let totalEarnings = 0;
      let totalUsers = new Set();
      for (const doc of transactions.docs) {
        const data = doc.data();
        totalEarnings += data.amount || 0;
        totalUsers.add(data.userid);
      }
      await db.collection("dailystats").add({
        date: admin.firestore.Timestamp.fromDate(today),
        totaltransactions: transactions.size,
        totalearnings: totalEarnings,
        activeusers: totalUsers.size,
        createdat: admin.firestore.FieldValue.serverTimestamp(),
      });
      functions.logger.info("Daily stats generated", "date", today.toISOString(), "transactions", transactions.size, "earnings", totalEarnings, "users", totalUsers.size);
    } catch (error) {
      functions.logger.error("Error generating daily stats", error);
    }
  });

// FRAUD DETECTION
export const detectFraudulentActivity = functions
  .region("asia-south1")
  .firestore.document("transactions/{transactionId}")
  .onCreate(async (snap, context) => {
    try {
      const transaction = snap.data();
      const userId = transaction.userid;
      // Get user's recent transactions (last hour)
      const recentTx = await db
        .collection("transactions")
        .where("userid", "==", userId)
        .where("createdat", ">", admin.firestore.Timestamp.fromDate(new Date(Date.now() - 60 * 60 * 1000)))
        .get();
      let totalAmount = 0;
      for (const doc of recentTx.docs) {
        totalAmount += doc.data().amount || 0;
      }
      // Fraud detection rules: more than 5 txs AND >50,000 amount in last hour
      if (recentTx.size > 5 && totalAmount > 50000) {
        functions.logger.warn("Suspicious activity detected", "userId", userId, "transactions", recentTx.size, "amount", totalAmount);
        await db.collection("fraudflags").add({
          userid: userId,
          reason: "ExcessiveTransactions",
          transactioncount: recentTx.size,
          totalamount: totalAmount,
          flaggedat: admin.firestore.FieldValue.serverTimestamp(),
        });
      }
    } catch (error) {
      functions.logger.error("Error in fraud detection", error);
    }
  });
