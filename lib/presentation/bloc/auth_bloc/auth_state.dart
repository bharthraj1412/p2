import 'package:equatable/equatable.dart';
import '../../../domain/entities/user_entity.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class UnauthenticatedState extends AuthState {
  const UnauthenticatedState();
}

class AuthSuccess extends AuthState {
  final UserEntity user;
  const AuthSuccess({required this.user});

  @override
  List<Object> get props => [user];
}

class AuthFailure extends AuthState {
  final String message;
  const AuthFailure({required this.message});

  @override
  List<Object> get props => [message];
}

class ProfileUpdated extends AuthState {
  final UserEntity user;
  const ProfileUpdated({required this.user});

  @override
  List<Object> get props => [user];
}
