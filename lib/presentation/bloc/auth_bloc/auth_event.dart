import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class CheckAuthStatusEvent extends AuthEvent {
  const CheckAuthStatusEvent();
}

class RegisterEvent extends AuthEvent {
  final String name;
  final String email;
  final String phone;
  final String upiId;
  final String password;
  final String? referrerId;
  const RegisterEvent({
    required this.name,
    required this.email,
    required this.phone,
    required this.upiId,
    required this.password,
    this.referrerId,
  });

  @override
  List<Object?> get props => [name, email, phone, upiId, password, referrerId];
}

class LoginEvent extends AuthEvent {
  final String email;
  final String password;
  const LoginEvent({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}

class LogoutEvent extends AuthEvent {
  const LogoutEvent();
}

class UpdateProfileEvent extends AuthEvent {
  final String userId;
  final Map<String, dynamic> data;
  const UpdateProfileEvent({required this.userId, required this.data});

  @override
  List<Object> get props => [userId, data];
}
