import 'package:equatable/equatable.dart';

abstract class PaymentState extends Equatable {
  const PaymentState();
  @override
  List<Object?> get props => [];
}

class PaymentInitial extends PaymentState {
  const PaymentInitial();
}

class PaymentLoading extends PaymentState {
  const PaymentLoading();
}

class WithdrawalInitiated extends PaymentState {
  final String orderId;
  const WithdrawalInitiated({required this.orderId});
  @override
  List<Object> get props => [orderId];
}

class PaymentSuccessful extends PaymentState {
  final String transactionId;
  final double amount;
  const PaymentSuccessful({required this.transactionId, required this.amount});
  @override
  List<Object> get props => [transactionId, amount];
}

class PaymentError extends PaymentState {
  final String message;
  const PaymentError({required this.message});
  @override
  List<Object> get props => [message];
}
