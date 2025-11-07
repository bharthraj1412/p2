import '../entities/referral_entity.dart';
import '../../data/repositories/referral_repository.dart';

class GetReferralTreeUseCase {
  final ReferralRepositoryInterface repository;
  GetReferralTreeUseCase(this.repository);

  Future<List<ReferralEntity>> call(String userId) async {
    if (userId.isEmpty) throw ArgumentError("User ID cannot be empty");

    final tree = await repository.getReferralTree(userId);
    return tree
        .map(
          (item) => ReferralEntity(
            id: item['userid'],
            referrerId: userId,
            referredUserId: item['userid'],
            level: item['level'] ?? 0,
            createdAt: DateTime.now(), // You may want to use item['createdAt']
            isActive: true,
            commissionEarned: item['earnings'] ?? 0.0,
          ),
        )
        .toList();
  }
}
