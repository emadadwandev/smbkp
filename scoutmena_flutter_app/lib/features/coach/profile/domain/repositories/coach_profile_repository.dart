import 'dart:io';
import '../entities/coach_profile_entity.dart';

/// Repository interface for coach profile operations
/// Defines contract for data layer implementation
abstract class CoachProfileRepository {
  /// Get coach profile for current user
  /// Returns null if profile doesn't exist
  Future<CoachProfileEntity?> getProfile();

  /// Create new coach profile
  /// Throws exception if profile already exists
  Future<CoachProfileEntity> createProfile(Map<String, dynamic> profileData);

  /// Update existing coach profile
  /// Throws exception if profile doesn't exist
  Future<CoachProfileEntity> updateProfile(Map<String, dynamic> profileData);

  /// Upload or update profile photo
  /// Returns updated profile with new photo URL
  Future<CoachProfileEntity> uploadProfilePhoto(File photo);

  /// Delete profile photo
  /// Returns updated profile without photo
  Future<CoachProfileEntity> deleteProfilePhoto();

  /// Refresh profile data from server
  Future<CoachProfileEntity> refreshProfile();

  /// Upload verification documents (license, certificates, ID, etc.)
  /// Returns list of uploaded document URLs
  Future<List<String>> uploadVerificationDocuments(List<File> documents);

  /// Get verification status
  /// Returns verification data including status, documents, rejection reason
  Future<Map<String, dynamic>> getVerificationStatus();
}
