import 'package:dartz/dartz.dart';
import '../repositories/user_repository.dart';
import '../entities/user.dart';

class GetUser {
  final UserRepository repository;

  GetUser(this.repository);

  Future<Either<Exception, User>> call(String userId) {
    return repository.getUser(userId);
  }
}
