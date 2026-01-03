import 'dart:io';
import 'package:equatable/equatable.dart';

/// Base class for all scout profile events
abstract class ScoutProfileEvent extends Equatable {
  const ScoutProfileEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load scout profile
class LoadScoutProfile extends ScoutProfileEvent {
  const LoadScoutProfile();
}

/// Event to create scout profile
class CreateScoutProfile extends ScoutProfileEvent {
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

  const CreateScoutProfile({
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
  });

  @override
  List<Object?> get props => [
        firstName,
        lastName,
        clubName,
        jobTitle,
        specializations,
        country,
        leaguesOfInterest,
        certificates,
        bio,
        contactEmail,
        contactPhone,
        socialLinks,
      ];
}

/// Event to update scout profile
class UpdateScoutProfile extends ScoutProfileEvent {
  final Map<String, dynamic> updates;

  const UpdateScoutProfile(this.updates);

  @override
  List<Object?> get props => [updates];
}

/// Event to upload verification documents during registration
class UploadVerificationDocuments extends ScoutProfileEvent {
  final List<File> documents;

  const UploadVerificationDocuments(this.documents);

  @override
  List<Object?> get props => [documents];
}

/// Event to upload profile photo
class UploadScoutProfilePhoto extends ScoutProfileEvent {
  final File photo;

  const UploadScoutProfilePhoto(this.photo);

  @override
  List<Object?> get props => [photo];
}

/// Event to delete profile photo
class DeleteScoutProfilePhoto extends ScoutProfileEvent {
  const DeleteScoutProfilePhoto();
}

/// Event to check verification status
class CheckVerificationStatus extends ScoutProfileEvent {
  const CheckVerificationStatus();
}

/// Event to refresh profile (after admin approval)
class RefreshScoutProfile extends ScoutProfileEvent {
  const RefreshScoutProfile();
}
