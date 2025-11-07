import '../datasources/firebase_datasource.dart';
import '../datasources/local_datasource.dart';
import '../models/user_model.dart';
import '../../core/encryption/encryption_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthRepositoryInterface {
  Future<UserModel> registerUser(
    String name,
    String email,
    String phone,
    String upiId,
    String password, [
    String? referrerId,
  ]);
  Future<UserModel> loginUser(String email, String password);
  Future<UserModel?> getCurrentUser();
  Future<void> logoutUser();
  Future<void> updateUserProfile(String userId, Map<String, dynamic> data);
  Future<bool> isUserAuthenticated();
}

class AuthRepositoryImpl implements AuthRepositoryInterface {
  final FirebaseDataSource firebaseDataSource;
  final LocalDataSource localDataSource;
  final EncryptionService encryption;

  AuthRepositoryImpl({
    required this.firebaseDataSource,
    required this.localDataSource,
    required this.encryption,
  });

  @override
  Future<UserModel> registerUser(
    String name,
    String email,
    String phone,
    String upiId,
    String password, [
    String? referrerId,
  ]) async {
    try {
      // Validate input
      if (name.isEmpty ||
          email.isEmpty ||
          phone.isEmpty ||
          upiId.isEmpty ||
          password.isEmpty) {
        throw Exception("All fields are required");
      }
      // Create auth user
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      final userId = userCredential.user!.uid;

      // Create user model
      final userModel = UserModel(
        id: userId,
        name: name,
        email: encryption.encryptString(email),
        phone: encryption.encryptString(phone),
        upiId: encryption.encryptString(upiId),
        referrerId: referrerId,
        kycVerified: false,
        totalEarnings: 0.0,
        availableBalance: 0.0,
        withdrawnAmount: 0.0,
        createdAt: DateTime.now(),
      );
      // Save user to Firestore and local
      await firebaseDataSource.createUser(userModel);
      await localDataSource.saveUser(userModel);
      return userModel;
    } catch (e) {
      throw Exception("Registration failed: $e");
    }
  }

  @override
  Future<UserModel> loginUser(String email, String password) async {
    try {
      final userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      final userId = userCredential.user!.uid;
      final user = await firebaseDataSource.getUserById(userId);
      await localDataSource.saveUser(user);
      return user;
    } catch (e) {
      throw Exception("Login failed: $e");
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return null;
      return await firebaseDataSource.getUserById(currentUser.uid);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> logoutUser() async {
    try {
      await FirebaseAuth.instance.signOut();
      await localDataSource.clearAllCache();
    } catch (e) {
      throw Exception("Logout failed: $e");
    }
  }

  @override
  Future<void> updateUserProfile(
    String userId,
    Map<String, dynamic> data,
  ) async {
    try {
      await firebaseDataSource.updateUser(userId, data);
      final updatedUser = await firebaseDataSource.getUserById(userId);
      await localDataSource.saveUser(updatedUser);
    } catch (e) {
      throw Exception("Profile update failed: $e");
    }
  }

  @override
  Future<bool> isUserAuthenticated() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    return currentUser != null;
  }
}
