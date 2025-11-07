import 'package:dartz/dartz.dart';
import '../entities/user.dart';

abstract class UserRepository {
  Future<Either<Exception, User>> getUser(String userId);
  Future<Either<Exception, User>> updateUser(User user);
  Future<Either<Exception, List<User>>> getReferrals(String userId);
}
