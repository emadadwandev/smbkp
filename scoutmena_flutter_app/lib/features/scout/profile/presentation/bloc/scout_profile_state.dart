import 'package:equatable/equatable.dart';
import '../../domain/entities/scout_profile_entity.dart';

/// Base class for all scout profile states
abstract class ScoutProfileState extends Equatable {
  const ScoutProfileState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class ScoutProfileInitial extends ScoutProfileState {
  const ScoutProfileInitial();
}

/// Loading state
class ScoutProfileLoading extends ScoutProfileState {
  const ScoutProfileLoading();
}

/// Profile loaded successfully
class ScoutProfileLoaded extends ScoutProfileState {
  final ScoutProfileEntity profile;

  const ScoutProfileLoaded(this.profile);

  @override
  List<Object?> get props => [profile];
}

/// Profile doesn't exist (not created yet)
class ScoutProfileNotFound extends ScoutProfileState {
  const ScoutProfileNotFound();
}

/// Uploading verification documents
class UploadingVerificationDocuments extends ScoutProfileState {
  final double progress;

  const UploadingVerificationDocuments(this.progress);

  @override
  List<Object?> get props => [progress];
}

/// Verification documents uploaded successfully
class VerificationDocumentsUploaded extends ScoutProfileState {
  final List<String> documentUrls;

  const VerificationDocumentsUploaded(this.documentUrls);

  @override
  List<Object?> get props => [documentUrls];
}

/// Uploading profile photo
class UploadingScoutProfilePhoto extends ScoutProfileState {
  const UploadingScoutProfilePhoto();
}

/// Profile created successfully
class ScoutProfileCreated extends ScoutProfileState {
  final ScoutProfileEntity profile;

  const ScoutProfileCreated(this.profile);

  @override
  List<Object?> get props => [profile];
}

/// Profile updated successfully
class ScoutProfileUpdated extends ScoutProfileState {
  final ScoutProfileEntity profile;

  const ScoutProfileUpdated(this.profile);

  @override
  List<Object?> get props => [profile];
}

/// Verification status checked
class VerificationStatusChecked extends ScoutProfileState {
  final Map<String, dynamic> verificationData;

  const VerificationStatusChecked(this.verificationData);

  @override
  List<Object?> get props => [verificationData];
}

/// Profile is pending verification (awaiting admin approval)
class ScoutProfilePendingVerification extends ScoutProfileState {
  final ScoutProfileEntity profile;
  final String message;

  const ScoutProfilePendingVerification({
    required this.profile,
    this.message = 'Your account is under verification. You will be notified once approved.',
  });

  @override
  List<Object?> get props => [profile, message];
}

/// Profile verification rejected
class ScoutProfileVerificationRejected extends ScoutProfileState {
  final String reason;

  const ScoutProfileVerificationRejected(this.reason);

  @override
  List<Object?> get props => [reason];
}

/// Profile verified and active
class ScoutProfileVerified extends ScoutProfileState {
  final ScoutProfileEntity profile;

  const ScoutProfileVerified(this.profile);

  @override
  List<Object?> get props => [profile];
}

/// Error state
class ScoutProfileError extends ScoutProfileState {
  final String message;

  const ScoutProfileError(this.message);

  @override
  List<Object?> get props => [message];
}
