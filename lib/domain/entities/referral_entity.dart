class ReferralEntity {
  final String id;
  final String referrerId;
  final String referredUserId;
  final int level;
  final DateTime createdAt;
  final bool isActive;
  final double commissionEarned;

  ReferralEntity({
    required this.id,
    required this.referrerId,
    required this.referredUserId,
    required this.level,
    required this.createdAt,
    required this.isActive,
    required this.commissionEarned,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReferralEntity &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'ReferralEntity(id: $id, level: $level, commissionEarned: $commissionEarned)';
}
