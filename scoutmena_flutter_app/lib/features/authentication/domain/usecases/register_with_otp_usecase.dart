import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/auth_result.dart';
import '../repositories/auth_repository.dart';

class RegisterWithOtpUseCase {
  final AuthRepository repository;

  RegisterWithOtpUseCase(this.repository);

  Future<Either<Failure, AuthResult>> call({
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
    // Validate required fields
    final validation = _validateInputs(
      name: name,
      email: email,
      phone: phone,
      password: password,
      dateOfBirth: dateOfBirth,
      accountType: accountType,
      country: country,
    );

    if (validation != null) {
      return Left(validation);
    }

    // Calculate age to check if minor
    final age = _calculateAge(DateTime.parse(dateOfBirth));
    final isMinor = age < 16;

    // If minor, validate parental information
    if (isMinor) {
      if (parentName == null || parentName.isEmpty) {
        return const Left(ValidationFailure('Parent/Guardian name is required for minors'));
      }
      if (parentEmail == null || parentEmail.isEmpty) {
        return const Left(ValidationFailure('Parent/Guardian email is required for minors'));
      }
      if (!_isValidEmail(parentEmail)) {
        return const Left(ValidationFailure('Invalid parent/guardian email format'));
      }
    }

    return await repository.registerWithOtp(
      name: name,
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
  }

  ValidationFailure? _validateInputs({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String dateOfBirth,
    required String accountType,
    required String country,
  }) {
    if (name.isEmpty) {
      return const ValidationFailure('Name is required');
    }

    if (email.isEmpty) {
      return const ValidationFailure('Email is required');
    }

    if (!_isValidEmail(email)) {
      return const ValidationFailure('Invalid email format');
    }

    if (phone.isEmpty) {
      return const ValidationFailure('Phone number is required');
    }

    if (password.isEmpty) {
      return const ValidationFailure('Password is required');
    }

    if (password.length < 8) {
      return const ValidationFailure('Password must be at least 6 characters');
    }

    if (dateOfBirth.isEmpty) {
      return const ValidationFailure('Date of birth is required');
    }

    if (country.isEmpty) {
      return const ValidationFailure('Country is required');
    }

    final validAccountTypes = ['player', 'scout', 'coach', 'academy'];
    if (!validAccountTypes.contains(accountType)) {
      return const ValidationFailure('Invalid account type');
    }

    return null;
  }

  bool _isValidEmail(String email) {
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return regex.hasMatch(email);
  }

  int _calculateAge(DateTime birthDate) {
    final today = DateTime.now();
    int age = today.year - birthDate.year;
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age;
  }
}
