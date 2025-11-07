import 'package:flutter/services.dart';
import '../../core/encryption/encryption_service.dart';
import '../datasources/firebase_datasource.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class PaymentService {
  final EncryptionService encryption;
  final FirebaseDataSource firebaseDataSource;

  PaymentService({required this.encryption, required this.firebaseDataSource});

  // Verify Razorpay payment signature
  bool verifyRazorpaySignature({
    required String orderId,
    required String paymentId,
    required String signature,
    required String razorpayKeySecret,
  }) {
    final payload = '$orderId|$paymentId';
    final expectedSignature = Hmac(
      sha256,
      utf8.encode(razorpayKeySecret),
    ).convert(utf8.encode(payload)).toString();
    return signature == expectedSignature;
  }

  // Generate payment link
  Map<String, dynamic> generatePaymentLink({
    required double amount,
    required String userId,
    required String upiId,
  }) {
    return {
      'amount': (amount * 100).toInt(), // Razorpay uses paise
      'currency': 'INR',
      'customer': {'contact': '9999999999', 'email': 'user@example.com'},
      'notify': {'sms': true, 'email': true},
      'reminder_enable': true,
      'notes': {'userid': userId, 'upiid': upiId},
    };
  }

  // Validate UPI ID format
  bool isValidUpiId(String upiId) {
    final regex = RegExp(r'^[a-zA-Z0-9.\-_]+@[a-zA-Z]+$');
    return regex.hasMatch(upiId);
  }

  // Process refund
  Future<bool> processRefund({
    required String paymentId,
    required double amount,
    required String reason,
  }) async {
    try {
      // In production, call Razorpay refund API
      print('Refund processed: $paymentId, Amount: $amount, Reason: $reason');
      return true;
    } catch (e) {
      print('Refund failed: $e');
      return false;
    }
  }

  // Get payment status
  Future<String> getPaymentStatus(String paymentId) async {
    try {
      // In production, fetch from Razorpay API
      return 'completed';
    } catch (e) {
      return 'unknown';
    }
  }
}
