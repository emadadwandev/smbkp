import '../../domain/entities/coach_profile_entity.dart';

/// Data model for coach profile
/// Handles JSON serialization/deserialization for API communication
class CoachProfileModel {
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

  const CoachProfileModel({
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

  /// Convert from JSON
  factory CoachProfileModel.fromJson(Map<String, dynamic> json) {
    // Parse specializations safely
    List<String>? specializations;
    final specializationsRaw = json['specializations'];
    if (specializationsRaw is List && specializationsRaw.isNotEmpty) {
      specializations = specializationsRaw.map((e) => e.toString()).toList();
    }
    
    // Parse social links safely
    Map<String, String>? socialLinks;
    final socialLinksRaw = json['social_links'];
    if (socialLinksRaw is List && socialLinksRaw.isNotEmpty) {
      socialLinks = {};
      for (var link in socialLinksRaw) {
        if (link is Map<String, dynamic>) {
          link.forEach((key, value) {
            if (value != null) {
              socialLinks![key] = value.toString();
            }
          });
        }
      }
    } else if (socialLinksRaw is Map) {
      socialLinks = {};
      socialLinksRaw.forEach((key, value) {
        if (value != null) {
          socialLinks![key.toString()] = value.toString();
        }
      });
    }
    
    // Parse verification documents safely
    List<String>? verificationDocumentUrls;
    final docsRaw = json['verification_document_urls'] ?? json['verification_documents'];
    if (docsRaw is List && docsRaw.isNotEmpty) {
      verificationDocumentUrls = docsRaw.map((e) => e.toString()).toList();
    }

    // Parse academies
    List<Map<String, dynamic>>? academies;
    if (json['academies'] is List) {
      academies = (json['academies'] as List).map((e) => e as Map<String, dynamic>).toList();
    }
    
    return CoachProfileModel(
      id: json['id']?.toString(),
      userId: json['user_id']?.toString(),
      firstName: json['first_name']?.toString() ?? '',
      lastName: json['last_name']?.toString() ?? '',
      clubName: json['club_name']?.toString() ?? '',
      currentRole: json['current_role']?.toString() ?? '',
      coachingLicense: json['coaching_license']?.toString() ?? '',
      yearsOfExperience: (json['years_of_experience'] is int)
          ? json['years_of_experience'] as int
          : int.tryParse(json['years_of_experience']?.toString() ?? '0') ?? 0,
      specializations: specializations,
      bio: json['bio']?.toString(),
      country: json['country']?.toString() ?? '',
      city: json['city']?.toString(),
      contactEmail: json['contact_email']?.toString(),
      contactPhone: json['contact_phone']?.toString(),
      socialLinks: socialLinks,
      profilePhotoUrl: json['profile_photo_url']?.toString(),
      isVerified: json['is_verified'] == true,
      isActive: json['is_active'] != false, // Default true unless explicitly false
      verificationStatus: json['verification_status']?.toString(),
      verificationDocumentUrls: verificationDocumentUrls,
      verifiedAt: json['verified_at'] != null
          ? DateTime.tryParse(json['verified_at'].toString())
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
      academies: academies,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      'first_name': firstName,
      'last_name': lastName,
      'club_name': clubName,
      'current_role': currentRole,
      'coaching_license': coachingLicense,
      'years_of_experience': yearsOfExperience,
      if (specializations != null) 'specializations': specializations,
      if (bio != null) 'bio': bio,
      'country': country,
      if (city != null) 'city': city,
      if (contactEmail != null) 'contact_email': contactEmail,
      if (contactPhone != null) 'contact_phone': contactPhone,
      if (socialLinks != null) 'social_links': socialLinks,
      if (profilePhotoUrl != null) 'profile_photo_url': profilePhotoUrl,
      'is_verified': isVerified,
      'is_active': isActive,
      if (verificationStatus != null) 'verification_status': verificationStatus,
      if (verificationDocumentUrls != null) 'verification_document_urls': verificationDocumentUrls,
      if (verifiedAt != null) 'verified_at': verifiedAt!.toIso8601String(),
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
      if (academies != null) 'academies': academies,
    };
  }

  /// Convert to domain entity
  CoachProfileEntity toEntity() {
    return CoachProfileEntity(
      id: id,
      userId: userId,
      firstName: firstName,
      lastName: lastName,
      clubName: clubName,
      currentRole: currentRole,
      coachingLicense: coachingLicense,
      yearsOfExperience: yearsOfExperience,
      specializations: specializations,
      bio: bio,
      country: country,
      city: city,
      contactEmail: contactEmail,
      contactPhone: contactPhone,
      socialLinks: socialLinks,
      profilePhotoUrl: profilePhotoUrl,
      isVerified: isVerified,
      isActive: isActive,
      verificationStatus: verificationStatus,
      verificationDocumentUrls: verificationDocumentUrls,
      verifiedAt: verifiedAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
      academies: academies,
    );
  }

  /// Create from domain entity
  factory CoachProfileModel.fromEntity(CoachProfileEntity entity) {
    return CoachProfileModel(
      id: entity.id,
      userId: entity.userId,
      firstName: entity.firstName,
      lastName: entity.lastName,
      clubName: entity.clubName,
      currentRole: entity.currentRole,
      coachingLicense: entity.coachingLicense,
      yearsOfExperience: entity.yearsOfExperience,
      specializations: entity.specializations,
      bio: entity.bio,
      country: entity.country,
      city: entity.city,
      contactEmail: entity.contactEmail,
      contactPhone: entity.contactPhone,
      socialLinks: entity.socialLinks,
      profilePhotoUrl: entity.profilePhotoUrl,
      isVerified: entity.isVerified,
      isActive: entity.isActive,
      verificationStatus: entity.verificationStatus,
      verificationDocumentUrls: entity.verificationDocumentUrls,
      verifiedAt: entity.verifiedAt,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      academies: entity.academies,
    );
  }

  /// Create a copy with modifications
  CoachProfileModel copyWith({
    String? id,
    String? userId,
    String? firstName,
    String? lastName,
    String? clubName,
    String? currentRole,
    String? coachingLicense,
    int? yearsOfExperience,
    List<String>? specializations,
    String? bio,
    String? country,
    String? city,
    String? contactEmail,
    String? contactPhone,
    Map<String, String>? socialLinks,
    String? profilePhotoUrl,
    bool? isVerified,
    bool? isActive,
    String? verificationStatus,
    List<String>? verificationDocumentUrls,
    DateTime? verifiedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<Map<String, dynamic>>? academies,
  }) {
    return CoachProfileModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      clubName: clubName ?? this.clubName,
      currentRole: currentRole ?? this.currentRole,
      coachingLicense: coachingLicense ?? this.coachingLicense,
      yearsOfExperience: yearsOfExperience ?? this.yearsOfExperience,
      specializations: specializations ?? this.specializations,
      bio: bio ?? this.bio,
      country: country ?? this.country,
      city: city ?? this.city,
      contactEmail: contactEmail ?? this.contactEmail,
      contactPhone: contactPhone ?? this.contactPhone,
      socialLinks: socialLinks ?? this.socialLinks,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
      isVerified: isVerified ?? this.isVerified,
      isActive: isActive ?? this.isActive,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      verificationDocumentUrls: verificationDocumentUrls ?? this.verificationDocumentUrls,
      verifiedAt: verifiedAt ?? this.verifiedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      academies: academies ?? this.academies,
    );
  }
}
