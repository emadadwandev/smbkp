import 'package:injectable/injectable.dart';
import '../entities/coach_profile_entity.dart';
import '../repositories/coach_profile_repository.dart';

/// Use case: Create coach profile
/// Creates a new coach profile with validation
@injectable
class CreateCoachProfile {
  final CoachProfileRepository repository;

  CreateCoachProfile(this.repository);

  /// Execute the use case
  /// Validates input data and creates profile
  Future<CoachProfileEntity> call(Map<String, dynamic> profileData) async {
    // Validate required fields
    _validateProfileData(profileData);

    try {
      return await repository.createProfile(profileData);
    } catch (e) {
      throw Exception('Failed to create coach profile: $e');
    }
  }

  /// Validate profile data before creation
  void _validateProfileData(Map<String, dynamic> data) {
    final errors = <String>[];

    // Validate first name
    if (data['first_name'] == null || (data['first_name'] as String).isEmpty) {
      errors.add('First name is required');
    }

    // Validate last name
    if (data['last_name'] == null || (data['last_name'] as String).isEmpty) {
      errors.add('Last name is required');
    }

    // Validate club name
    if (data['club_name'] == null || (data['club_name'] as String).isEmpty) {
      errors.add('Club name is required');
    }

    // Validate current role
    if (data['current_role'] == null ||
        (data['current_role'] as String).isEmpty) {
      errors.add('Current role is required');
    }

    // Validate coaching license
    if (data['coaching_license'] == null ||
        (data['coaching_license'] as String).isEmpty) {
      errors.add('Coaching license is required');
    }

    // Validate years of experience
    if (data['years_of_experience'] == null) {
      errors.add('Years of experience is required');
    } else {
      final years = data['years_of_experience'] as int;
      if (years < 0 || years > 50) {
        errors.add('Years of experience must be between 0 and 50');
      }
    }

    // Validate country
    if (data['country'] == null || (data['country'] as String).isEmpty) {
      errors.add('Country is required');
    }

    // Validate bio (optional but length check)
    if (data['bio'] != null && (data['bio'] as String).length > 500) {
      errors.add('Bio must not exceed 500 characters');
    }

    // Validate email format (if provided)
    if (data['contact_email'] != null) {
      final email = data['contact_email'] as String;
      if (email.isNotEmpty && !_isValidEmail(email)) {
        errors.add('Invalid email format');
      }
    }

    // Validate phone format (if provided)
    if (data['contact_phone'] != null) {
      final phone = data['contact_phone'] as String;
      if (phone.isNotEmpty && phone.length < 10) {
        errors.add('Invalid phone number format');
      }
    }

    if (errors.isNotEmpty) {
      throw ValidationException(errors.join(', '));
    }
  }

  /// Validate email format
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }
}

/// Custom exception for validation errors
class ValidationException implements Exception {
  final String message;
  ValidationException(this.message);

  @override
  String toString() => message;
}
