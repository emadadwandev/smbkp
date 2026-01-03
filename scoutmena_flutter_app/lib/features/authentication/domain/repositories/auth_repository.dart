import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/auth_result.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  /// Send OTP to phone number via backend (Infobip)
  Future<Either<Failure, String>> sendOtp({
    required String phoneNumber,
    required String method, // 'sms' or 'whatsapp'
  });

  /// Verify OTP code
  Future<Either<Failure, bool>> verifyOtp({
    required String phoneNumber,
    required String otpCode,
    required String verificationId,
  });

  /// Register user with OTP (after verification)
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
  });

  /// Login with OTP
  Future<Either<Failure, AuthResult>> loginWithOtp({
    required String phoneNumber,
    required String otpCode,
    required String accountType,
  });

  /// Login with email and password
  Future<Either<Failure, AuthResult>> loginWithEmail({
    required String email,
    required String password,
  });

  /// Sign in with Firebase (social login)
  Future<Either<Failure, AuthResult>> signInWithFirebase({
    required String firebaseIdToken,
  });

  /// Get current authenticated user
  Future<Either<Failure, UserEntity>> getCurrentUser();

  /// Logout
  Future<Either<Failure, void>> logout();

  /// Check if user is authenticated
  Future<bool> isAuthenticated();

  /// Get stored auth token
  Future<String?> getAuthToken();

  /// Save auth token
  Future<void> saveAuthToken(String token);

  /// Clear auth data
  Future<void> clearAuthData();
}
