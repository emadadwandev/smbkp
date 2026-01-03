import 'package:equatable/equatable.dart';
import '../../domain/entities/auth_result.dart';
import '../../domain/entities/user_entity.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

// Initial state
class AuthInitial extends AuthState {
  const AuthInitial();
}

// Loading state
class AuthLoading extends AuthState {
  const AuthLoading();
}

// Authenticated state
class Authenticated extends AuthState {
  final UserEntity user;
  final String? token;

  const Authenticated({
    required this.user,
    this.token,
  });

  @override
  List<Object?> get props => [user, token];
}

// Unauthenticated state
class Unauthenticated extends AuthState {
  const Unauthenticated();
}

// OTP sent successfully
class OtpSent extends AuthState {
  final String verificationId;
  final String phoneNumber;

  const OtpSent({
    required this.verificationId,
    required this.phoneNumber,
  });

  @override
  List<Object?> get props => [verificationId, phoneNumber];
}

// OTP verified successfully
class OtpVerified extends AuthState {
  final String phoneNumber;

  const OtpVerified({
    required this.phoneNumber,
  });

  @override
  List<Object?> get props => [phoneNumber];
}

// Registration successful
class RegistrationSuccess extends AuthState {
  final AuthResult authResult;

  const RegistrationSuccess({
    required this.authResult,
  });

  @override
  List<Object?> get props => [authResult];
}

// Registration successful but requires parental consent
class RegistrationPendingParentalConsent extends AuthState {
  final UserEntity user;
  final String parentEmail;
  final String parentalConsentId;

  const RegistrationPendingParentalConsent({
    required this.user,
    required this.parentEmail,
    required this.parentalConsentId,
  });

  @override
  List<Object?> get props => [user, parentEmail, parentalConsentId];
}

// Login successful
class LoginSuccess extends AuthState {
  final AuthResult authResult;

  const LoginSuccess({
    required this.authResult,
  });

  @override
  List<Object?> get props => [authResult];
}

// Logout successful
class LogoutSuccess extends AuthState {
  const LogoutSuccess();
}

// Error state
class AuthError extends AuthState {
  final String message;
  final String? errorCode;

  const AuthError({
    required this.message,
    this.errorCode,
  });

  @override
  List<Object?> get props => [message, errorCode];
}

// Validation error
class ValidationError extends AuthState {
  final String message;
  final Map<String, String>? fieldErrors;

  const ValidationError({
    required this.message,
    this.fieldErrors,
  });

  @override
  List<Object?> get props => [message, fieldErrors];
}
