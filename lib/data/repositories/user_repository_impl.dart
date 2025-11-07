import 'package:dartz/dartz.dart';
import '../../domain/repositories/user_repository.dart';
import '../../domain/entities/user.dart';
import '../models/user_model.dart';
import '../services/firebase_auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserRepositoryImpl implements UserRepository {
  final FirebaseAuthService authService;
  final FirebaseFirestore firestore;

  UserRepositoryImpl(this.authService, this.firestore);

  @override
  Future<Either<Exception, User>> getUser(String userId) async {
    try {
      DocumentSnapshot doc = await firestore
          .collection('users')
          .doc(userId)
          .get();
      if (doc.exists) {
        UserModel userModel = UserModel.fromJson(
          doc.data() as Map<String, dynamic>,
        );
        return Right(userModel);
      } else {
        return Left(Exception('User not found'));
      }
    } catch (e) {
      return Left(Exception('Failed to get user: $e'));
    }
  }

  @override
  Future<Either<Exception, User>> updateUser(User user) async {
    try {
      UserModel userModel = UserModel(
        id: user.id,
        email: user.email,
        name: user.name,
        phone: user.phone,
        upiId: user.upiId,
        referrerUid: user.referrerUid,
        totalEarnings: user.totalEarnings,
        availableBalance: user.availableBalance,
        withdrawnAmount: user.withdrawnAmount,
        kycVerified: user.kycVerified,
        createdAt: user.createdAt,
        referralCode: user.referralCode,
        level: user.level,
      );
      await firestore.collection('users').doc(user.id).set(userModel.toJson());
      return Right(userModel);
    } catch (e) {
      return Left(Exception('Failed to update user: $e'));
    }
  }

  @override
  Future<Either<Exception, List<User>>> getReferrals(String userId) async {
    try {
      QuerySnapshot query = await firestore
          .collection('referrals')
          .where('referrer_id', isEqualTo: userId)
          .get();
      List<User> referrals = query.docs
          .map((doc) => UserModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
      return Right(referrals);
    } catch (e) {
      return Left(Exception('Failed to get referrals: $e'));
    }
  }
}
