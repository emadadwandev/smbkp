import 'package:equatable/equatable.dart';
import '../../domain/entities/scout_profile_entity.dart';

/// Data model for scout profile
/// Handles JSON serialization/deserialization for API communication
class ScoutProfileModel extends Equatable {
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

  const ScoutProfileModel({
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

  /// Convert from JSON
  factory ScoutProfileModel.fromJson(Map<String, dynamic> json) {
    // Parse specializations safely
    List<String>? specializations;
    final specializationsRaw = json['specializations'];
    if (specializationsRaw is List && specializationsRaw.isNotEmpty) {
      specializations = specializationsRaw.map((e) => e.toString()).toList();
    }
    
    // Parse leagues safely
    List<String>? leaguesOfInterest;
    final leaguesRaw = json['leagues_of_interest'] ?? json['leagues'];
    if (leaguesRaw is List && leaguesRaw.isNotEmpty) {
      leaguesOfInterest = leaguesRaw.map((e) => e.toString()).toList();
    }
    
    // Parse certificates safely
    List<String>? certificates;
    final certificatesRaw = json['certificates'];
    if (certificatesRaw is List && certificatesRaw.isNotEmpty) {
      certificates = certificatesRaw.map((e) => e.toString()).toList();
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

    // Parse name from user object if not at root
    String firstName = json['first_name']?.toString() ?? '';
    String lastName = json['last_name']?.toString() ?? '';
    
    if (firstName.isEmpty && lastName.isEmpty && json['user'] != null) {
      final user = json['user'];
      if (user is Map<String, dynamic>) {
        final name = user['name']?.toString() ?? '';
        if (name.isNotEmpty) {
          final parts = name.split(' ');
          if (parts.isNotEmpty) {
            firstName = parts.first;
            if (parts.length > 1) {
              lastName = parts.sublist(1).join(' ');
            }
          }
        }
      } else if (user.toString().contains('name:')) {
        // Handle the case where user might be a string representation (as seen in logs)
        // though ideally it should be a Map. The log showed: user: {id: 3, name: Test Scout...}
        // which might be just how it was printed, but if it's a Map, the above works.
      }
    }
    
    return ScoutProfileModel(
      id: json['id']?.toString(),
      userId: json['user_id']?.toString(),
      firstName: firstName,
      lastName: lastName,
      clubName: json['club_name']?.toString(),
      jobTitle: json['job_title']?.toString(),
      specializations: specializations,
      country: json['country']?.toString() ?? '',
      leaguesOfInterest: leaguesOfInterest,
      certificates: certificates,
      bio: json['bio']?.toString(),
      contactEmail: json['contact_email']?.toString(),
      contactPhone: json['contact_phone']?.toString(),
      socialLinks: socialLinks,
      profilePhotoUrl: json['profile_photo_url']?.toString(),
      isVerified: json['is_verified'] == true,
      isActive: json['is_active'] == true,
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
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      'first_name': firstName,
      'last_name': lastName,
      if (clubName != null) 'club_name': clubName,
      if (jobTitle != null) 'job_title': jobTitle,
      if (specializations != null) 'specializations': specializations,
      'country': country,
      if (leaguesOfInterest != null) 'leagues_of_interest': leaguesOfInterest,
      if (certificates != null) 'certificates': certificates,
      if (bio != null) 'bio': bio,
      if (contactEmail != null) 'contact_email': contactEmail,
      if (contactPhone != null) 'contact_phone': contactPhone,
      if (socialLinks != null) 'social_links': socialLinks,
      if (profilePhotoUrl != null) 'profile_photo_url': profilePhotoUrl,
      'is_verified': isVerified,
      'is_active': isActive,
      if (verificationStatus != null) 'verification_status': verificationStatus,
      if (verificationDocumentUrls != null)
        'verification_document_urls': verificationDocumentUrls,
      if (verifiedAt != null) 'verified_at': verifiedAt!.toIso8601String(),
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  /// Convert to domain entity
  ScoutProfileEntity toEntity() {
    return ScoutProfileEntity(
      id: id,
      userId: userId,
      firstName: firstName,
      lastName: lastName,
      clubName: clubName,
      jobTitle: jobTitle,
      specializations: specializations,
      country: country,
      leaguesOfInterest: leaguesOfInterest,
      certificates: certificates,
      bio: bio,
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
    );
  }

  /// Create from domain entity
  factory ScoutProfileModel.fromEntity(ScoutProfileEntity entity) {
    return ScoutProfileModel(
      id: entity.id,
      userId: entity.userId,
      firstName: entity.firstName,
      lastName: entity.lastName,
      clubName: entity.clubName,
      specializations: entity.specializations,
      country: entity.country,
      leaguesOfInterest: entity.leaguesOfInterest,
      certificates: entity.certificates,
      bio: entity.bio,
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
    );
  }

  /// Create a copy with modifications
  ScoutProfileModel copyWith({
    String? id,
    String? userId,
    String? firstName,
    String? lastName,
    String? clubName,
    List<String>? specializations,
    String? country,
    List<String>? leaguesOfInterest,
    List<String>? certificates,
    String? bio,
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
  }) {
    return ScoutProfileModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      clubName: clubName ?? this.clubName,
      specializations: specializations ?? this.specializations,
      country: country ?? this.country,
      leaguesOfInterest: leaguesOfInterest ?? this.leaguesOfInterest,
      certificates: certificates ?? this.certificates,
      bio: bio ?? this.bio,
      contactEmail: contactEmail ?? this.contactEmail,
      contactPhone: contactPhone ?? this.contactPhone,
      socialLinks: socialLinks ?? this.socialLinks,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
      isVerified: isVerified ?? this.isVerified,
      isActive: isActive ?? this.isActive,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      verificationDocumentUrls:
          verificationDocumentUrls ?? this.verificationDocumentUrls,
      verifiedAt: verifiedAt ?? this.verifiedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
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
