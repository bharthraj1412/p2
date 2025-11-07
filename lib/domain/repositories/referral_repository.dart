import 'package:dartz/dartz.dart';
import '../entities/referral.dart';

abstract class ReferralRepository {
  Future<Either<Exception, List<Referral>>> getReferrals(String userId);
  Future<Either<Exception, Referral>> createReferral(
    String referrerId,
    String referredId,
  );
  Future<Either<Exception, List<Referral>>> getReferralTree(String userId);
}
