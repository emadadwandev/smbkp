import 'package:equatable/equatable.dart';
import '../../domain/entities/player_profile_entity.dart';
import '../../domain/entities/academy_entity.dart';

/// Base class for all player profile states
abstract class PlayerProfileState extends Equatable {
  const PlayerProfileState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class PlayerProfileInitial extends PlayerProfileState {
  const PlayerProfileInitial();
}

/// Loading state
class PlayerProfileLoading extends PlayerProfileState {
  const PlayerProfileLoading();
}

/// Academies loaded successfully
class AcademiesLoaded extends PlayerProfileState {
  final List<AcademyEntity> academies;

  const AcademiesLoaded(this.academies);

  @override
  List<Object?> get props => [academies];
}

/// Profile loaded successfully
class PlayerProfileLoaded extends PlayerProfileState {
  final PlayerProfileEntity profile;
  final Map<String, dynamic>? analytics;

  const PlayerProfileLoaded(this.profile, {this.analytics});

  @override
  List<Object?> get props => [profile, analytics];
}

/// Profile created successfully
class PlayerProfileCreated extends PlayerProfileState {
  final PlayerProfileEntity profile;

  const PlayerProfileCreated(this.profile);

  @override
  List<Object?> get props => [profile];
}

/// Profile updated successfully
class PlayerProfileUpdated extends PlayerProfileState {
  final PlayerProfileEntity profile;

  const PlayerProfileUpdated(this.profile);

  @override
  List<Object?> get props => [profile];
}

/// Profile photo uploaded successfully
class ProfilePhotoUploaded extends PlayerProfileState {
  final String photoUrl;

  const ProfilePhotoUploaded(this.photoUrl);

  @override
  List<Object?> get props => [photoUrl];
}

/// Profile photo deleted successfully
class ProfilePhotoDeleted extends PlayerProfileState {
  const ProfilePhotoDeleted();
}

/// Gallery photo uploaded successfully
class GalleryPhotoUploaded extends PlayerProfileState {
  final String photoUrl;
  final bool isHero;

  const GalleryPhotoUploaded({
    required this.photoUrl,
    this.isHero = false,
  });

  @override
  List<Object?> get props => [photoUrl, isHero];
}

/// Gallery photo deleted successfully
class GalleryPhotoDeleted extends PlayerProfileState {
  final String photoId;

  const GalleryPhotoDeleted(this.photoId);

  @override
  List<Object?> get props => [photoId];
}

/// Privacy settings updated successfully
class PrivacySettingsUpdated extends PlayerProfileState {
  const PrivacySettingsUpdated();
}

/// Error state
class PlayerProfileError extends PlayerProfileState {
  final String message;
  final String? errorCode;

  const PlayerProfileError({
    required this.message,
    this.errorCode,
  });

  @override
  List<Object?> get props => [message, errorCode];
}

/// Uploading media state (for progress indication)
class UploadingMedia extends PlayerProfileState {
  final double progress; // 0.0 to 1.0
  final String type; // 'profile_photo', 'gallery_photo', 'hero_image'

  const UploadingMedia({
    required this.progress,
    required this.type,
  });

  @override
  List<Object?> get props => [progress, type];
}
