import 'package:equatable/equatable.dart';

/// Domain entity for coach profile
/// Contains business logic and validation rules
class CoachProfileEntity extends Equatable {
  final String? id;
  final String? userId;
  final String firstName;
  final String lastName;
  final String clubName;
  final String currentRole;
  final String coachingLicense;
  final int yearsOfExperience;
  final List<String>? specializations;
  final String? bio;
  final String country;
  final String? city;
  final String? contactEmail;
  final String? contactPhone;
  final Map<String, String>? socialLinks;
  final String? profilePhotoUrl;
  final bool isVerified;
  final bool isActive;
  final String? verificationStatus;
  final List<String>? verificationDocumentUrls;
  final DateTime? verifiedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<Map<String, dynamic>>? academies;

  const CoachProfileEntity({
    this.id,
    this.userId,
    required this.firstName,
    required this.lastName,
    required this.clubName,
    required this.currentRole,
    required this.coachingLicense,
    required this.yearsOfExperience,
    this.specializations,
    this.bio,
    required this.country,
    this.city,
    this.contactEmail,
    this.contactPhone,
    this.socialLinks,
    this.profilePhotoUrl,
    this.isVerified = false,
    this.isActive = true,
    this.verificationStatus,
    this.verificationDocumentUrls,
    this.verifiedAt,
    this.createdAt,
    this.updatedAt,
    this.academies,
  });

  /// Get full name
  String get fullName => '$firstName $lastName';

  /// Get full location (city, country or just country)
  String get fullLocation {
    if (city != null && city!.isNotEmpty) {
      return '$city, $country';
    }
    return country;
  }

  /// Check if profile is complete (all required info filled)
  bool get isComplete {
    return firstName.isNotEmpty &&
        lastName.isNotEmpty &&
        clubName.isNotEmpty &&
        currentRole.isNotEmpty &&
        coachingLicense.isNotEmpty &&
        country.isNotEmpty &&
        bio != null &&
        bio!.isNotEmpty;
  }

  /// Check if coach is experienced (5+ years)
  bool get isExperienced => yearsOfExperience >= 5;

  /// Check if coach is veteran (10+ years)
  bool get isVeteran => yearsOfExperience >= 10;

  /// Calculate profile completion percentage (0-100)
  int get completionPercentage {
    int score = 0;
    const int maxScore = 100;

    // Required fields (50%)
    if (firstName.isNotEmpty) score += 10;
    if (lastName.isNotEmpty) score += 10;
    if (clubName.isNotEmpty) score += 10;
    if (currentRole.isNotEmpty) score += 10;
    if (coachingLicense.isNotEmpty) score += 10;

    // Important optional fields (50%)
    if (bio != null && bio!.isNotEmpty) score += 15;
    if (specializations != null && specializations!.isNotEmpty) score += 10;
    if (city != null && city!.isNotEmpty) score += 5;
    if (profilePhotoUrl != null) score += 10;
    if (contactEmail != null || contactPhone != null) score += 5;
    if (socialLinks != null && socialLinks!.isNotEmpty) score += 5;

    return score.clamp(0, maxScore);
  }

  /// Get experience level label
  String get experienceLevel {
    if (yearsOfExperience >= 15) return 'Expert';
    if (yearsOfExperience >= 10) return 'Veteran';
    if (yearsOfExperience >= 5) return 'Experienced';
    if (yearsOfExperience >= 2) return 'Intermediate';
    return 'Beginner';
  }

  /// Check if verification is pending
  bool get isPendingVerification {
    return !isVerified && 
           verificationStatus == 'pending' && 
           hasUploadedDocuments;
  }

  /// Check if verification was rejected
  bool get isVerificationRejected {
    return !isVerified && verificationStatus == 'rejected';
  }

  /// Check if has uploaded verification documents
  bool get hasUploadedDocuments {
    return verificationDocumentUrls != null && 
           verificationDocumentUrls!.isNotEmpty;
  }

  /// Check if can search players (must be verified and active)
  bool get canSearchPlayers => isVerified && isActive;

  @override
  List<Object?> get props => [
        id,
        userId,
        firstName,
        lastName,
        clubName,
        currentRole,
        coachingLicense,
        yearsOfExperience,
        specializations,
        bio,
        country,
        city,
        contactEmail,
        contactPhone,
        socialLinks,
        profilePhotoUrl,
        isVerified,
        isActive,
        verificationStatus,
        verificationDocumentUrls,
        verifiedAt,
        createdAt,
        updatedAt,
        academies,
      ];
}
