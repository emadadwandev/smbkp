import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/usecases/get_scout_profile.dart';
import '../../domain/usecases/create_scout_profile.dart' as create_usecase;
import '../../domain/usecases/update_scout_profile.dart' as update_usecase;
import '../../domain/usecases/upload_verification_documents.dart' as upload_docs_usecase;
import '../../domain/usecases/upload_scout_profile_photo.dart' as upload_photo_usecase;
import 'scout_profile_event.dart';
import 'scout_profile_state.dart';

/// BLoC for managing scout profile state
@injectable
class ScoutProfileBloc extends Bloc<ScoutProfileEvent, ScoutProfileState> {
  final GetScoutProfile getScoutProfile;
  final create_usecase.CreateScoutProfile createScoutProfile;
  final update_usecase.UpdateScoutProfile updateScoutProfile;
  final upload_docs_usecase.UploadVerificationDocuments uploadVerificationDocuments;
  final upload_photo_usecase.UploadScoutProfilePhoto uploadScoutProfilePhoto;

  ScoutProfileBloc({
    required this.getScoutProfile,
    required this.createScoutProfile,
    required this.updateScoutProfile,
    required this.uploadVerificationDocuments,
    required this.uploadScoutProfilePhoto,
  }) : super(const ScoutProfileInitial()) {
    on<LoadScoutProfile>(_onLoadProfile);
    on<CreateScoutProfile>(_onCreateProfile);
    on<UpdateScoutProfile>(_onUpdateProfile);
    on<UploadVerificationDocuments>(_onUploadDocuments);
    on<UploadScoutProfilePhoto>(_onUploadPhoto);
    on<RefreshScoutProfile>(_onRefreshProfile);
  }

  /// Handle load profile event
  Future<void> _onLoadProfile(
    LoadScoutProfile event,
    Emitter<ScoutProfileState> emit,
  ) async {
    emit(const ScoutProfileLoading());

    try {
      final profile = await getScoutProfile();

      if (profile == null) {
        emit(const ScoutProfileNotFound());
      } else if (profile.isPendingVerification) {
        emit(ScoutProfilePendingVerification(profile: profile));
      } else if (profile.isVerificationRejected) {
        emit(ScoutProfileVerificationRejected(
          profile.verificationStatus ?? 'Verification rejected',
        ));
      } else if (profile.isVerified) {
        emit(ScoutProfileVerified(profile));
      } else {
        emit(ScoutProfileLoaded(profile));
      }
    } catch (e) {
      emit(ScoutProfileError(e.toString()));
    }
  }

  /// Handle create profile event
  Future<void> _onCreateProfile(
    CreateScoutProfile event,
    Emitter<ScoutProfileState> emit,
  ) async {
    emit(const ScoutProfileLoading());

    try {
      final profileData = {
        'first_name': event.firstName,
        'last_name': event.lastName,
        if (event.clubName != null) 'club_name': event.clubName,
        if (event.jobTitle != null) 'job_title': event.jobTitle,
        if (event.specializations != null)
          'specializations': event.specializations,
        'country': event.country,
        if (event.leaguesOfInterest != null)
          'leagues_of_interest': event.leaguesOfInterest,
        if (event.certificates != null) 'certificates': event.certificates,
        if (event.bio != null) 'bio': event.bio,
        if (event.contactEmail != null) 'contact_email': event.contactEmail,
        if (event.contactPhone != null) 'contact_phone': event.contactPhone,
        if (event.socialLinks != null) 'social_links': event.socialLinks,
      };

      try {
        final profile = await createScoutProfile(profileData);
        emit(ScoutProfileCreated(profile));
      } catch (e) {
        // If profile already exists (409 Conflict or 400 Bad Request), try updating instead
        if (e.toString().contains('409') || 
            e.toString().contains('400') || 
            e.toString().toLowerCase().contains('already exists')) {
          final profile = await updateScoutProfile(profileData);
          emit(ScoutProfileCreated(profile)); // Treat update as creation success for this flow
        } else {
          rethrow;
        }
      }

      // Auto-reload to get latest state
      add(const LoadScoutProfile());
    } catch (e) {
      emit(ScoutProfileError(e.toString()));
    }
  }

  /// Handle update profile event
  Future<void> _onUpdateProfile(
    UpdateScoutProfile event,
    Emitter<ScoutProfileState> emit,
  ) async {
    emit(const ScoutProfileLoading());

    try {
      final profile = await updateScoutProfile(event.updates);
      emit(ScoutProfileUpdated(profile));

      // Auto-reload to get latest state
      add(const LoadScoutProfile());
    } catch (e) {
      emit(ScoutProfileError(e.toString()));
    }
  }

  /// Handle upload verification documents event
  Future<void> _onUploadDocuments(
    UploadVerificationDocuments event,
    Emitter<ScoutProfileState> emit,
  ) async {
    emit(const UploadingVerificationDocuments(0.0));

    try {
      // Simulate progress updates (in real implementation, this would come from upload progress)
      emit(const UploadingVerificationDocuments(0.3));

      final documentUrls = await uploadVerificationDocuments(event.documents);

      emit(const UploadingVerificationDocuments(1.0));
      emit(VerificationDocumentsUploaded(documentUrls));

      // Auto-reload profile to show updated verification status
      add(const LoadScoutProfile());
    } catch (e) {
      emit(ScoutProfileError(e.toString()));
    }
  }

  /// Handle upload profile photo event
  Future<void> _onUploadPhoto(
    UploadScoutProfilePhoto event,
    Emitter<ScoutProfileState> emit,
  ) async {
    emit(const UploadingScoutProfilePhoto());

    try {
      final profile = await uploadScoutProfilePhoto(event.photo);
      emit(ScoutProfileUpdated(profile));

      // Auto-reload to get latest state
      add(const LoadScoutProfile());
    } catch (e) {
      emit(ScoutProfileError(e.toString()));
    }
  }

  /// Handle refresh profile event (after admin approval)
  Future<void> _onRefreshProfile(
    RefreshScoutProfile event,
    Emitter<ScoutProfileState> emit,
  ) async {
    // Simply trigger load profile
    add(const LoadScoutProfile());
  }
}
