class Transaction {
  final String id;
  final String userId;
  final double amount;
  final String type; // 'hotspot', 'referral', 'withdrawal'
  final String status;
  final DateTime createdAt;

  Transaction({
    required this.id,
    required this.userId,
    required this.amount,
    required this.type,
    required this.status,
    required this.createdAt,
  });
}
