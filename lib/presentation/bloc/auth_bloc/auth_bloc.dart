import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import '../../../domain/usecases/register_user_usecase.dart';
import '../../../domain/usecases/login_user_usecase.dart';
import '../../../domain/entities/user_entity.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final RegisterUserUseCase registerUserUseCase;
  final LoginUserUseCase loginUserUseCase;

  AuthBloc({required this.registerUserUseCase, required this.loginUserUseCase})
    : super(const AuthInitial()) {
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
    on<RegisterEvent>(_onRegister);
    on<LoginEvent>(_onLogin);
    on<LogoutEvent>(_onLogout);
    on<UpdateProfileEvent>(_onUpdateProfile);
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      // Add logic to check authentication
      emit(const UnauthenticatedState());
    } catch (e) {
      emit(AuthFailure(message: e.toString()));
    }
  }

  Future<void> _onRegister(RegisterEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    try {
      final user = await registerUserUseCase.call(
        name: event.name,
        email: event.email,
        phone: event.phone,
        upiId: event.upiId,
        password: event.password,
        referrerId: event.referrerId,
      );
      emit(AuthSuccess(user: user));
    } catch (e) {
      emit(AuthFailure(message: e.toString()));
    }
  }

  Future<void> _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    try {
      final user = await loginUserUseCase.call(
        email: event.email,
        password: event.password,
      );
      emit(AuthSuccess(user: user));
    } catch (e) {
      emit(AuthFailure(message: e.toString()));
    }
  }

  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    try {
      // Add logout logic here
      emit(const UnauthenticatedState());
    } catch (e) {
      emit(AuthFailure(message: e.toString()));
    }
  }

  Future<void> _onUpdateProfile(
    UpdateProfileEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      // Add profile update logic here
      if (state is AuthSuccess) {
        // Example: emit(ProfileUpdated(user: updatedUser));
      }
    } catch (e) {
      emit(AuthFailure(message: e.toString()));
    }
  }
}
