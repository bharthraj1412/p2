import 'package:flutter_bloc/flutter_bloc.dart';
import 'payment_event.dart';
import 'payment_state.dart';
import '../../../domain/usecases/process_payment_usecase.dart';

class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  final ProcessPaymentUseCase processPaymentUseCase;

  PaymentBloc({required this.processPaymentUseCase})
    : super(const PaymentInitial()) {
    on<InitiateWithdrawalEvent>(_onInitiateWithdrawal);
    on<ConfirmPaymentEvent>(_onConfirmPayment);
  }

  Future<void> _onInitiateWithdrawal(
    InitiateWithdrawalEvent event,
    Emitter<PaymentState> emit,
  ) async {
    emit(const PaymentLoading());
    try {
      final orderId = await processPaymentUseCase.initiateWithdrawal(
        userId: event.userId,
        amount: event.amount,
        upiId: event.upiId,
      );
      emit(WithdrawalInitiated(orderId: orderId));
    } catch (e) {
      emit(PaymentError(message: e.toString()));
    }
  }

  Future<void> _onConfirmPayment(
    ConfirmPaymentEvent event,
    Emitter<PaymentState> emit,
  ) async {
    emit(const PaymentLoading());
    try {
      final success = await processPaymentUseCase.confirmPayment(
        orderId: event.orderId,
        paymentId: event.paymentId,
        signature: event.signature,
      );
      if (success) {
        emit(PaymentSuccessful(transactionId: event.orderId, amount: 0.0));
      } else {
        emit(const PaymentError(message: "Payment confirmation failed"));
      }
    } catch (e) {
      emit(PaymentError(message: e.toString()));
    }
  }
}
