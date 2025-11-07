class Referral {
  final String id;
  final String referrerId;
  final String referredUid;
  final int level;
  final double commissionPercentage;
  final DateTime referralDate;

  Referral({
    required this.id,
    required this.referrerId,
    required this.referredUid,
    required this.level,
    required this.commissionPercentage,
    required this.referralDate,
  });
}
