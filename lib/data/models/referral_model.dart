import '../../domain/entities/referral.dart';

class ReferralModel extends Referral {
  const ReferralModel({
    required super.id,
    required super.referrerId,
    required super.referredUid,
    required super.level,
    required super.commissionPercentage,
    required super.referralDate,
  });

  factory ReferralModel.fromJson(Map<String, dynamic> json) {
    return ReferralModel(
      id: json['id'] as String,
      referrerId: json['referrer_id'] as String,
      referredUid: json['referred_uid'] as String,
      level: json['level'] as int,
      commissionPercentage: (json['commission_percentage'] as num).toDouble(),
      referralDate: DateTime.parse(json['referral_date'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'referrer_id': referrerId,
      'referred_uid': referredUid,
      'level': level,
      'commission_percentage': commissionPercentage,
      'referral_date': referralDate.toIso8601String(),
    };
  }

  factory ReferralModel.fromEntity(Referral entity) {
    return ReferralModel(
      id: entity.id,
      referrerId: entity.referrerId,
      referredUid: entity.referredUid,
      level: entity.level,
      commissionPercentage: entity.commissionPercentage,
      referralDate: entity.referralDate,
    );
  }
}
