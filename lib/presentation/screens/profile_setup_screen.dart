import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:form_field_validator/form_field_validator.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_event.dart';
import '../bloc/auth/auth_state.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _upiIdController = TextEditingController();
  final _referralCodeController = TextEditingController();

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _upiIdController.dispose();
    _referralCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Your Profile'),
        centerTitle: true,
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthProfileSetupSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Profile setup completed successfully!'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.of(context).pushReplacementNamed('/dashboard');
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Please provide your information to complete setup',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  // Full Name Field
                  TextFormField(
                    controller: _fullNameController,
                    decoration: const InputDecoration(
                      labelText: 'Full Name',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: MultiValidator([
                      RequiredValidator(errorText: 'Full name is required'),
                      MinLengthValidator(
                        2,
                        errorText: 'Name must be at least 2 characters',
                      ),
                    ]),
                  ),
                  const SizedBox(height: 16),

                  // Email Field
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: MultiValidator([
                      RequiredValidator(errorText: 'Email is required'),
                      EmailValidator(errorText: 'Enter a valid email address'),
                    ]),
                  ),
                  const SizedBox(height: 16),

                  // Phone Number Field
                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.phone),
                      hintText: '10-digit mobile number',
                    ),
                    keyboardType: TextInputType.phone,
                    maxLength: 10,
                    validator: MultiValidator([
                      RequiredValidator(errorText: 'Phone number is required'),
                      PatternValidator(
                        r'^[6-9]\d{9}$',
                        errorText:
                            'Enter a valid 10-digit Indian mobile number',
                      ),
                    ]),
                  ),
                  const SizedBox(height: 16),

                  // UPI ID Field
                  TextFormField(
                    controller: _upiIdController,
                    decoration: const InputDecoration(
                      labelText: 'UPI ID',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.account_balance_wallet),
                      hintText: 'yourname@upi',
                    ),
                    validator: MultiValidator([
                      RequiredValidator(errorText: 'UPI ID is required'),
                      PatternValidator(
                        r'^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+$',
                        errorText: 'Enter a valid UPI ID (e.g., name@upi)',
                      ),
                    ]),
                  ),
                  const SizedBox(height: 16),

                  // Referral Code Field (Optional)
                  TextFormField(
                    controller: _referralCodeController,
                    decoration: const InputDecoration(
                      labelText: 'Referral Code (Optional)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.card_giftcard),
                      hintText: 'Enter referral code if you have one',
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Submit Button
                  ElevatedButton(
                    onPressed: state is AuthLoading ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: state is AuthLoading
                        ? const CircularProgressIndicator()
                        : const Text(
                            'Complete Setup',
                            style: TextStyle(fontSize: 16),
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      final profileData = {
        'fullName': _fullNameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'upiId': _upiIdController.text.trim(),
        'referralCode': _referralCodeController.text.trim().isEmpty
            ? null
            : _referralCodeController.text.trim(),
      };

      context.read<AuthBloc>().add(CompleteProfileSetup(profileData));
    }
  }
}
