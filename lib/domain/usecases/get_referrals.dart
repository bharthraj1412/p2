import 'package:dartz/dartz.dart';
import '../repositories/referral_repository.dart';
import '../entities/referral.dart';

class GetReferrals {
  final ReferralRepository repository;

  GetReferrals(this.repository);

  Future<Either<Exception, List<Referral>>> call(String userId) {
    return repository.getReferrals(userId);
  }
}
