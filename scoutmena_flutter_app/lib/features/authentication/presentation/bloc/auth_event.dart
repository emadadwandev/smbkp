import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

// Check authentication status on app start
class CheckAuthStatusEvent extends AuthEvent {
  const CheckAuthStatusEvent();
}

// Send OTP
class SendOtpRequested extends AuthEvent {
  final String phoneNumber;
  final String method; // 'sms' or 'whatsapp'

  const SendOtpRequested({
    required this.phoneNumber,
    this.method = 'sms',
  });

  @override
  List<Object?> get props => [phoneNumber, method];
}

// Verify OTP
class VerifyOtpRequested extends AuthEvent {
  final String phoneNumber;
  final String otpCode;
  final String verificationId;

  const VerifyOtpRequested({
    required this.phoneNumber,
    required this.otpCode,
    required this.verificationId,
  });

  @override
  List<Object?> get props => [phoneNumber, otpCode, verificationId];
}

// Register with OTP
class RegisterWithOtpRequested extends AuthEvent {
  final String name;
  final String email;
  final String phone;
  final String password;
  final String dateOfBirth;
  final String accountType;
  final String country;
  final String gender;
  final String verificationId;
  final String? parentName;
  final String? parentEmail;
  final String? parentPhone;
  final String? parentRelationship;

  const RegisterWithOtpRequested({
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
    required this.dateOfBirth,
    required this.accountType,
    required this.country,
    required this.gender,
    required this.verificationId,
    this.parentName,
    this.parentEmail,
    this.parentPhone,
    this.parentRelationship,
  });

  @override
  List<Object?> get props => [
        name,
        email,
        phone,
        password,
        dateOfBirth,
        accountType,
        country,
        gender,
        verificationId,
        parentName,
        parentEmail,
        parentPhone,
        parentRelationship,
      ];
}

// Login with OTP
class LoginWithOtpRequested extends AuthEvent {
  final String phoneNumber;
  final String otpCode;
  final String accountType;

  const LoginWithOtpRequested({
    required this.phoneNumber,
    required this.otpCode,
    required this.accountType,
  });

  @override
  List<Object?> get props => [phoneNumber, otpCode, accountType];
}

// Login with email and password
class LoginWithEmailRequested extends AuthEvent {
  final String email;
  final String password;

  const LoginWithEmailRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

// Sign in with Firebase (social login)
class SignInWithFirebaseRequested extends AuthEvent {
  final String firebaseIdToken;

  const SignInWithFirebaseRequested({
    required this.firebaseIdToken,
  });

  @override
  List<Object?> get props => [firebaseIdToken];
}

// Logout
class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}

// Get current user
class GetCurrentUserRequested extends AuthEvent {
  const GetCurrentUserRequested();
}
