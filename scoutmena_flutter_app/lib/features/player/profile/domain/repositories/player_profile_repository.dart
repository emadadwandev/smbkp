import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../../core/error/failures.dart';
import '../entities/player_profile_entity.dart';
import '../entities/career_entry.dart';

import '../entities/academy_entity.dart';

/// Repository interface for player profile operations
abstract class PlayerProfileRepository {
  /// Get list of academies
  Future<Either<Failure, List<AcademyEntity>>> getAcademies();

  /// Get player profile
  Future<Either<Failure, PlayerProfileEntity>> getProfile();

  /// Create player profile
  Future<Either<Failure, PlayerProfileEntity>> createProfile({
    required String firstName,
    required String lastName,
    String? nationality,
    String? city,
    required String country,
    String? gender,
    int? heightCm,
    int? weightKg,
    String? preferredFoot,
    required String primaryPosition,
    List<String>? secondaryPositions,
    String? currentClub,
    String? academyId,
    String? academyName,
    int? jerseyNumber,
    DateTime? careerStartDate,
    String? bio,
    List<String>? achievements,
    String? agentName,
    String? agentEmail,
    required String contactEmail,
    String? phoneNumber,
    Map<String, String>? socialLinks,
    required String privacyLevel,
  });

  /// Update player profile
  Future<Either<Failure, PlayerProfileEntity>> updateProfile({
    required String profileId,
    String? firstName,
    String? lastName,
    String? nationality,
    String? city,
    String? country,
    String? gender,
    int? heightCm,
    int? weightKg,
    String? preferredFoot,
    String? primaryPosition,
    List<String>? secondaryPositions,
    String? currentClub,
    String? academyId,
    String? academyName,
    List<CareerEntry>? careerHistory,
    int? jerseyNumber,
    DateTime? careerStartDate,
    String? bio,
    List<String>? achievements,
    Map<String, dynamic>? trainingData,
    Map<String, dynamic>? technicalData,
    Map<String, dynamic>? tacticalData,
    Map<String, dynamic>? physicalData,
    String? agentName,
    String? agentEmail,
    String? contactEmail,
    String? phoneNumber,
    Map<String, String>? socialLinks,
    String? privacyLevel,
  });

  /// Upload profile photo
  Future<Either<Failure, String>> uploadProfilePhoto(File photo);

  /// Delete profile photo
  Future<Either<Failure, void>> deleteProfilePhoto();

  /// Delete hero image
  Future<Either<Failure, void>> deleteHeroImage();

  /// Upload gallery photo (max 5)
  Future<Either<Failure, String>> uploadGalleryPhoto({
    required File photo,
    bool isHero = false,
    String? caption,
  });

  /// Get gallery photos
  Future<Either<Failure, List<String>>> getGalleryPhotos();

  /// Delete gallery photo
  Future<Either<Failure, void>> deleteGalleryPhoto(String photoId);

  /// Delete video
  Future<Either<Failure, void>> deleteVideo(String videoId);

  /// Update privacy settings
  Future<Either<Failure, void>> updatePrivacySettings({
    required String privacyLevel,
  });

  /// Get player analytics
  Future<Either<Failure, Map<String, dynamic>>> getAnalytics();
}
