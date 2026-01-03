import 'package:injectable/injectable.dart';
import '../entities/coach_profile_entity.dart';
import '../repositories/coach_profile_repository.dart';

/// Use case: Update coach profile
/// Updates existing coach profile with validation
@injectable
class UpdateCoachProfile {
  final CoachProfileRepository repository;

  UpdateCoachProfile(this.repository);

  /// Execute the use case
  /// Validates input data and updates profile
  Future<CoachProfileEntity> call(Map<String, dynamic> profileData) async {
    // Validate data if provided
    _validateProfileData(profileData);

    try {
      return await repository.updateProfile(profileData);
    } catch (e) {
      throw Exception('Failed to update coach profile: $e');
    }
  }

  /// Validate profile data before update
  void _validateProfileData(Map<String, dynamic> data) {
    final errors = <String>[];

    // Validate first name if provided
    if (data.containsKey('first_name') &&
        (data['first_name'] as String).isEmpty) {
      errors.add('First name cannot be empty');
    }

    // Validate last name if provided
    if (data.containsKey('last_name') &&
        (data['last_name'] as String).isEmpty) {
      errors.add('Last name cannot be empty');
    }

    // Validate club name if provided
    if (data.containsKey('club_name') &&
        (data['club_name'] as String).isEmpty) {
      errors.add('Club name cannot be empty');
    }

    // Validate years of experience if provided
    if (data.containsKey('years_of_experience')) {
      final years = data['years_of_experience'] as int;
      if (years < 0 || years > 50) {
        errors.add('Years of experience must be between 0 and 50');
      }
    }

    // Validate bio length if provided
    if (data.containsKey('bio') && (data['bio'] as String).length > 500) {
      errors.add('Bio must not exceed 500 characters');
    }

    // Validate email format if provided
    if (data.containsKey('contact_email')) {
      final email = data['contact_email'] as String?;
      if (email != null && email.isNotEmpty && !_isValidEmail(email)) {
        errors.add('Invalid email format');
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
