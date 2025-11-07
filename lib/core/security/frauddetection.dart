import 'package:device_info_plus/device_info_plus.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

class FraudDetectionService {
  static final FraudDetectionService instance =
      FraudDetectionService._internal();
  final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  late String deviceFingerprint;

  factory FraudDetectionService() {
    return instance;
  }

  FraudDetectionService._internal();

  // Generate device fingerprint (Android Example)
  Future<String> generateDeviceFingerprint() async {
    try {
      final androidInfo = await deviceInfo.androidInfo;
      String fingerprint = md5
          .convert(
            utf8.encode(
              androidInfo.device +
                  androidInfo.manufacturer +
                  androidInfo.serialNumber,
            ),
          )
          .toString();
      deviceFingerprint = fingerprint;
      return fingerprint;
    } catch (e) {
      throw Exception('Failed to generate device fingerprint: $e');
    }
  }

  String getDeviceFingerprint() => deviceFingerprint;

  // Suspicious activity detection
  bool detectSuspiciousActivity({
    required int transactionCount,
    required double totalAmount,
    required int timeFrameHours,
    required List<String> ipAddresses,
  }) {
    // Multiple large transactions in short time
    if (transactionCount > 5 && totalAmount > 50000 && timeFrameHours < 24)
      return true;
    // Multiple IPs
    if (ipAddresses.toSet().length > 3) return true;
    // Unusual pattern
    if (totalAmount > 100000 && transactionCount == 1) return true;
    return false;
  }

  // Validate referral chain
  bool validateReferralChain(List<String> referralChain) {
    final uniqueIds = referralChain.toSet();
    if (uniqueIds.length != referralChain.length) return false; // Circular ref
    if (referralChain.length > 5) return false; // Exceeds max levels
    return true;
  }

  // Velocity abuse - too many accounts from same device
  bool detectVelocityAbuse({
    required int accountsFromDevice,
    required int maxAllowed,
  }) {
    return accountsFromDevice > maxAllowed;
  }

  // Impossible geography - location rapid changes
  bool detectImpossibleGeography({
    required double lastLatitude,
    required double lastLongitude,
    required double currentLatitude,
    required double currentLongitude,
    required int timeElapsedSeconds,
  }) {
    const earthRadiusKm = 6371;
    double toRad(double deg) => deg * 3.141592653589793 / 180;
    final dLat = toRad(currentLatitude - lastLatitude);
    final dLon = toRad(currentLongitude - lastLongitude);
    final a =
        (sin(dLat / 2) * sin(dLat / 2)) +
        (cos(toRad(lastLatitude)) *
            cos(toRad(currentLatitude)) *
            sin(dLon / 2) *
            sin(dLon / 2));
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    final distance = earthRadiusKm * c;
    // Max possible speed ~900km/h (jet)
    final maxPossibleDistance = (timeElapsedSeconds / 3600) * 900;
    return distance > maxPossibleDistance;
  }

  // Validate UPI transaction
  bool validateUpiTransaction({
    required String upiId,
    required double amount,
    required String transactionId,
  }) {
    if (!RegExp(r'^[a-zA-Z0-9.\-_]+@[a-zA-Z]+$').hasMatch(upiId)) return false;
    if (amount < 100 || amount > 50000) return false;
    if (!RegExp(
      r'^[0-9a-fA-F]{8}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{12}$',
    ).hasMatch(transactionId))
      return false;
    return true;
  }

  // Risk score (0-100)
  int calculateRiskScore({
    required int newAccountAge,
    required int transactionCount,
    required double totalTransactionAmount,
    required bool isDeviceVerified,
    required bool isLocationConsistent,
    required bool isPhoneVerified,
  }) {
    int riskScore = 0;
    if (newAccountAge < 1)
      riskScore += 30;
    else if (newAccountAge < 7)
      riskScore += 15;
    else if (newAccountAge < 30)
      riskScore += 5;

    if (transactionCount > 10)
      riskScore += 25;
    else if (transactionCount > 5)
      riskScore += 15;

    if (totalTransactionAmount > 100000)
      riskScore += 20;
    else if (totalTransactionAmount > 50000)
      riskScore += 10;

    if (!isDeviceVerified) riskScore += 15;
    if (!isLocationConsistent) riskScore += 10;
    if (!isPhoneVerified) riskScore += 10;

    return riskScore.clamp(0, 100);
  }

  bool requiresAdditionalVerification(int riskScore) => riskScore > 50;
}
