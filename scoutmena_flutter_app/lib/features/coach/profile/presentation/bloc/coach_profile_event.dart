import 'dart:io';
import 'package:equatable/equatable.dart';

/// Events for coach profile management
abstract class CoachProfileEvent extends Equatable {
  const CoachProfileEvent();

  @override
  List<Object?> get props => [];
}

/// Event: Load coach profile
class LoadCoachProfile extends CoachProfileEvent {
  const LoadCoachProfile();
}

/// Event: Create new coach profile
class CreateCoachProfile extends CoachProfileEvent {
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

  const CreateCoachProfile({
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
  });

  @override
  List<Object?> get props => [
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
      ];
}

/// Event: Update coach profile
class UpdateCoachProfile extends CoachProfileEvent {
  final Map<String, dynamic> updates;

  const UpdateCoachProfile(this.updates);

  @override
  List<Object?> get props => [updates];
}

/// Event: Upload profile photo
class UploadCoachProfilePhoto extends CoachProfileEvent {
  final File photo;

  const UploadCoachProfilePhoto(this.photo);

  @override
  List<Object?> get props => [photo];
}

/// Event: Delete profile photo
class DeleteCoachProfilePhoto extends CoachProfileEvent {
  const DeleteCoachProfilePhoto();
}

/// Event: Upload verification documents
class UploadCoachVerificationDocuments extends CoachProfileEvent {
  final List<File> documents;

  const UploadCoachVerificationDocuments(this.documents);

  @override
  List<Object?> get props => [documents];
}

/// Event: Check verification status
class CheckCoachVerificationStatus extends CoachProfileEvent {
  const CheckCoachVerificationStatus();
}

/// Event: Refresh profile
class RefreshCoachProfile extends CoachProfileEvent {
  const RefreshCoachProfile();
}
