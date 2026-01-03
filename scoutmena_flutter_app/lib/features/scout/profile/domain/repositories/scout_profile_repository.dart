import 'dart:io';
import '../entities/scout_profile_entity.dart';

/// Repository interface for scout profile operations
/// Defines contract for data layer implementation
abstract class ScoutProfileRepository {
  /// Get scout profile for current user
  /// Returns null if profile doesn't exist
  Future<ScoutProfileEntity?> getProfile();

  /// Create new scout profile
  /// Throws exception if profile already exists
  Future<ScoutProfileEntity> createProfile(Map<String, dynamic> profileData);

  /// Update existing scout profile
  /// Throws exception if profile doesn't exist
  Future<ScoutProfileEntity> updateProfile(Map<String, dynamic> profileData);

  /// Upload verification documents during registration
  /// Returns list of uploaded document URLs
  Future<List<String>> uploadVerificationDocuments(List<File> documents);

  /// Upload or update profile photo
  /// Returns updated profile with new photo URL
  Future<ScoutProfileEntity> uploadProfilePhoto(File photo);

  /// Delete profile photo
  /// Returns updated profile without photo
  Future<ScoutProfileEntity> deleteProfilePhoto();

  /// Check verification status
  /// Returns current verification status and details
  Future<Map<String, dynamic>> getVerificationStatus();

  /// Refresh profile data from server
  /// Useful after admin approval notification
  Future<ScoutProfileEntity> refreshProfile();
}
