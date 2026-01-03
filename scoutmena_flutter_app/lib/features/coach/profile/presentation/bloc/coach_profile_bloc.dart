import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/usecases/create_coach_profile.dart' as create;
import '../../domain/usecases/get_coach_profile.dart';
import '../../domain/usecases/update_coach_profile.dart' as update;
import '../../domain/usecases/upload_coach_profile_photo.dart' as upload_photo;
import '../../domain/usecases/upload_coach_verification_documents.dart' as upload_docs;
import 'coach_profile_event.dart';
import 'coach_profile_state.dart';

/// BLoC for managing coach profile state
@injectable
class CoachProfileBloc extends Bloc<CoachProfileEvent, CoachProfileState> {
  final GetCoachProfile getCoachProfile;
  final create.CreateCoachProfile createCoachProfile;
  final update.UpdateCoachProfile updateCoachProfile;
  final upload_photo.UploadCoachProfilePhoto uploadCoachProfilePhoto;
  final upload_docs.UploadCoachVerificationDocuments uploadVerificationDocuments;

  CoachProfileBloc({
    required this.getCoachProfile,
    required this.createCoachProfile,
    required this.updateCoachProfile,
    required this.uploadCoachProfilePhoto,
    required this.uploadVerificationDocuments,
  }) : super(const CoachProfileInitial()) {
    on<LoadCoachProfile>(_onLoadProfile);
    on<CreateCoachProfile>(_onCreateProfile);
    on<UpdateCoachProfile>(_onUpdateProfile);
    on<UploadCoachProfilePhoto>(_onUploadPhoto);
    on<UploadCoachVerificationDocuments>(_onUploadDocuments);
    on<CheckCoachVerificationStatus>(_onCheckVerificationStatus);
    on<RefreshCoachProfile>(_onRefreshProfile);
  }

  /// Handle load profile event
  Future<void> _onLoadProfile(
    LoadCoachProfile event,
    Emitter<CoachProfileState> emit,
  ) async {
    try {
      emit(const CoachProfileLoading());

      final profile = await getCoachProfile();

      if (profile == null) {
        emit(const CoachProfileNotFound());
      } else if (profile.isPendingVerification) {
        emit(CoachProfilePendingVerification(
          profile,
          'Your account is under verification. We\'re reviewing your documents.',
        ));
      } else if (profile.isVerificationRejected) {
        emit(const CoachVerificationRejected(
          'Your verification documents were rejected. Please resubmit.',
        ));
      } else if (profile.isVerified) {
        emit(CoachProfileVerified(profile));
      } else {
        emit(CoachProfileLoaded(profile));
      }
    } catch (e) {
      emit(CoachProfileError(e.toString()));
    }
  }

  /// Handle create profile event
  Future<void> _onCreateProfile(
    CreateCoachProfile event,
    Emitter<CoachProfileState> emit,
  ) async {
    try {
      emit(const CoachProfileLoading());

      // Convert event data to map
      final profileData = {
        'first_name': event.firstName,
        'last_name': event.lastName,
        'club_name': event.clubName,
        'current_role': event.currentRole,
        'coaching_license': event.coachingLicense,
        'years_of_experience': event.yearsOfExperience,
        if (event.specializations != null)
          'specializations': event.specializations,
        if (event.bio != null) 'bio': event.bio,
        'country': event.country,
        if (event.city != null) 'city': event.city,
        if (event.contactEmail != null) 'contact_email': event.contactEmail,
        if (event.contactPhone != null) 'contact_phone': event.contactPhone,
        if (event.socialLinks != null) 'social_links': event.socialLinks,
      };

      try {
        final profile = await createCoachProfile(profileData);
        emit(CoachProfileCreated(profile));
      } catch (e) {
        // If profile already exists (409 Conflict or 400 Bad Request), try updating instead
        if (e.toString().contains('409') || 
            e.toString().contains('400') || 
            e.toString().toLowerCase().contains('already exists')) {
          final profile = await updateCoachProfile(profileData);
          emit(CoachProfileCreated(profile)); // Treat update as creation success for this flow
        } else {
          rethrow;
        }
      }

      // Auto-reload profile after creation
      add(const LoadCoachProfile());
    } on create.ValidationException catch (e) {
      emit(CoachProfileError(e.message));
    } catch (e) {
      emit(CoachProfileError('Failed to create profile: $e'));
    }
  }

  /// Handle update profile event
  Future<void> _onUpdateProfile(
    UpdateCoachProfile event,
    Emitter<CoachProfileState> emit,
  ) async {
    try {
      emit(const CoachProfileLoading());

      final profile = await updateCoachProfile(event.updates);

      emit(CoachProfileUpdated(profile));

      // Auto-reload profile after update
      add(const LoadCoachProfile());
    } on update.ValidationException catch (e) {
      emit(CoachProfileError(e.message));
    } catch (e) {
      emit(CoachProfileError('Failed to update profile: $e'));
    }
  }

  /// Handle upload photo event
  Future<void> _onUploadPhoto(
    UploadCoachProfilePhoto event,
    Emitter<CoachProfileState> emit,
  ) async {
    try {
      emit(const UploadingCoachProfilePhoto());

      final profile = await uploadCoachProfilePhoto(event.photo);

      emit(CoachProfileUpdated(profile));

      // Auto-reload profile after photo upload
      add(const LoadCoachProfile());
    } catch (e) {
      emit(CoachProfileError('Failed to upload photo: $e'));
    }
  }

  /// Handle refresh profile event
  Future<void> _onRefreshProfile(
    RefreshCoachProfile event,
    Emitter<CoachProfileState> emit,
  ) async {
    add(const LoadCoachProfile());
  }

  /// Handle upload verification documents event
  Future<void> _onUploadDocuments(
    UploadCoachVerificationDocuments event,
    Emitter<CoachProfileState> emit,
  ) async {
    try {
      // Show upload progress
      emit(const UploadingCoachVerificationDocuments(0.0));
      
      // Simulate initial progress
      await Future.delayed(const Duration(milliseconds: 300));
      emit(const UploadingCoachVerificationDocuments(0.3));

      // Upload documents
      final documentUrls = await uploadVerificationDocuments(event.documents);

      // Show completion progress
      emit(const UploadingCoachVerificationDocuments(1.0));
      await Future.delayed(const Duration(milliseconds: 300));

      emit(CoachVerificationDocumentsUploaded(documentUrls));

      // Auto-reload profile after upload
      add(const LoadCoachProfile());
    } on upload_docs.ValidationException catch (e) {
      emit(CoachProfileError(e.message));
    } catch (e) {
      emit(CoachProfileError('Failed to upload documents: $e'));
    }
  }

  /// Handle check verification status event
  Future<void> _onCheckVerificationStatus(
    CheckCoachVerificationStatus event,
    Emitter<CoachProfileState> emit,
  ) async {
    try {
      // This would call repository method to get verification status
      // For now, just reload the profile
      add(const LoadCoachProfile());
    } catch (e) {
      emit(CoachProfileError('Failed to check verification status: $e'));
    }
  }
}
