import '../entities/commission_entity.dart';
import '../../data/repositories/payment_repository.dart';

class ProcessPaymentUseCase {
  final PaymentRepositoryInterface repository;
  ProcessPaymentUseCase(this.repository);

  Future<String> initiateWithdrawal({
    required String userId,
    required double amount,
    required String upiId,
  }) async {
    if (userId.isEmpty) throw ArgumentError("User ID cannot be empty");
    if (amount <= 0) throw ArgumentError("Amount must be greater than 0");
    if (amount < 100) throw ArgumentError("Minimum withdrawal is 100");
    if (amount > 50000) throw ArgumentError("Maximum withdrawal is 50,000");
    if (upiId.isEmpty) throw ArgumentError("UPI ID cannot be empty");
    if (!isValidUpi(upiId)) throw ArgumentError("Invalid UPI format");

    return await repository.initiateWithdrawal(userId, amount, upiId);
  }

  Future<bool> confirmPayment({
    required String orderId,
    required String paymentId,
    required String signature,
  }) async {
    if (orderId.isEmpty) throw ArgumentError("Order ID cannot be empty");
    if (paymentId.isEmpty) throw ArgumentError("Payment ID cannot be empty");
    if (signature.isEmpty) throw ArgumentError("Signature cannot be empty");

    return await repository.confirmPayment(orderId, paymentId, signature);
  }

  bool isValidUpi(String upiId) {
    final regex = RegExp(r'^[a-zA-Z0-9.\-_]+@[a-zA-Z]+$');
    return regex.hasMatch(upiId);
  }
}
