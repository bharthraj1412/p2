class CommissionEntity {
  final String id;
  final String userId;
  final String transactionId;
  final String sourceUserId;
  final int commissionLevel;
  final double commissionAmount;
  final double transactionAmount;
  final String status; // 'pending', 'approved', 'rejected'
  final DateTime createdAt;

  CommissionEntity({
    required this.id,
    required this.userId,
    required this.transactionId,
    required this.sourceUserId,
    required this.commissionLevel,
    required this.commissionAmount,
    required this.transactionAmount,
    required this.status,
    required this.createdAt,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CommissionEntity &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'CommissionEntity(id: $id, userId: $userId, amount: $commissionAmount, status: $status)';
}
