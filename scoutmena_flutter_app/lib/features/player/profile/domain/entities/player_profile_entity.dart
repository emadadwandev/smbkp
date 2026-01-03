import 'package:equatable/equatable.dart';
import 'career_entry.dart';
import 'photo_entity.dart';
import 'video_entity.dart';

/// Player profile domain entity
/// Represents a player's complete profile data
class PlayerProfileEntity extends Equatable {
  final String? id;
  final String? userId;
  final String firstName;
  final String lastName;
  final String? nationality;
  final String? city;
  final String country;
  final String? gender; // 'male', 'female'
  final int? heightCm;
  final int? weightKg;
  final String? preferredFoot; // 'left', 'right', 'both'
  final String primaryPosition;
  final List<String>? secondaryPositions;
  final String? currentClub;
  final List<CareerEntry>? careerHistory;
  final int? jerseyNumber;
  final DateTime? careerStartDate;
  final String? bio;
  final List<String>? achievements;
  final Map<String, dynamic>? trainingData;
  final Map<String, dynamic>? technicalData;
  final Map<String, dynamic>? tacticalData;
  final Map<String, dynamic>? physicalData;
  final String? agentName;
  final String? agentEmail;
  final String contactEmail;
  final String? phoneNumber;
  final Map<String, String>? socialLinks; // {instagram: '@user', twitter: '@user'}
  final String privacyLevel; // 'public', 'scouts_only', 'private'
  final String? profilePhotoUrl;
  final String? heroImageUrl;
  final List<String>? galleryPhotoUrls;
  final List<PhotoEntity>? photos;
  final List<VideoEntity>? videos;
  final int? profileCompletionScore; // 0-100
  final bool? isPublished; // Draft mode for minors awaiting parental consent
  final bool? requiresModeration; // All minor content requires moderation
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const PlayerProfileEntity({
    this.id,
    this.userId,
    required this.firstName,
    required this.lastName,
    this.nationality,
    this.city,
    required this.country,
    this.gender,
    this.heightCm,
    this.weightKg,
    this.preferredFoot,
    required this.primaryPosition,
    this.secondaryPositions,
    this.currentClub,
    this.careerHistory,
    this.jerseyNumber,
    this.careerStartDate,
    this.bio,
    this.achievements,
    this.trainingData,
    this.technicalData,
    this.tacticalData,
    this.physicalData,
    this.agentName,
    this.agentEmail,
    required this.contactEmail,
    this.phoneNumber,
    this.socialLinks,
    required this.privacyLevel,
    this.profilePhotoUrl,
    this.heroImageUrl,
    this.galleryPhotoUrls,
    this.photos,
    this.videos,
    this.profileCompletionScore,
    this.isPublished,
    this.requiresModeration,
    this.createdAt,
    this.updatedAt,
  });

  /// Get full name
  String get fullName => '$firstName $lastName';

  /// Check if profile is complete (score >= 80)
  bool get isComplete => (profileCompletionScore ?? 0) >= 80;

  /// Check if profile is in draft mode
  bool get isDraft => isPublished == false;

  /// Calculate profile completion percentage (0-100)
  int calculateCompletionPercentage() {
    int score = 0;

    // 1. Basic Info (20%)
    if (firstName.isNotEmpty && lastName.isNotEmpty) score += 5;
    if (nationality != null && nationality!.isNotEmpty) score += 5;
    if (city != null && city!.isNotEmpty) score += 5;
    if (bio != null && bio!.isNotEmpty) score += 5;

    // 2. Physical Data (15%)
    if (heightCm != null && heightCm! > 0) score += 5;
    if (weightKg != null && weightKg! > 0) score += 5;
    if (preferredFoot != null && preferredFoot!.isNotEmpty) score += 5;

    // 3. Football Details (15%)
    if (primaryPosition.isNotEmpty) score += 5;
    if (currentClub != null && currentClub!.isNotEmpty) score += 5;
    if (jerseyNumber != null) score += 5;

    // 4. Media (20%)
    if (profilePhotoUrl != null && profilePhotoUrl!.isNotEmpty) score += 10;
    if (heroImageUrl != null && heroImageUrl!.isNotEmpty) score += 5;
    if (galleryPhotoUrls != null && galleryPhotoUrls!.isNotEmpty) score += 5;

    // 5. Attributes (20%)
    if (technicalData != null && technicalData!.isNotEmpty) score += 7;
    if (tacticalData != null && tacticalData!.isNotEmpty) score += 7;
    if (physicalData != null && physicalData!.isNotEmpty) score += 6;

    // 6. History (10%)
    if (careerHistory != null && careerHistory!.isNotEmpty) score += 10;

    return score.clamp(0, 100);
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        firstName,
        lastName,
        nationality,
        city,
        country,
        gender,
        heightCm,
        weightKg,
        preferredFoot,
        primaryPosition,
        secondaryPositions,
        currentClub,
        careerHistory,
        jerseyNumber,
        careerStartDate,
        bio,
        achievements,
        trainingData,
        technicalData,
        tacticalData,
        physicalData,
        agentName,
        agentEmail,
        contactEmail,
        phoneNumber,
        socialLinks,
        privacyLevel,
        profilePhotoUrl,
        heroImageUrl,
        galleryPhotoUrls,
        photos,
        videos,
        profileCompletionScore,
        isPublished,
        requiresModeration,
        createdAt,
        updatedAt,
      ];
}
