import 'dart:io';
import 'package:injectable/injectable.dart';
import '../repositories/coach_profile_repository.dart';

/// Use case: Upload coach verification documents
/// Uploads coach credentials for verification (license, certificates, etc.)
@injectable
class UploadCoachVerificationDocuments {
  final CoachProfileRepository repository;

  UploadCoachVerificationDocuments(this.repository);

  /// Execute the use case
  /// Validates documents and uploads to server for admin review
  Future<List<String>> call(List<File> documents) async {
    // Validate documents
    _validateDocuments(documents);

    try {
      return await repository.uploadVerificationDocuments(documents);
    } catch (e) {
      throw Exception('Failed to upload verification documents: $e');
    }
  }

  /// Validate documents before upload
  void _validateDocuments(List<File> documents) {
    final errors = <String>[];

    // Check minimum and maximum number of documents
    if (documents.isEmpty) {
      errors.add('At least one document is required');
    }

    if (documents.length > 5) {
      errors.add('Maximum 5 documents allowed');
    }

    // Validate each document
    for (final document in documents) {
      // Check if file exists
      if (!document.existsSync()) {
        errors.add('Document file does not exist: ${document.path}');
        continue;
      }

      // Check file size (max 10MB)
      final fileSizeInBytes = document.lengthSync();
      final fileSizeInMB = fileSizeInBytes / (1024 * 1024);
      if (fileSizeInMB > 10) {
        errors.add('Document size exceeds 10MB limit: ${document.path}');
      }

      // Check file extension
      final fileName = document.path.toLowerCase();
      final validExtensions = ['.pdf', '.jpg', '.jpeg', '.png'];
      final isValidExtension = validExtensions.any(
        (ext) => fileName.endsWith(ext),
      );

      if (!isValidExtension) {
        errors.add('Invalid document format: ${document.path}. Allowed: PDF, JPG, PNG');
      }
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
