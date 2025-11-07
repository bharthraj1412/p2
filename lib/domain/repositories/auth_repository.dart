import 'package:dartz/dartz.dart';

import '../../data/models/auth_model.dart';

abstract class AuthRepository {
  Future<Either<String, AuthModel>> signInWithEmailAndPassword(
    String email,
    String password,
  );
  Future<Either<String, AuthModel>> signUpWithEmailAndPassword(
    String email,
    String password,
    String name,
    String? referralCode,
  );
  Future<Either<String, AuthModel>> signInWithGoogle();
  Future<Either<String, AuthModel>> signInWithPhoneNumber(
    String phoneNumber,
    String verificationId,
    String smsCode,
  );
  Future<Either<String, void>> verifyPhoneNumber(String phoneNumber);
  Future<Either<String, void>> signOut();
  Future<Either<String, AuthModel?>> getCurrentUser();
  Future<Either<String, void>> resetPassword(String email);
  Future<Either<String, void>> completeProfileSetup(
    Map<String, dynamic> profileData,
  );
  Stream<AuthModel?> authStateChanges();
}
