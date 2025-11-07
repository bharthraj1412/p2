import '../../domain/entities/user.dart';

class UserModel extends User {
  UserModel({
    required super.id,
    required super.email,
    required super.name,
    super.phone,
    super.upiId,
    super.referrerUid,
    super.totalEarnings,
    super.availableBalance,
    super.withdrawnAmount,
    super.kycVerified,
    required super.createdAt,
    super.referralCode,
    super.level,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      phone: json['phone'],
      upiId: json['upi_id'],
      referrerUid: json['referrer_uid'],
      totalEarnings: json['total_earnings']?.toDouble() ?? 0.0,
      availableBalance: json['available_balance']?.toDouble() ?? 0.0,
      withdrawnAmount: json['withdrawn_amount']?.toDouble() ?? 0.0,
      kycVerified: json['kyc_verified'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      referralCode: json['referral_code'],
      level: json['level'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phone': phone,
      'upi_id': upiId,
      'referrer_uid': referrerUid,
      'total_earnings': totalEarnings,
      'available_balance': availableBalance,
      'withdrawn_amount': withdrawnAmount,
      'kyc_verified': kycVerified,
      'created_at': createdAt.toIso8601String(),
      'referral_code': referralCode,
      'level': level,
    };
  }
}
