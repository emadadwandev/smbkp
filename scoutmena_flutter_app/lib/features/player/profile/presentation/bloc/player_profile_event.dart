import 'dart:io';
import 'package:equatable/equatable.dart';
import '../../domain/entities/career_entry.dart';

/// Base class for all player profile events
abstract class PlayerProfileEvent extends Equatable {
  const PlayerProfileEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load player profile
class LoadPlayerProfile extends PlayerProfileEvent {
  const LoadPlayerProfile();
}

/// Event to load academies
class LoadAcademies extends PlayerProfileEvent {
  const LoadAcademies();
}

/// Event to create player profile
class CreatePlayerProfile extends PlayerProfileEvent {
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
  final String? academyId;
  final String? academyName;
  final int? jerseyNumber;
  final DateTime? careerStartDate;
  final String? bio;
  final List<String>? achievements;
  final String? agentName;
  final String? agentEmail;
  final String contactEmail;
  final String? phoneNumber;
  final Map<String, String>? socialLinks;
  final String privacyLevel;

  const CreatePlayerProfile({
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
    this.academyId,
    this.academyName,
    this.jerseyNumber,
    this.careerStartDate,
    this.bio,
    this.achievements,
    this.agentName,
    this.agentEmail,
    required this.contactEmail,
    this.phoneNumber,
    this.socialLinks,
    required this.privacyLevel,
  });

  @override
  List<Object?> get props => [
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
        jerseyNumber,
        careerStartDate,
        bio,
        achievements,
        agentName,
        agentEmail,
        contactEmail,
        phoneNumber,
        socialLinks,
        privacyLevel,
      ];
}

/// Event to update player profile
class UpdatePlayerProfile extends PlayerProfileEvent {
  final String profileId;
  final String? firstName;
  final String? lastName;
  final String? nationality;
  final String? city;
  final String? country;
  final String? gender;
  final int? heightCm;
  final int? weightKg;
  final String? preferredFoot;
  final String? primaryPosition;
  final List<String>? secondaryPositions;
  final String? currentClub;
  final String? academyId;
  final String? academyName;
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
  final String? contactEmail;
  final String? phoneNumber;
  final Map<String, String>? socialLinks;
  final String? privacyLevel;

  const UpdatePlayerProfile({
    required this.profileId,
    this.firstName,
    this.lastName,
    this.nationality,
    this.city,
    this.country,
    this.gender,
    this.heightCm,
    this.weightKg,
    this.preferredFoot,
    this.primaryPosition,
    this.secondaryPositions,
    this.currentClub,
    this.academyId,
    this.academyName,
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
    this.contactEmail,
    this.phoneNumber,
    this.socialLinks,
    this.privacyLevel,
  });

  @override
  List<Object?> get props => [
        profileId,
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
      ];
}

/// Event to upload profile photo
class UploadProfilePhoto extends PlayerProfileEvent {
  final File photo;

  const UploadProfilePhoto(this.photo);

  @override
  List<Object?> get props => [photo];
}

/// Event to delete profile photo
class DeleteProfilePhoto extends PlayerProfileEvent {
  const DeleteProfilePhoto();
}

/// Event to upload gallery photo
class UploadGalleryPhoto extends PlayerProfileEvent {
  final File photo;
  final bool isHero;
  final String? caption;

  const UploadGalleryPhoto({
    required this.photo,
    this.isHero = false,
    this.caption,
  });

  @override
  List<Object?> get props => [photo, isHero, caption];
}

/// Event to delete gallery photo
class DeleteGalleryPhoto extends PlayerProfileEvent {
  final String photoId;

  const DeleteGalleryPhoto(this.photoId);

  @override
  List<Object?> get props => [photoId];
}

/// Event to delete video
class DeleteVideo extends PlayerProfileEvent {
  final String videoId;

  const DeleteVideo(this.videoId);

  @override
  List<Object?> get props => [videoId];
}

/// Event to delete hero image
class DeleteHeroImage extends PlayerProfileEvent {
  const DeleteHeroImage();
}

/// Event to update privacy settings
class UpdatePrivacySettings extends PlayerProfileEvent {
  final String privacyLevel;

  const UpdatePrivacySettings(this.privacyLevel);

  @override
  List<Object?> get props => [privacyLevel];
}

/// Event to load player analytics
class LoadPlayerAnalytics extends PlayerProfileEvent {
  const LoadPlayerAnalytics();
}
