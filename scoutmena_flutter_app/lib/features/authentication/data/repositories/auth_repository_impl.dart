import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/services/otp_service.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/api_constants.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/entities/auth_result.dart';
import '../../domain/entities/user_entity.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final OtpService _otpService;
  final FlutterSecureStorage _secureStorage;
  final AuthService _authService;
  final ApiClient _apiClient;

  static const String _firebaseTokenKey = 'firebase_token';

  AuthRepositoryImpl(
    this._otpService,
    this._secureStorage,
    this._authService,
    this._apiClient,
  );

  @override
  Future<Either<Failure, String>> sendOtp({
    required String phoneNumber,
    required String method,
  }) async {
    try {
      final response = await _otpService.sendOtp(
        phoneNumber: phoneNumber,
        method: method,
      );
      return Right(response.verificationId);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> verifyOtp({
    required String phoneNumber,
    required String otpCode,
    required String verificationId,
  }) async {
    try {
      final response = await _otpService.verifyOtp(
        phoneNumber: phoneNumber,
        otpCode: otpCode,
        verificationId: verificationId,
      );
      return Right(response.verified);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthResult>> registerWithOtp({
    required String name,
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
      // Split name into first and last name
      final nameParts = name.trim().split(' ');
      final firstName = nameParts.isNotEmpty ? nameParts.first : '';
      final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

      final response = await _otpService.registerWithOtp(
        firstName: firstName,
        lastName: lastName,
        email: email,
        phone: phone,
        password: password,
        dateOfBirth: dateOfBirth,
        gender: gender,
        accountType: accountType,
        country: country,
        verificationId: verificationId,
        parentName: parentName,
        parentEmail: parentEmail,
        parentPhone: parentPhone,
        parentRelationship: parentRelationship,
      );

      UserEntity user;
      if (response.user != null) {
        user = _mapUserDataToEntity(response.user!);
      } else {
        user = UserEntity(
          id: response.userId ?? '',
          name: '$firstName $lastName'.trim(),
          email: email,
          accountType: accountType,
          isMinor: response.requiresParentalConsent,
          requiresParentalConsent: response.requiresParentalConsent,
          isActive: !response.accountLocked,
          isVerified: false,
        );
      }

      final authResult = AuthResult(
        user: user,
        token: response.token,
        requiresParentalConsent: response.requiresParentalConsent,
        parentalConsentId: response.parentalConsent?.id,
        parentEmail: response.parentalConsent?.parentEmail,
      );

      return Right(authResult);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthResult>> loginWithOtp({
    required String phoneNumber,
    required String otpCode,
    required String accountType,
  }) async {
    try {
      // Verify OTP first - get verification ID from secure storage
      final verificationId = await _secureStorage.read(key: 'otp_verification_id');
      
      if (verificationId == null) {
        return Left(ValidationFailure('No verification ID found. Please request OTP first.'));
      }

      // First verify the OTP
      await _otpService.verifyOtp(
        phoneNumber: phoneNumber,
        otpCode: otpCode,
        verificationId: verificationId,
      );

      // Then login
      final response = await _otpService.loginWithOtp(
        phone: phoneNumber,
        verificationId: verificationId,
        accountType: accountType,
      );

      final user = _mapUserDataToEntity(response.user);
      final authResult = AuthResult(
        user: user,
        token: response.token,
        requiresParentalConsent: false,
      );

      return Right(authResult);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthResult>> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _otpService.loginWithEmail(
        email: email,
        password: password,
      );

      final user = _mapUserDataToEntity(response.user);
      final authResult = AuthResult(
        user: user,
        token: response.token,
        requiresParentalConsent: false,
      );

      return Right(authResult);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthResult>> signInWithFirebase({
    required String firebaseIdToken,
  }) async {
    try {
      // Send Firebase ID token to backend for verification
      final response = await _apiClient.post(
        ApiConstants.firebaseLogin,
        data: {
          'firebase_token': firebaseIdToken,
        },
      );

      final userData = response.data['data']['user'];
      final token = response.data['data']['token'] as String?;

      final user = UserEntity(
        id: userData['id'].toString(),
        name: userData['name'] as String,
        email: userData['email'] as String,
        accountType: userData['account_type'] as String,
        isMinor: userData['is_minor'] as bool? ?? false,
        requiresParentalConsent: userData['requires_parental_consent'] as bool? ?? false,
        isActive: userData['is_active'] as bool? ?? true,
        isVerified: userData['is_verified'] as bool? ?? false,
      );

      // Store Firebase token
      await _secureStorage.write(key: _firebaseTokenKey, value: firebaseIdToken);
      
      // Store auth token if provided
      if (token != null) {
        await saveAuthToken(token);
        await _secureStorage.write(key: AppConstants.userIdKey, value: user.id);
        await _secureStorage.write(key: AppConstants.userRoleKey, value: user.accountType);
      }

      final authResult = AuthResult(
        user: user,
        token: token,
        requiresParentalConsent: user.requiresParentalConsent,
      );

      return Right(authResult);
    } catch (e) {
      return Left(ServerFailure('Firebase authentication failed: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> getCurrentUser() async {
    try {
      final token = await _secureStorage.read(key: AppConstants.accessTokenKey);
      
      if (token == null) {
        return Left(AuthenticationFailure('No authentication token found'));
      }

      // Fetch current user from backend
      final response = await _authService.getCurrentUser();
      
      final user = UserEntity(
        id: response.id,
        name: response.name,
        email: response.email,
        phone: response.phone,
        accountType: response.accountType,
        isMinor: response.isMinor ?? false,
        requiresParentalConsent: response.requiresParentalConsent ?? false,
        isActive: response.isActive ?? true,
        isVerified: response.isVerified ?? false,
        dateOfBirth: response.dateOfBirth,
        country: response.country,
      );

      return Right(user);
    } catch (e) {
      return Left(ServerFailure('Failed to get current user: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Unit>> logout() async {
    try {
      await clearAuthData();
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    try {
      final token = await _secureStorage.read(key: AppConstants.accessTokenKey);
      return token != null && token.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<String?> getAuthToken() async {
    try {
      return await _secureStorage.read(key: AppConstants.accessTokenKey);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> saveAuthToken(String token) async {
    try {
      await _secureStorage.write(key: AppConstants.accessTokenKey, value: token);
    } catch (e) {
      // Log error
      rethrow;
    }
  }

  @override
  Future<void> clearAuthData() async {
    try {
      await _secureStorage.delete(key: AppConstants.accessTokenKey);
      await _secureStorage.delete(key: _firebaseTokenKey);
      await _secureStorage.delete(key: 'otp_verification_id');
    } catch (e) {
      // Log error
      rethrow;
    }
  }

  /// Helper method to map OtpService UserData to domain UserEntity
  UserEntity _mapUserDataToEntity(UserData userData) {
    return UserEntity(
      id: userData.id,
      name: userData.name,
      email: userData.email,
      accountType: userData.accountType,
      isMinor: userData.isMinor ?? false,
      requiresParentalConsent: userData.isMinor ?? false,
      isActive: true,
      isVerified: false,
    );
  }
}
