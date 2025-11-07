import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BackgroundServiceManager {
  static const platform = MethodChannel('com.sharenetear.app/background');

  Future<void> initializeBackgroundService() async {
    final service = FlutterBackgroundService();
    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        isForegroundMode: true,
      ),
      iosConfiguration: IosConfiguration(
        onForeground: onStart,
        onBackground: onIosBackground,
      ),
    );
    service.startService();
  }

  @pragma('vm:entry-point')
  static void onStart(ServiceInstance service) async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    if (service is AndroidServiceInstance) {
      service
          .on('setAsForeground')
          .listen((event) => service.setAsForegroundService());
      service
          .on('setAsBackground')
          .listen((event) => service.setAsBackgroundService());
      service.on('stopService').listen((event) => service.stopSelf());
    }
    // Simulate WiFi earning update every 5 minutes
    Future.doWhile(() async {
      await updateHotspotEarnings();
      await Future.delayed(const Duration(minutes: 5));
      return true;
    });
  }

  @pragma('vm:entry-point')
  static Future<bool> onIosBackground(ServiceInstance service) async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    await updateHotspotEarnings();
    return true;
  }

  static Future<void> updateHotspotEarnings() async {
    try {
      final firestore = FirebaseFirestore.instance;
      // NOTE: In production, get userId from secure storage
      const userId = 'currentUserId';
      await firestore.collection('users').doc(userId).update({
        'availableBalance': FieldValue.increment(0.5),
      });
      print('Background earning updated');
    } catch (e) {
      print('Background service error: $e');
    }
  }

  Future<void> stopBackgroundService() async {
    final service = FlutterBackgroundService();
    await service.invoke('stopService');
  }
}
