class Earning {
  final String id;
  final String userId;
  final double amount;
  final String type; // e.g., 'referral', 'bonus'
  final DateTime createdAt;

  Earning({
    required this.id,
    required this.userId,
    required this.amount,
    required this.type,
    required this.createdAt,
  });
}
