import '../datasources/firebase_datasource.dart';
import '../models/transaction_model.dart';
import 'package:uuid/uuid.dart';
import '../services/payment_service.dart';

abstract class PaymentRepositoryInterface {
  Future<String> initiateWithdrawal(String userId, double amount, String upiId);
  Future<bool> confirmPayment(
    String orderId,
    String paymentId,
    String signature,
  );
  Future<TransactionModel> getTransactionStatus(String transactionId);
  Future<List<TransactionModel>> getPaymentHistory(String userId);
}

class PaymentRepositoryImpl implements PaymentRepositoryInterface {
  final FirebaseDataSource firebaseDataSource;
  final PaymentService paymentService;

  PaymentRepositoryImpl({
    required this.firebaseDataSource,
    required this.paymentService,
  });

  @override
  Future<String> initiateWithdrawal(
    String userId,
    double amount,
    String upiId,
  ) async {
    try {
      if (amount < 100 || amount > 50000)
        throw Exception("Invalid withdrawal amount");
      final user = await firebaseDataSource.getUserById(userId);
      if (user.availableBalance < amount)
        throw Exception("Insufficient balance");
      final transactionId = const Uuid().v4();
      final transaction = TransactionModel(
        id: transactionId,
        userId: userId,
        amount: amount,
        type: "withdrawal",
        status: "pending",
        description: "UPI Withdrawal to $upiId",
        createdAt: DateTime.now(),
        metadata: {'upiid': upiId},
      );
      await firebaseDataSource.createTransaction(transaction);
      return transactionId;
    } catch (e) {
      throw Exception('Failed to initiate withdrawal: $e');
    }
  }

  @override
  Future<bool> confirmPayment(
    String orderId,
    String paymentId,
    String signature,
  ) async {
    try {
      final isValid = await paymentService.verifyPayment(
        paymentId: paymentId,
        signature: signature,
        orderId: orderId,
      );
      if (!isValid) throw Exception("Payment verification failed");
      await firebaseDataSource.updateTransaction(orderId, {
        "status": "completed",
        "paymentId": paymentId,
        "completedAt": DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      throw Exception('Payment confirmation failed: $e');
    }
  }

  @override
  Future<TransactionModel> getTransactionStatus(String transactionId) async {
    try {
      final transactions = await firebaseDataSource.getUserTransactions("all");
      return transactions.firstWhere((t) => t.id == transactionId);
    } catch (e) {
      throw Exception('Failed to get transaction: $e');
    }
  }

  @override
  Future<List<TransactionModel>> getPaymentHistory(String userId) async {
    try {
      return await firebaseDataSource.getUserTransactions(userId);
    } catch (e) {
      throw Exception('Failed to get payment history: $e');
    }
  }
}
