import 'dart:io';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service to handle App Tracking Transparency (ATT) requests
/// Required by Apple App Store for iOS apps that track users
@lazySingleton
class TrackingService {
  final SharedPreferences _prefs;
  static const String _trackingRequestedKey = 'tracking_requested';
  static const String _trackingStatusKey = 'tracking_status';

  TrackingService(this._prefs);

  /// Request tracking permission from the user
  /// Should be called after user has had a chance to use the app
  /// Returns the tracking authorization status
  Future<TrackingStatus> requestTrackingAuthorization() async {
    // Only request on iOS
    if (!Platform.isIOS) {
      return TrackingStatus.notSupported;
    }

    try {
      // Check if we've already requested
      final hasRequested = _prefs.getBool(_trackingRequestedKey) ?? false;

      // Get current status
      final status = await AppTrackingTransparency.trackingAuthorizationStatus;

      // If not determined and we haven't asked yet, request permission
      if (status == TrackingStatus.notDetermined && !hasRequested) {
        final newStatus =
            await AppTrackingTransparency.requestTrackingAuthorization();

        // Mark as requested
        await _prefs.setBool(_trackingRequestedKey, true);
        await _prefs.setString(_trackingStatusKey, newStatus.toString());

        return newStatus;
      }

      return status;
    } catch (e) {
      print('Error requesting tracking authorization: $e');
      return TrackingStatus.notDetermined;
    }
  }

  /// Get the current tracking authorization status
  Future<TrackingStatus> getTrackingStatus() async {
    if (!Platform.isIOS) {
      return TrackingStatus.notSupported;
    }

    try {
      return await AppTrackingTransparency.trackingAuthorizationStatus;
    } catch (e) {
      print('Error getting tracking status: $e');
      return TrackingStatus.notDetermined;
    }
  }

  /// Check if tracking has been requested before
  bool hasRequestedTracking() {
    return _prefs.getBool(_trackingRequestedKey) ?? false;
  }

  /// Get the advertising identifier (IDFA)
  /// Only available if user has granted tracking permission
  Future<String?> getAdvertisingIdentifier() async {
    if (!Platform.isIOS) {
      return null;
    }

    try {
      final status = await getTrackingStatus();

      // Only get IDFA if authorized
      if (status == TrackingStatus.authorized) {
        return await AppTrackingTransparency.getAdvertisingIdentifier();
      }

      return null;
    } catch (e) {
      print('Error getting advertising identifier: $e');
      return null;
    }
  }

  /// Show a pre-permission dialog explaining why tracking is needed
  /// Call this before requesting actual permission
  /// Returns true if user wants to continue to permission request
  Future<bool> showPrePermissionDialog({
    required String title,
    required String message,
    required Function() onContinue,
  }) async {
    // This should be implemented in the UI layer
    // For now, just return true to continue
    return true;
  }

  /// Check if we should show the tracking request
  /// Based on app usage and whether it's been requested before
  Future<bool> shouldRequestTracking() async {
    if (!Platform.isIOS) {
      return false;
    }

    // Check if already requested
    if (hasRequestedTracking()) {
      return false;
    }

    // Check current status
    final status = await getTrackingStatus();

    // Only request if not determined
    return status == TrackingStatus.notDetermined;
  }
}
