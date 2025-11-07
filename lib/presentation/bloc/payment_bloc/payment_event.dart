import 'package:equatable/equatable.dart';

abstract class PaymentEvent extends Equatable {
  const PaymentEvent();
  @override
  List<Object> get props => [];
}

class InitiateWithdrawalEvent extends PaymentEvent {
  final String userId;
  final double amount;
  final String upiId;
  const InitiateWithdrawalEvent({
    required this.userId,
    required this.amount,
    required this.upiId,
  });

  @override
  List<Object> get props => [userId, amount, upiId];
}

class ConfirmPaymentEvent extends PaymentEvent {
  final String orderId;
  final String paymentId;
  final String signature;
  const ConfirmPaymentEvent({
    required this.orderId,
    required this.paymentId,
    required this.signature,
  });

  @override
  List<Object> get props => [orderId, paymentId, signature];
}
