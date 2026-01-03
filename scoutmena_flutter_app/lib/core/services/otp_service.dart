import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'dart:io';
import '../network/api_client.dart';
import '../constants/api_constants.dart';

@lazySingleton
class OtpService {
  final ApiClient _apiClient;

  OtpService(this._apiClient);

  /// Send OTP via SMS using Infobip (through backend)
  /// Backend endpoint: POST /api/v1/auth/send-otp
  Future<OtpResponse> sendOtp({
    required String phoneNumber,
    String method = 'sms', // 'sms' or 'whatsapp'
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.sendOtp,
        data: {
          'phone': phoneNumber,
          'method': method,
        },
      );

      return OtpResponse.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to send OTP: $e');
    }
  }

  /// Verify OTP code
  /// Backend endpoint: POST /api/v1/auth/verify-otp
  Future<OtpVerificationResponse> verifyOtp({
    required String phoneNumber,
    required String otpCode,
    required String verificationId,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.verifyOtp,
        data: {
          'phone': phoneNumber,
          'otp': otpCode,
          'verification_id': verificationId,
        },
      );

      return OtpVerificationResponse.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to verify OTP: $e');
    }
  }

  /// Register with OTP (without Firebase)
  /// Backend endpoint: POST /api/v1/auth/register-with-otp
  Future<RegistrationResponse> registerWithOtp({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
    required String dateOfBirth,
    required String gender,
    required String accountType,
    required String country,
    required String verificationId,
    String? parentName,
    String? parentEmail,
    String? parentPhone,
    String? parentRelationship,
  }) async {
    try {
      final data = {
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'phone': phone,
        'password': password,
        'date_of_birth': dateOfBirth,
        'gender': gender,
        'account_type': accountType,
        'country': country,
        'verification_id': verificationId,
      };

      // Add parental info if provided (for minors)
      if (parentName != null) {
        data['parent_name'] = parentName;
      }
      if (parentEmail != null) {
        data['parent_email'] = parentEmail;
      }
      if (parentPhone != null) {
        data['parent_phone'] = parentPhone;
      }
      if (parentRelationship != null) {
        data['parent_relationship'] = parentRelationship;
      }

      final response = await _apiClient.post(
        ApiConstants.registerWithOtp,
        data: data,
      );

      return RegistrationResponse.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to register: $e');
    }
  }

  /// Login with OTP (without Firebase)
  /// Backend endpoint: POST /api/v1/auth/login-with-otp
  /// Note: OTP must be verified first using verifyOtp()
  Future<LoginResponse> loginWithOtp({
    required String phone,
    required String verificationId,
    required String accountType,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.loginWithOtp,
        data: {
          'phone': phone,
          'verification_id': verificationId,
          'account_type': accountType,
        },
      );

      return LoginResponse.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to login: $e');
    }
  }

  /// Login with Email and Password
  /// Backend endpoint: POST /api/v1/auth/login
  Future<LoginResponse> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.login,
        data: {
          'email': email,
          'password': password,
        },
      );

      return LoginResponse.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to login: $e');
    }
  }

  /// Send forgot password email
  /// Backend endpoint: POST /api/v1/auth/forgot-password
  Future<ForgotPasswordResponse> sendForgotPasswordEmail({
    required String email,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.forgotPassword,
        data: {
          'email': email,
        },
      );

      return ForgotPasswordResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to send reset email: $e');
    }
  }

  /// Upload verification documents for scout/coach registration
  /// Backend endpoint: POST /api/v1/auth/upload-verification-documents
  Future<VerificationDocumentsResponse> uploadVerificationDocuments({
    required String userId,
    required String accountType,
    required String identityDocumentType,
    File? nationalId,
    File? passport,
    required List<File> professionalCertificates,
  }) async {
    try {
      // Create FormData for multipart file upload
      final formData = FormData.fromMap({
        'user_id': userId,
        'account_type': accountType,
        'identity_document_type': identityDocumentType,
      });

      // Add national ID if provided
      if (nationalId != null) {
        formData.files.add(MapEntry(
          'national_id',
          await MultipartFile.fromFile(
            nationalId.path,
            filename: nationalId.path.split('/').last,
          ),
        ));
      }

      // Add passport if provided
      if (passport != null) {
        formData.files.add(MapEntry(
          'passport',
          await MultipartFile.fromFile(
            passport.path,
            filename: passport.path.split('/').last,
          ),
        ));
      }

      // Add professional certificates
      for (int i = 0; i < professionalCertificates.length; i++) {
        final certificate = professionalCertificates[i];
        formData.files.add(MapEntry(
          'professional_certificates[$i]',
          await MultipartFile.fromFile(
            certificate.path,
            filename: certificate.path.split('/').last,
          ),
        ));
      }

      final response = await _apiClient.post(
        ApiConstants.uploadVerificationDocuments,
        data: formData,
      );

      return VerificationDocumentsResponse.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to upload verification documents: $e');
    }
  }
}

