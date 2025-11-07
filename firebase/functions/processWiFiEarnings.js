const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

exports.onWiFiSessionCreate = functions.firestore
  .document('wifi_sessions/{sessionId}')
  .onCreate(async (snap, context) => {
    const session = snap.data();
    const userId = session.user_id;

    // Award ₹1 for each WiFi session
    const earnings = 1.0;

    // Record transaction
    await admin.firestore().collection('transactions').add({
      user_id: userId,
      amount: earnings,
      type: 'hotspot',
      status: 'approved',
      created_at: admin.firestore.FieldValue.serverTimestamp(),
    });

    // Update user balance
    await admin.firestore().collection('users').doc(userId).update({
      available_balance: admin.firestore.FieldValue.increment(earnings),
      total_earnings: admin.firestore.FieldValue.increment(earnings),
    });

    // Trigger commission calculation
    // (Commission BLoC will handle this)
  });
