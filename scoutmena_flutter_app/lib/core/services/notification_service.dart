import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:injectable/injectable.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../network/api_client.dart';
import '../constants/api_constants.dart';
import '../constants/app_constants.dart';

@lazySingleton
class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final ApiClient _apiClient;
  final FlutterSecureStorage _secureStorage;

  NotificationService(this._apiClient, this._secureStorage);

  Future<void> registerDevice({String? authToken}) async {
    try {
      // Check if we have a token (either passed or in storage)
      final tokenToUse = authToken ?? await _secureStorage.read(key: AppConstants.accessTokenKey);
      
      if (tokenToUse == null) {
        print('⚠️ Skipping device registration: No auth token available');
        return;
      }

      // 1. Get FCM Token
      final token = await _messaging.getToken();
      if (token == null) {
        print('⚠️ FCM Token is null');
        return;
      }
      print('🔥 FCM Token: $token');

      // 2. Get Device Info
      final deviceInfo = DeviceInfoPlugin();
      String? deviceName;
      String? deviceModel;
      String? osVersion;
      String platform = Platform.isIOS ? 'ios' : 'android';

      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        deviceName = androidInfo.brand;
        deviceModel = androidInfo.model;
        osVersion = androidInfo.version.release;
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        deviceName = iosInfo.name;
        deviceModel = iosInfo.model;
        osVersion = iosInfo.systemVersion;
      }

      // 3. Get App Version
      final packageInfo = await PackageInfo.fromPlatform();
      final appVersion = packageInfo.version;

      print('DEBUG: Registering device with authToken: ${authToken != null ? "PROVIDED" : "FROM STORAGE"}');

      // 4. Register with Backend
      await _apiClient.post(
        ApiConstants.deviceRegister,
        data: {
          'device_token': token,
          'platform': platform,
          'device_name': deviceName,
          'device_model': deviceModel,
          'os_version': osVersion,
          'app_version': appVersion,
        },
        options: Options(headers: {'Authorization': 'Bearer $tokenToUse'}),
      );
      print('✅ Device registered with backend');
    } catch (e) {
      print('⚠️ Failed to register device: $e');
    }
  }
  
  Future<void> unregisterDevice() async {
     try {
      final token = await _messaging.getToken();
      if (token == null) return;

      await _apiClient.delete(
        ApiConstants.deviceUnregister,
        data: {
          'device_token': token,
        },
      );
      print('✅ Device unregistered from backend');
    } catch (e) {
      print('⚠️ Failed to unregister device: $e');
    }
  }
}
