import 'dart:io';
import 'package:injectable/injectable.dart';
import '../repositories/scout_profile_repository.dart';

/// Use case: Upload verification documents
/// Uploads documents to prove scout credentials during registration
@injectable
class UploadVerificationDocuments {
  final ScoutProfileRepository repository;

  UploadVerificationDocuments(this.repository);

  /// Execute the use case
  /// Validates files and uploads to server
  /// Returns list of uploaded document URLs
  Future<List<String>> call(List<File> documents) async {
    // Validate documents
    _validateDocuments(documents);

    try {
      return await repository.uploadVerificationDocuments(documents);
    } catch (e) {
      throw Exception('Failed to upload verification documents: $e');
    }
  }

  /// Validate document files before upload
  void _validateDocuments(List<File> documents) {
    final errors = <String>[];

    // Check if documents list is empty
    if (documents.isEmpty) {
      errors.add('At least one verification document is required');
    }

    // Validate each document
    for (int i = 0; i < documents.length; i++) {
      final file = documents[i];

      // Check if file exists
      if (!file.existsSync()) {
        errors.add('Document ${i + 1} does not exist');
        continue;
      }

      // Check file size (max 10MB per file)
      final fileSizeInBytes = file.lengthSync();
      final fileSizeInMB = fileSizeInBytes / (1024 * 1024);
      if (fileSizeInMB > 10) {
        errors.add('Document ${i + 1} exceeds 10MB size limit');
      }

      // Check file extension
      final fileName = file.path.toLowerCase();
      final validExtensions = ['.pdf', '.jpg', '.jpeg', '.png'];
      final isValidExtension = validExtensions.any(
        (ext) => fileName.endsWith(ext),
      );

      if (!isValidExtension) {
        errors.add(
          'Document ${i + 1} has invalid format. Allowed: PDF, JPG, PNG',
        );
      }
    }

    // Check maximum number of documents (max 5)
    if (documents.length > 5) {
      errors.add('Maximum 5 documents allowed');
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
