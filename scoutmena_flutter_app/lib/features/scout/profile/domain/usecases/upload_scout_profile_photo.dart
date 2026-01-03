import 'dart:io';
import 'package:injectable/injectable.dart';
import '../entities/scout_profile_entity.dart';
import '../repositories/scout_profile_repository.dart';

/// Use case: Upload profile photo
/// Uploads or updates scout profile photo
@injectable
class UploadScoutProfilePhoto {
  final ScoutProfileRepository repository;

  UploadScoutProfilePhoto(this.repository);

  /// Execute the use case
  /// Validates photo file and uploads to server
  /// Returns updated profile with new photo URL
  Future<ScoutProfileEntity> call(File photo) async {
    // Validate photo
    _validatePhoto(photo);

    try {
      return await repository.uploadProfilePhoto(photo);
    } catch (e) {
      throw Exception('Failed to upload profile photo: $e');
    }
  }

  /// Validate photo file before upload
  void _validatePhoto(File photo) {
    final errors = <String>[];

    // Check if file exists
    if (!photo.existsSync()) {
      errors.add('Photo file does not exist');
    }

    // Check file size (max 5MB)
    final fileSizeInBytes = photo.lengthSync();
    final fileSizeInMB = fileSizeInBytes / (1024 * 1024);
    if (fileSizeInMB > 5) {
      errors.add('Photo size exceeds 5MB limit');
    }

    // Check file extension
    final fileName = photo.path.toLowerCase();
    final validExtensions = ['.jpg', '.jpeg', '.png'];
    final isValidExtension = validExtensions.any(
      (ext) => fileName.endsWith(ext),
    );

    if (!isValidExtension) {
      errors.add('Invalid photo format. Allowed: JPG, PNG');
    }

    if (errors.isNotEmpty) {
      throw ValidationException(errors.join(', '));
    }
  }
}

/// Custom exception for validation errors
class ValidationException implements Exception {
  final String message;
  ValidationException(this.message);

  @override
  String toString() => message;
}
