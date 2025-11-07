class UserEntity {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String upiId;
  final String? referrerId;
  final bool kycVerified;
  final double totalEarnings;
  final double availableBalance;
  final double withdrawnAmount;
  final DateTime createdAt;
  final DateTime? updatedAt;

  UserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.upiId,
    this.referrerId,
    required this.kycVerified,
    required this.totalEarnings,
    required this.availableBalance,
    required this.withdrawnAmount,
    required this.createdAt,
    this.updatedAt,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          email == other.email;

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ email.hashCode;

  @override
  String toString() =>
      "UserEntity(id: $id, name: $name, email: $email, totalEarnings: $totalEarnings)";
}