// Response Models
class OtpResponse {
  final String verificationId;
  final DateTime expiresAt;

  OtpResponse({
    required this.verificationId,
    required this.expiresAt,
  });

  factory OtpResponse.fromJson(Map<String, dynamic> json) {
    return OtpResponse(
      verificationId: json['verification_id'] as String,
      expiresAt: DateTime.parse(json['expires_at'] as String),
    );
  }
}

class OtpVerificationResponse {
  final bool verified;
  final String phone;

  OtpVerificationResponse({
    required this.verified,
    required this.phone,
  });

  factory OtpVerificationResponse.fromJson(Map<String, dynamic> json) {
    return OtpVerificationResponse(
      verified: json['verified'] as bool,
      phone: json['phone'] as String,
    );
  }
}

class RegistrationResponse {
  final UserData? user;
  final bool requiresParentalConsent;
  final ParentalConsentData? parentalConsent;
  final String? token;
  final String? userId;
  final String? parentalConsentId;
  final bool accountLocked;

  RegistrationResponse({
    this.user,
    required this.requiresParentalConsent,
    this.parentalConsent,
    this.token,
    this.userId,
    this.parentalConsentId,
    this.accountLocked = false,
  });

  factory RegistrationResponse.fromJson(Map<String, dynamic> json) {
    return RegistrationResponse(
      user: json['user'] != null ? UserData.fromJson(json['user'] as Map<String, dynamic>) : null,
      requiresParentalConsent: json['requires_parental_consent'] as bool? ?? false,
      parentalConsent: json['parental_consent'] != null
          ? ParentalConsentData.fromJson(json['parental_consent'] as Map<String, dynamic>)
          : null,
      token: json['token'] as String?,
      userId: json['user_id']?.toString(),
      parentalConsentId: json['parental_consent_id']?.toString(),
      accountLocked: json['account_locked'] as bool? ?? false,
    );
  }
}

class LoginResponse {
  final UserData user;
  final String token;

  LoginResponse({
    required this.user,
    required this.token,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      user: UserData.fromJson(json['user'] as Map<String, dynamic>),
      token: json['token'] as String,
    );
  }
}

class UserData {
  final String id;
  final String name;
  final String email;
  final String accountType;
  final int? age;
  final bool? isMinor;

  UserData({
    required this.id,
    required this.name,
    required this.email,
    required this.accountType,
    this.age,
    this.isMinor,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['id'].toString(), // Backend returns int ID, convert to String for consistency
      name: json['name'] as String,
      email: json['email'] as String,
      accountType: json['account_type'] as String,
      age: json['age'] as int?,
      isMinor: json['is_minor'] as bool?,
    );
  }
}

class ParentalConsentData {
  final String id;
  final String status;
  final String parentEmail;
  final DateTime consentRequestedAt;

  ParentalConsentData({
    required this.id,
    required this.status,
    required this.parentEmail,
    required this.consentRequestedAt,
  });

  factory ParentalConsentData.fromJson(Map<String, dynamic> json) {
    return ParentalConsentData(
      id: json['id'].toString(), // Backend may return int, convert to String
      status: json['status'] as String,
      parentEmail: json['parent_email'] as String,
      consentRequestedAt: DateTime.parse(json['consent_requested_at'] as String),
    );
  }
}

class ForgotPasswordResponse {
  final bool success;
  final String message;

  ForgotPasswordResponse({
    required this.success,
    required this.message,
  });

  factory ForgotPasswordResponse.fromJson(Map<String, dynamic> json) {
    return ForgotPasswordResponse(
      success: json['success'] as bool? ?? true,
      message: json['message'] as String,
    );
  }
}

class VerificationDocumentsResponse {
  final bool documentsUploaded;
  final String accountStatus;

  VerificationDocumentsResponse({
    required this.documentsUploaded,
    required this.accountStatus,
  });

  factory VerificationDocumentsResponse.fromJson(Map<String, dynamic> json) {
    return VerificationDocumentsResponse(
      documentsUploaded: json['documents_uploaded'] as bool,
      accountStatus: json['account_status'] as String,
    );
  }
}
