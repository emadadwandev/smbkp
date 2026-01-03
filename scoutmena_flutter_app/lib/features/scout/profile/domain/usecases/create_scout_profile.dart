import 'package:injectable/injectable.dart';
import '../entities/scout_profile_entity.dart';
import '../repositories/scout_profile_repository.dart';

/// Use case: Create scout profile
/// Creates a new scout profile with validation
@injectable
class CreateScoutProfile {
  final ScoutProfileRepository repository;

  CreateScoutProfile(this.repository);

  /// Execute the use case
  /// Validates input data and creates profile
  /// Throws exception if validation fails or profile already exists
  Future<ScoutProfileEntity> call(Map<String, dynamic> profileData) async {
    // Validate required fields
    _validateProfileData(profileData);

    try {
      return await repository.createProfile(profileData);
    } catch (e) {
      throw Exception('Failed to create scout profile: $e');
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

    // Validate country
    if (data['country'] == null || (data['country'] as String).isEmpty) {
      errors.add('Country is required');
    }

    // Validate bio (optional but recommended)
    if (data['bio'] != null && (data['bio'] as String).length > 500) {
      errors.add('Bio must not exceed 500 characters');
    }

    // Validate specializations (if provided)
    if (data['specializations'] != null) {
      final specs = data['specializations'] as List;
      if (specs.isEmpty) {
        errors.add('At least one specialization is recommended');
      }
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
