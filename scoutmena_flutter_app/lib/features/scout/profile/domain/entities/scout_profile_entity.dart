import 'package:equatable/equatable.dart';

/// Domain entity for scout profile
/// Contains business logic and validation rules
class ScoutProfileEntity extends Equatable {
  final String? id;
  final String? userId;
  final String firstName;
  final String lastName;
  final String? clubName;
  final String? jobTitle;
  final List<String>? specializations;
  final String country;
  final List<String>? leaguesOfInterest;
  final List<String>? certificates;
  final String? bio;
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

  const ScoutProfileEntity({
    this.id,
    this.userId,
    required this.firstName,
    required this.lastName,
    this.clubName,
    this.jobTitle,
    this.specializations,
    required this.country,
    this.leaguesOfInterest,
    this.certificates,
    this.bio,
    this.contactEmail,
    this.contactPhone,
    this.socialLinks,
    this.profilePhotoUrl,
    this.isVerified = false,
    this.isActive = false,
    this.verificationStatus,
    this.verificationDocumentUrls,
    this.verifiedAt,
    this.createdAt,
    this.updatedAt,
  });

  /// Get full name
  String get fullName => '$firstName $lastName';

  /// Check if profile is complete (basic info filled)
  bool get isComplete {
    return firstName.isNotEmpty &&
        lastName.isNotEmpty &&
        country.isNotEmpty &&
        bio != null &&
        bio!.isNotEmpty;
  }

  /// Check if profile is pending verification
  bool get isPendingVerification {
    return !isVerified &&
        verificationStatus == 'pending' &&
        verificationDocumentUrls != null &&
        verificationDocumentUrls!.isNotEmpty;
  }

  /// Check if verification was rejected
  bool get isVerificationRejected {
    return !isVerified && verificationStatus == 'rejected';
  }

  /// Check if can search players (verified and active)
  bool get canSearchPlayers {
    return isVerified && isActive;
  }

  /// Check if documents are uploaded
  bool get hasUploadedDocuments {
    return verificationDocumentUrls != null &&
        verificationDocumentUrls!.isNotEmpty;
  }

  /// Calculate profile completion percentage (0-100)
  int get completionPercentage {
    int score = 0;
    const int maxScore = 100;

    // Required fields (40%)
    if (firstName.isNotEmpty) score += 10;
    if (lastName.isNotEmpty) score += 10;
    if (country.isNotEmpty) score += 10;
    if (bio != null && bio!.isNotEmpty) score += 10;

    // Optional but important fields (60%)
    if (clubName != null && clubName!.isNotEmpty) score += 10;
    if (specializations != null && specializations!.isNotEmpty) score += 15;
    if (leaguesOfInterest != null && leaguesOfInterest!.isNotEmpty) score += 10;
    if (certificates != null && certificates!.isNotEmpty) score += 10;
    if (profilePhotoUrl != null) score += 10;
    if (contactEmail != null || contactPhone != null) score += 5;

    return score.clamp(0, maxScore);
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        firstName,
        lastName,
        clubName,
        specializations,
        country,
        leaguesOfInterest,
        certificates,
        bio,
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
      ];
}
