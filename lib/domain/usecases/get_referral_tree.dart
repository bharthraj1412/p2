import 'package:dartz/dartz.dart';
import '../repositories/referral_repository.dart';
import '../entities/referral.dart';

class GetReferralTree {
  final ReferralRepository repository;

  GetReferralTree(this.repository);

  Future<Either<Exception, List<Referral>>> call(String userId) {
    return repository.getReferralTree(userId);
  }
}
