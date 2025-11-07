import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../config/app_config.dart';

class PaymentService {
  late Razorpay _razorpay;
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  PaymentService() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  Future<Map<String, dynamic>> createPaymentOrder({
    required double amount,
    required String upiId,
  }) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) throw Exception('User not authenticated');

      // Call Firebase Cloud Function to create order
      final result = await _functions.httpsCallable('createPaymentOrder').call({
        'userId': userId,
        'amount': amount,
        'upiId': upiId,
      });

      return result.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to create payment order: $e');
    }
  }

  Future<Map<String, dynamic>> confirmPayment(String paymentId) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) throw Exception('User not authenticated');

      // Call Firebase Cloud Function to confirm payment
      final result = await _functions.httpsCallable('confirmPayment').call({
        'userId': userId,
        'paymentId': paymentId,
      });

      return result.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to confirm payment: $e');
    }
  }

  Future<void> initiateWithdrawal({
    required String userId,
    required double amount,
    required String upiId,
  }) async {
    try {
      // Call Firebase Cloud Function to create order
      final result = await _functions.httpsCallable('initiateUPIPayment').call({
        'userId': userId,
        'amount': amount,
        'upiId': upiId,
      });

      final orderId = result.data['orderId'];

      // Open Razorpay checkout
      var options = {
        'key': AppConfig.razorpayKeyId,
        'order_id': orderId,
        'amount': (amount * 100).toInt(),
        'currency': 'INR',
        'name': 'ShareNet Earn',
        'description': 'Withdrawal to $upiId',
        'prefill': {
          'contact': FirebaseAuth.instance.currentUser?.phoneNumber ?? '',
          'email': FirebaseAuth.instance.currentUser?.email ?? '',
        },
        'theme': {'color': '#0066FF'},
      };

      _razorpay.open(options);
    } catch (e) {
      throw Exception('Failed to initiate payment: $e');
    }
  }

  void openCheckout({
    required double amount,
    required String name,
    required String description,
    required String contact,
    required String email,
    required Function(PaymentSuccessResponse) onSuccess,
    required Function(PaymentFailureResponse) onError,
  }) {
    var options = {
      'key': AppConfig.razorpayKeyId,
      'amount': (amount * 100).toInt(), // Amount in paise
      'name': name,
      'description': description,
      'prefill': {'contact': contact, 'email': email},
      'theme': {'color': '#3399cc'},
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      print('Error: $e');
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    // Handle successful payment
    print('Payment Success: ${response.paymentId}');
    // TODO: Update transaction in Firebase
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    // Handle payment failure
    print('Payment Error: ${response.code} - ${response.message}');
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    // Handle external wallet
    print('External Wallet: ${response.walletName}');
  }

  void dispose() {
    _razorpay.clear();
  }
}
