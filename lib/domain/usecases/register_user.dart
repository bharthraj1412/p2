import 'package:dartz/dartz.dart';

import '../repositories/auth_repository.dart';
import '../repositories/user_repository.dart';
import '../../data/models/auth_model.dart';

class RegisterUserUseCase {
  final AuthRepository authRepository;
  final UserRepository userRepository;

  RegisterUserUseCase(this.authRepository, this.userRepository);

  Future<Either<String, AuthModel>> call({
    required String email,
    required String password,
    required String name,
    String? referralCode,
  }) async {
    try {
      // First, register with Firebase Auth
      final authResult = await authRepository.signUpWithEmailAndPassword(
        email,
        password,
        name,
        referralCode,
      );

      return authResult.fold((error) => Left(error), (authModel) async {
        // If auth successful, create user profile in Firestore
        // This would be handled in the AuthRepository implementation
        return Right(authModel);
      });
    } catch (e) {
      return Left('Registration failed: $e');
    }
  }
}
