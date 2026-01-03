import 'package:equatable/equatable.dart';
import '../../domain/entities/coach_profile_entity.dart';

/// States for coach profile management
abstract class CoachProfileState extends Equatable {
  const CoachProfileState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class CoachProfileInitial extends CoachProfileState {
  const CoachProfileInitial();
}

/// Loading state
class CoachProfileLoading extends CoachProfileState {
  const CoachProfileLoading();
}

/// Profile loaded successfully
class CoachProfileLoaded extends CoachProfileState {
  final CoachProfileEntity profile;

  const CoachProfileLoaded(this.profile);

  @override
  List<Object?> get props => [profile];
}

/// Profile not found (needs creation)
class CoachProfileNotFound extends CoachProfileState {
  const CoachProfileNotFound();
}

/// Profile created successfully
class CoachProfileCreated extends CoachProfileLoaded {
  const CoachProfileCreated(super.profile);
}

/// Profile updated successfully
class CoachProfileUpdated extends CoachProfileLoaded {
  const CoachProfileUpdated(super.profile);
}

/// Uploading profile photo
class UploadingCoachProfilePhoto extends CoachProfileState {
  const UploadingCoachProfilePhoto();
}

/// Uploading verification documents
class UploadingCoachVerificationDocuments extends CoachProfileState {
  final double progress;

  const UploadingCoachVerificationDocuments(this.progress);

  @override
  List<Object?> get props => [progress];
}

/// Verification documents uploaded successfully
class CoachVerificationDocumentsUploaded extends CoachProfileState {
  final List<String> documentUrls;

  const CoachVerificationDocumentsUploaded(this.documentUrls);

  @override
  List<Object?> get props => [documentUrls];
}

/// Verification status checked
class CoachVerificationStatusChecked extends CoachProfileState {
  final Map<String, dynamic> verificationData;

  const CoachVerificationStatusChecked(this.verificationData);

  @override
  List<Object?> get props => [verificationData];
}

/// Profile pending verification
class CoachProfilePendingVerification extends CoachProfileState {
  final CoachProfileEntity profile;
  final String message;

  const CoachProfilePendingVerification(this.profile, this.message);

  @override
  List<Object?> get props => [profile, message];
}

/// Verification rejected
class CoachVerificationRejected extends CoachProfileState {
  final String reason;

  const CoachVerificationRejected(this.reason);

  @override
  List<Object?> get props => [reason];
}

/// Profile verified
class CoachProfileVerified extends CoachProfileLoaded {
  const CoachProfileVerified(super.profile);
}

/// Error state
class CoachProfileError extends CoachProfileState {
  final String message;

  const CoachProfileError(this.message);

  @override
  List<Object?> get props => [message];
}
