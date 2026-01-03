import 'package:injectable/injectable.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../network/api_client.dart';
import '../constants/api_constants.dart';
import '../constants/app_constants.dart';

@lazySingleton
class AuthService {
  final ApiClient _apiClient;
  final FlutterSecureStorage _secureStorage;

  AuthService(this._apiClient, this._secureStorage);

  /// Get current authenticated user
  /// Backend endpoint: GET /api/v1/auth/me
  Future<CurrentUserResponse> getCurrentUser() async {
    try {
      final response = await _apiClient.get(ApiConstants.me);
      // The user data is nested inside the 'user' key within the 'data' object
      final userData = response.data['data']['user'];
      return CurrentUserResponse.fromJson(userData);
    } catch (e) {
      throw Exception('Failed to get current user: $e');
    }
  }

  /// Logout user
  /// Backend endpoint: POST /api/v1/auth/logout
  Future<void> logout() async {
    try {
      // Call backend logout endpoint
      await _apiClient.post(ApiConstants.logout);
      
      // Clear all local auth data
      await _clearLocalAuthData();
    } catch (e) {
      // Even if backend call fails, clear local data
      await _clearLocalAuthData();
      throw Exception('Failed to logout: $e');
    }
  }

  /// Clear all authentication data from local storage
  Future<void> _clearLocalAuthData() async {
    await _secureStorage.delete(key: AppConstants.accessTokenKey);
    await _secureStorage.delete(key: AppConstants.refreshTokenKey);
    await _secureStorage.delete(key: AppConstants.userIdKey);
    await _secureStorage.delete(key: AppConstants.userRoleKey);
    await _secureStorage.delete(key: 'otp_verification_id');
    await _secureStorage.delete(key: 'firebase_token');
  }

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final token = await _secureStorage.read(key: AppConstants.accessTokenKey);
    return token != null && token.isNotEmpty;
  }

  /// Get stored auth token
  Future<String?> getAuthToken() async {
    return await _secureStorage.read(key: AppConstants.accessTokenKey);
  }

  /// Get stored user role
  Future<String?> getUserRole() async {
    return await _secureStorage.read(key: AppConstants.userRoleKey);
  }

  /// Get stored user ID
  Future<String?> getUserId() async {
    return await _secureStorage.read(key: AppConstants.userIdKey);
  }
}

// Response Models
class CurrentUserResponse {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String accountType;
  final bool? hasCompletedProfile;
  final bool? requiresParentalConsent;
  final bool? isMinor;
  final bool? isActive;
  final bool? isVerified;
  final String? dateOfBirth;
  final String? country;
  final ParentalConsentStatus? parentalConsentStatus;

  CurrentUserResponse({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.accountType,
    this.hasCompletedProfile,
    this.requiresParentalConsent,
    this.isMinor,
    this.isActive,
    this.isVerified,
    this.dateOfBirth,
    this.country,
    this.parentalConsentStatus,
  });

  factory CurrentUserResponse.fromJson(Map<String, dynamic> json) {
    return CurrentUserResponse(
      id: json['id'].toString(),
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      accountType: json['account_type'] as String,
      hasCompletedProfile: json['has_completed_profile'] as bool?,
      requiresParentalConsent: json['requires_parental_consent'] as bool?,
      isMinor: json['is_minor'] as bool?,
      isActive: json['is_active'] as bool?,
      isVerified: json['is_verified'] as bool?,
      dateOfBirth: json['date_of_birth'] as String?,
      country: json['country'] as String?,
      parentalConsentStatus: json['parental_consent_status'] != null
          ? ParentalConsentStatus.fromJson(json['parental_consent_status'])
          : null,
    );
  }
}

class ParentalConsentStatus {
  final String status; // pending, approved, rejected
  final String? parentEmail;

  ParentalConsentStatus({
    required this.status,
    this.parentEmail,
  });

  factory ParentalConsentStatus.fromJson(Map<String, dynamic> json) {
    return ParentalConsentStatus(
      status: json['status'] as String,
      parentEmail: json['parent_email'] as String?,
    );
  }
}
