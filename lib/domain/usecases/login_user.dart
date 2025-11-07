import 'package:dartz/dartz.dart';

import '../repositories/auth_repository.dart';
import '../../data/models/auth_model.dart';

class LoginUserUseCase {
  final AuthRepository authRepository;

  LoginUserUseCase(this.authRepository);

  Future<Either<String, AuthModel>> call({
    required String email,
    required String password,
  }) async {
    try {
      final result = await authRepository.signInWithEmailAndPassword(
        email,
        password,
      );
      return result;
    } catch (e) {
      return Left('Login failed: $e');
    }
  }
}
