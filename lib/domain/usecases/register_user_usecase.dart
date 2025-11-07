import '../entities/user_entity.dart';
import '../../data/repositories/auth_repository.dart';

class RegisterUserUseCase {
  final AuthRepositoryInterface repository;
  RegisterUserUseCase(this.repository);

  Future<UserEntity> call({
    required String name,
    required String email,
    required String phone,
    required String upiId,
    required String password,
    String? referrerId,
  }) async {
    // Validate inputs
    if (name.isEmpty) throw ArgumentError("Name cannot be empty");
    if (email.isEmpty) throw ArgumentError("Email cannot be empty");
    if (!email.contains('@')) throw ArgumentError("Invalid email format");
    if (phone.isEmpty) throw ArgumentError("Phone cannot be empty");
    if (phone.length != 10) throw ArgumentError("Phone must be 10 digits");
    if (upiId.isEmpty) throw ArgumentError("UPI ID cannot be empty");
    if (password.isEmpty || password.length < 6)
      throw ArgumentError("Password must be at least 6 characters");

    // Call repository
    final userModel = await repository.registerUser(
      name,
      email,
      phone,
      upiId,
      password,
      referrerId,
    );
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
