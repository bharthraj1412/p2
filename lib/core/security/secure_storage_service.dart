import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'encryption_service.dart';

class SecureStorageService {
  static final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  static Future<void> saveAuthToken(String token) async {
    await _secureStorage.write(
      key: 'auth_token',
      value: EncryptionService.encryptData(token),
    );
  }

  static Future<String?> getAuthToken() async {
    final encrypted = await _secureStorage.read(key: 'auth_token');
    if (encrypted == null) return null;
    return EncryptionService.decryptData(encrypted);
  }

  static Future<void> saveRefreshToken(String token) async {
    await _secureStorage.write(
      key: 'refresh_token',
      value: EncryptionService.encryptData(token),
    );
  }

  static Future<String?> getRefreshToken() async {
    final encrypted = await _secureStorage.read(key: 'refresh_token');
    if (encrypted == null) return null;
    return EncryptionService.decryptData(encrypted);
  }

  static Future<void> saveUserId(String userId) async {
    await _secureStorage.write(
      key: 'user_id',
      value: EncryptionService.encryptData(userId),
    );
  }

  static Future<String?> getUserId() async {
    final encrypted = await _secureStorage.read(key: 'user_id');
    if (encrypted == null) return null;
    return EncryptionService.decryptData(encrypted);
  }

  static Future<void> clearAll() async {
    await _secureStorage.deleteAll();
  }
}
