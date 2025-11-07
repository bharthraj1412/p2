import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/payment_bloc/payment_bloc.dart';
import '../bloc/payment_bloc/payment_event.dart';
import '../bloc/payment_bloc/payment_state.dart';
import '../bloc/auth_bloc/auth_bloc.dart';
import '../bloc/auth_bloc/auth_state.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({Key? key}) : super(key: key);

  @override
  State<PaymentScreen> createState() => PaymentScreenState();
}

class PaymentScreenState extends State<PaymentScreen> {
  final amountController = TextEditingController();
  final upiController = TextEditingController();

  @override
  void dispose() {
    amountController.dispose();
    upiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Withdraw Earnings")),
      body: BlocListener<PaymentBloc, PaymentState>(
        listener: (context, state) {
          if (state is PaymentSuccessful) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Payment successful!")),
            );
            Navigator.pop(context);
          } else if (state is PaymentError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text("Error: ${state.message}")));
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Withdrawal Amount",
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: "Enter amount (100 - 50,000)",
                  prefixText: "₹",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text("UPI ID", style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 10),
              TextField(
                controller: upiController,
                decoration: InputDecoration(
                  hintText: "Enter UPI ID (e.g., user@upi)",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              BlocBuilder<PaymentBloc, PaymentState>(
                builder: (context, state) {
                  return SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: state is PaymentLoading ? null : onWithdraw,
                      child: state is PaymentLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text("Proceed to Payment"),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void onWithdraw() {
    final amount = double.tryParse(amountController.text);
    final upiId = upiController.text;
    if (amount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid amount")),
      );
      return;
    }
    if (upiId.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please enter UPI ID")));
      return;
    }
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthSuccess) {
      context.read<PaymentBloc>().add(
        InitiateWithdrawalEvent(
          userId: authState.user.id,
          amount: amount,
          upiId: upiId,
        ),
      );
    }
  }
}
