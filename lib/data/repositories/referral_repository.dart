import '../datasources/firebase_datasource.dart';
import '../../core/security/frauddetection.dart';

abstract class ReferralRepositoryInterface {
  Future<List<Map<String, dynamic>>> getReferralTree(String userId);
  Future<int> getReferralCount(String userId, {int level = 0});
  Future<double> calculateCommission(String userId, int level);
  Future<bool> validateReferralCode(String code, String userId);
}

class ReferralRepositoryImpl implements ReferralRepositoryInterface {
  final FirebaseDataSource firebaseDataSource;
  final FraudDetectionService fraudDetection = FraudDetectionService();

  ReferralRepositoryImpl({required this.firebaseDataSource});

  @override
  Future<List<Map<String, dynamic>>> getReferralTree(String userId) async {
    try {
      final tree = await firebaseDataSource.getReferralTree(userId);
      // Integrity check
      final userIds = tree.map((t) => t['userid'] as String).toList();
      if (!fraudDetection.validateReferralChain(userIds)) {
        throw Exception('Invalid referral chain detected');
      }
      return tree;
    } catch (e) {
      throw Exception('Failed to get referral tree: $e');
    }
  }

  @override
  Future<int> getReferralCount(String userId, {int level = 0}) async {
    try {
      final tree = await getReferralTree(userId);
      return tree.where((t) => t['level'] == level).length;
    } catch (e) {
      throw Exception('Failed to get referral count: $e');
    }
  }

  @override
  Future<double> calculateCommission(String userId, int level) async {
    try {
      final commissionRates = [0.15, 0.08, 0.05, 0.02, 0.01];
      if (level > commissionRates.length) return 0.0;
      final earnings = await firebaseDataSource.calculateTotalEarnings(userId);
      return earnings * commissionRates[level];
    } catch (e) {
      throw Exception('Failed to calculate commission: $e');
    }
  }

  @override
  Future<bool> validateReferralCode(String code, String userId) async {
    try {
      // Format and logical checks
      if (code.length < 6 || code.length > 20) return false;
      if (code == userId) return false;
      // Production: validate in DB
      return true;
    } catch (e) {
      return false;
    }
  }
}
