import 'package:injectable/injectable.dart';
import '../entities/scout_profile_entity.dart';
import '../repositories/scout_profile_repository.dart';

/// Use case: Update scout profile
/// Updates existing scout profile with validation
@injectable
class UpdateScoutProfile {
  final ScoutProfileRepository repository;

  UpdateScoutProfile(this.repository);

  /// Execute the use case
  /// Validates input data and updates profile
  /// Throws exception if validation fails or profile doesn't exist
  Future<ScoutProfileEntity> call(Map<String, dynamic> profileData) async {
    // Validate data if provided
    _validateProfileData(profileData);

    try {
      return await repository.updateProfile(profileData);
    } catch (e) {
      throw Exception('Failed to update scout profile: $e');
    }
  }

  /// Validate profile data before update
  /// Only validates fields that are being updated
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

    // Validate country if provided
    if (data.containsKey('country') && (data['country'] as String).isEmpty) {
      errors.add('Country cannot be empty');
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

    // Validate phone format if provided
    if (data.containsKey('contact_phone')) {
      final phone = data['contact_phone'] as String?;
      if (phone != null && phone.isNotEmpty && phone.length < 10) {
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
