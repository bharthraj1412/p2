import '../entities/user_entity.dart';
import '../../data/repositories/auth_repository.dart';

class LoginUserUseCase {
  final AuthRepositoryInterface repository;
  LoginUserUseCase(this.repository);

  Future<UserEntity> call({
    required String email,
    required String password,
  }) async {
    if (email.isEmpty) throw ArgumentError("Email cannot be empty");
    if (!email.contains('@')) throw ArgumentError("Invalid email format");
    if (password.isEmpty) throw ArgumentError("Password cannot be empty");

    final userModel = await repository.loginUser(email, password);
    return mapModelToEntity(userModel);
  }

  UserEntity mapModelToEntity(dynamic model) => UserEntity(
    id: model.id,
    name: model.name,
    email: model.email,
    phone: model.phone,
    upiId: model.upiId,
    referrerId: model.referrerId,
    kycVerified: model.kycVerified,
    totalEarnings: model.totalEarnings,
    availableBalance: model.availableBalance,
    withdrawnAmount: model.withdrawnAmount,
    createdAt: model.createdAt,
    updatedAt: model.updatedAt,
  );
}
