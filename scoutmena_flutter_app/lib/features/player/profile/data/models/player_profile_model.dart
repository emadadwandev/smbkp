import 'package:equatable/equatable.dart';
import '../../domain/entities/player_profile_entity.dart';
import '../../domain/entities/career_entry.dart';
import '../../domain/entities/photo_entity.dart';
import '../../domain/entities/video_entity.dart';
import 'photo_model.dart';
import 'video_model.dart';

/// Data model for player profile
/// Handles JSON serialization/deserialization for API communication
class PlayerProfileModel extends Equatable {
  final String? id;
  final String? userId;
  final String firstName;
  final String lastName;
  final String? nationality;
  final String? city;
  final String country;
  final String? gender;
  final int? heightCm;
  final int? weightKg;
  final String? preferredFoot;
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
  final Map<String, String>? socialLinks;
  final String privacyLevel;
  final String? profilePhotoUrl;
  final String? heroImageUrl;
  final List<String>? galleryPhotoUrls;
  final List<PhotoEntity>? photos;
  final List<VideoEntity>? videos;
  final int? profileCompletionScore;
  final bool? isPublished;
  final bool? requiresModeration;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const PlayerProfileModel({
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

  /// Convert from JSON
  factory PlayerProfileModel.fromJson(Map<String, dynamic> json) {
    // Handle nested location object
    final location = json['location'] as Map<String, dynamic>?;
    
    // Handle nested physical object
    final physical = json['physical'] as Map<String, dynamic>?;
    
    // Handle nested football object
    final football = json['football'] as Map<String, dynamic>?;
    
    // Handle nested contact object
    final contact = json['contact'] as Map<String, dynamic>?;
    final agent = contact?['agent'] as Map<String, dynamic>?;
    
    // Handle nested metrics object
    final metrics = json['metrics'] as Map<String, dynamic>?;
    
    // Extract photos URLs from photos array
    final photosRaw = json['photos'] as List<dynamic>?;
    String? profilePhotoUrl = json['profile_photo_url'] as String?;
    String? heroImageUrl = json['hero_image_url'] as String?;
    List<String>? galleryPhotoUrls;
    List<PhotoEntity>? photos;
    
    if (photosRaw != null && photosRaw.isNotEmpty) {
      photos = photosRaw.map((p) => PhotoModel.fromJson(p as Map<String, dynamic>)).toList();

      // Find primary/hero photo
      final primaryPhoto = photosRaw.firstWhere(
        (p) => (p as Map<String, dynamic>)['is_primary'] == true,
        orElse: () => photosRaw.first,
      ) as Map<String, dynamic>?;
      
      if (primaryPhoto != null && profilePhotoUrl == null) {
        final urls = primaryPhoto['urls'] as Map<String, dynamic>?;
        profilePhotoUrl = urls?['medium'] as String? ?? urls?['original'] as String?;
      }
      
      // Collect all photo URLs for gallery
      galleryPhotoUrls = photosRaw.map((p) {
        final photoMap = p as Map<String, dynamic>;
        final urls = photoMap['urls'] as Map<String, dynamic>?;
        return urls?['medium'] as String? ?? urls?['original'] as String?;
      }).whereType<String>().toList();
    }

    // Extract videos
    final videosRaw = json['videos'] as List<dynamic>?;
    List<VideoEntity>? videos;
    if (videosRaw != null && videosRaw.isNotEmpty) {
      videos = videosRaw.map((v) => VideoModel.fromJson(v as Map<String, dynamic>)).toList();
    }
    
    // Parse social links safely
    final socialLinksRaw = json['social_links'];
    Map<String, String>? socialLinks;
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
      socialLinks = Map<String, String>.from(socialLinksRaw);
    }
    
    // Parse achievements safely
    final achievementsRaw = json['achievements'];
    List<String>? achievements;
    if (achievementsRaw is List && achievementsRaw.isNotEmpty) {
      achievements = achievementsRaw.map((e) => e.toString()).toList();
    }

    // Parse career history
    final previousClubsRaw = football?['previous_clubs'] as List<dynamic>?;
    List<CareerEntry>? careerHistory;
    if (previousClubsRaw != null) {
      careerHistory = previousClubsRaw
          .map((e) => CareerEntry.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    
    return PlayerProfileModel(
      id: json['id'] as String?,
      userId: json['user_id'] as String?,
      firstName: json['first_name'] as String? ?? '',
      lastName: json['last_name'] as String? ?? '',
      nationality: location?['nationality'] as String?,
      city: location?['city'] as String?,
      country: location?['country'] as String? ?? '',
      gender: json['gender'] as String? ?? physical?['gender'] as String?,
      heightCm: physical?['height_cm'] as int?,
      weightKg: physical?['weight_kg'] as int?,
      preferredFoot: physical?['preferred_foot'] as String?,
      physicalData: physical?['data'] as Map<String, dynamic>?,
      trainingData: json['training_data'] as Map<String, dynamic>?,
      technicalData: json['technical_data'] as Map<String, dynamic>?,
      tacticalData: json['tactical_data'] as Map<String, dynamic>?,
      primaryPosition: football?['primary_position'] as String? ?? '',
      secondaryPositions: (football?['secondary_positions'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      currentClub: football?['current_club'] as String?,
      careerHistory: careerHistory,
      jerseyNumber: football?['jersey_number'] as int?,
      careerStartDate: football?['career_start_date'] != null
          ? DateTime.tryParse(football!['career_start_date'].toString())
          : null,
      bio: json['bio'] as String?,
      achievements: achievements,
      agentName: agent?['name'] as String?,
      agentEmail: agent?['email'] as String?,
      contactEmail: contact?['email'] as String? ?? '',
      phoneNumber: contact?['phone'] as String?,
      socialLinks: socialLinks,
      privacyLevel: json['privacy_level'] as String? ?? 'scouts_only',
      profilePhotoUrl: profilePhotoUrl,
      heroImageUrl: heroImageUrl,
      galleryPhotoUrls: galleryPhotoUrls,
      photos: photos,
      videos: videos,
      profileCompletionScore: metrics?['completion_score'] as int?,
      isPublished: json['is_published'] as bool?,
      requiresModeration: json['moderation'] != null
          ? (json['moderation'] as Map<String, dynamic>)['status'] == 'pending'
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
      if (nationality != null) 'nationality': nationality,
      if (city != null) 'city': city,
      'country': country,
      if (gender != null) 'gender': gender,
      if (heightCm != null) 'height_cm': heightCm,
      if (weightKg != null) 'weight_kg': weightKg,
      if (preferredFoot != null) 'preferred_foot': preferredFoot,
      'primary_position': primaryPosition,
      if (secondaryPositions != null) 'secondary_positions': secondaryPositions,
      if (currentClub != null) 'current_club': currentClub,
      if (careerHistory != null) 'previous_clubs': careerHistory!.map((e) => e.toJson()).toList(),
      if (jerseyNumber != null) 'jersey_number': jerseyNumber,
      if (careerStartDate != null)
        'career_start_date': careerStartDate!.toIso8601String(),
      if (bio != null) 'bio': bio,
      if (achievements != null) 'achievements': achievements,
      if (trainingData != null) 'training_data': trainingData,
      if (technicalData != null) 'technical_data': technicalData,
      if (tacticalData != null) 'tactical_data': tacticalData,
      if (physicalData != null) 'physical_data': physicalData,
      if (agentName != null) 'agent_name': agentName,
      if (agentEmail != null) 'agent_email': agentEmail,
      'contact_email': contactEmail,
      if (phoneNumber != null) 'contact_phone': phoneNumber,
      if (socialLinks != null) 'social_links': socialLinks,
      'privacy_level': privacyLevel,
      if (profilePhotoUrl != null) 'profile_photo_url': profilePhotoUrl,
      if (heroImageUrl != null) 'hero_image_url': heroImageUrl,
      if (galleryPhotoUrls != null) 'gallery_photo_urls': galleryPhotoUrls,
      if (videos != null) 'videos': videos!.map((v) => (v as VideoModel).toJson()).toList(),
      if (profileCompletionScore != null)
        'profile_completion_score': profileCompletionScore,
      if (isPublished != null) 'is_published': isPublished,
      if (requiresModeration != null) 'requires_moderation': requiresModeration,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  /// Convert to domain entity
  PlayerProfileEntity toEntity() {
    return PlayerProfileEntity(
      id: id,
      userId: userId,
      firstName: firstName,
      lastName: lastName,
      nationality: nationality,
      city: city,
      country: country,
      gender: gender,
      heightCm: heightCm,
      weightKg: weightKg,
      preferredFoot: preferredFoot,
      primaryPosition: primaryPosition,
      secondaryPositions: secondaryPositions,
      currentClub: currentClub,
      careerHistory: careerHistory,
      jerseyNumber: jerseyNumber,
      careerStartDate: careerStartDate,
      bio: bio,
      achievements: achievements,
      trainingData: trainingData,
      technicalData: technicalData,
      tacticalData: tacticalData,
      physicalData: physicalData,
      agentName: agentName,
      agentEmail: agentEmail,
      contactEmail: contactEmail,
      phoneNumber: phoneNumber,
      socialLinks: socialLinks,
      privacyLevel: privacyLevel,
      profilePhotoUrl: profilePhotoUrl,
      heroImageUrl: heroImageUrl,
      galleryPhotoUrls: galleryPhotoUrls,
      photos: photos,
      videos: videos,
      profileCompletionScore: profileCompletionScore,
      isPublished: isPublished,
      requiresModeration: requiresModeration,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Create from domain entity
  factory PlayerProfileModel.fromEntity(PlayerProfileEntity entity) {
    return PlayerProfileModel(
      id: entity.id,
      userId: entity.userId,
      firstName: entity.firstName,
      lastName: entity.lastName,
      nationality: entity.nationality,
      city: entity.city,
      country: entity.country,
      gender: entity.gender,
      heightCm: entity.heightCm,
      weightKg: entity.weightKg,
      preferredFoot: entity.preferredFoot,
      primaryPosition: entity.primaryPosition,
      secondaryPositions: entity.secondaryPositions,
      currentClub: entity.currentClub,
      careerHistory: entity.careerHistory,
      jerseyNumber: entity.jerseyNumber,
      careerStartDate: entity.careerStartDate,
      bio: entity.bio,
      achievements: entity.achievements,
      trainingData: entity.trainingData,
      technicalData: entity.technicalData,
      tacticalData: entity.tacticalData,
      physicalData: entity.physicalData,
      agentName: entity.agentName,
      agentEmail: entity.agentEmail,
      contactEmail: entity.contactEmail,
      phoneNumber: entity.phoneNumber,
      socialLinks: entity.socialLinks,
      privacyLevel: entity.privacyLevel,
      profilePhotoUrl: entity.profilePhotoUrl,
      heroImageUrl: entity.heroImageUrl,
      galleryPhotoUrls: entity.galleryPhotoUrls,
      photos: entity.photos,
      videos: entity.videos,
      profileCompletionScore: entity.profileCompletionScore,
      isPublished: entity.isPublished,
      requiresModeration: entity.requiresModeration,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
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
        profileCompletionScore,
        isPublished,
        requiresModeration,
        createdAt,
        updatedAt,
      ];
}
