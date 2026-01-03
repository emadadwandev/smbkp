import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/usecases/create_player_profile_usecase.dart';
import '../../domain/usecases/get_player_profile_usecase.dart';
import '../../domain/usecases/update_player_profile_usecase.dart';
import '../../domain/usecases/upload_profile_photo_usecase.dart';
import '../../domain/usecases/upload_gallery_photo_usecase.dart';
import '../../domain/usecases/delete_profile_photo_usecase.dart';
import '../../domain/usecases/delete_hero_image_usecase.dart';
import '../../domain/usecases/delete_gallery_photo_usecase.dart';
import '../../domain/usecases/delete_video_usecase.dart';
import '../../domain/usecases/get_player_analytics_usecase.dart';
import '../../domain/usecases/get_academies_usecase.dart';
import 'player_profile_event.dart';
import 'player_profile_state.dart';

/// BLoC for managing player profile state
@injectable
class PlayerProfileBloc extends Bloc<PlayerProfileEvent, PlayerProfileState> {
  final GetPlayerProfileUseCase getPlayerProfileUseCase;
  final CreatePlayerProfileUseCase createPlayerProfileUseCase;
  final UpdatePlayerProfileUseCase updatePlayerProfileUseCase;
  final UploadProfilePhotoUseCase uploadProfilePhotoUseCase;
  final UploadGalleryPhotoUseCase uploadGalleryPhotoUseCase;
  final DeleteProfilePhotoUseCase deleteProfilePhotoUseCase;
  final DeleteHeroImageUseCase deleteHeroImageUseCase;
  final DeleteGalleryPhotoUseCase deleteGalleryPhotoUseCase;
  final DeleteVideoUseCase deleteVideoUseCase;
  final GetPlayerAnalyticsUseCase getPlayerAnalyticsUseCase;
  final GetAcademiesUseCase getAcademiesUseCase;

  PlayerProfileBloc({
    required this.getPlayerProfileUseCase,
    required this.createPlayerProfileUseCase,
    required this.updatePlayerProfileUseCase,
    required this.uploadProfilePhotoUseCase,
    required this.uploadGalleryPhotoUseCase,
    required this.deleteProfilePhotoUseCase,
    required this.deleteHeroImageUseCase,
    required this.deleteGalleryPhotoUseCase,
    required this.deleteVideoUseCase,
    required this.getPlayerAnalyticsUseCase,
    required this.getAcademiesUseCase,
  }) : super(const PlayerProfileInitial()) {
    on<LoadPlayerProfile>(_onLoadPlayerProfile);
    on<CreatePlayerProfile>(_onCreatePlayerProfile);
    on<UpdatePlayerProfile>(_onUpdatePlayerProfile);
    on<UploadProfilePhoto>(_onUploadProfilePhoto);
    on<UploadGalleryPhoto>(_onUploadGalleryPhoto);
    on<DeleteProfilePhoto>(_onDeleteProfilePhoto);
    on<DeleteHeroImage>(_onDeleteHeroImage);
    on<DeleteGalleryPhoto>(_onDeleteGalleryPhoto);
    on<DeleteVideo>(_onDeleteVideo);
    on<LoadPlayerAnalytics>(_onLoadPlayerAnalytics);
    on<LoadAcademies>(_onLoadAcademies);
  }

  /// Handle load academies event
  Future<void> _onLoadAcademies(
    LoadAcademies event,
    Emitter<PlayerProfileState> emit,
  ) async {
    // Don't emit loading state here to avoid full screen loader if not needed
    // Or emit a specific loading state if UI handles it
    
    final result = await getAcademiesUseCase();

    result.fold(
      (failure) => emit(PlayerProfileError(message: failure.message)),
      (academies) => emit(AcademiesLoaded(academies)),
    );
  }

  /// Handle load player profile event
  Future<void> _onLoadPlayerProfile(
    LoadPlayerProfile event,
    Emitter<PlayerProfileState> emit,
  ) async {
    emit(const PlayerProfileLoading());

    final result = await getPlayerProfileUseCase();

    result.fold(
      (failure) => emit(PlayerProfileError(message: failure.message)),
      (profile) {
        emit(PlayerProfileLoaded(profile));
        add(const LoadPlayerAnalytics());
      },
    );
  }

  /// Handle load player analytics event
  Future<void> _onLoadPlayerAnalytics(
    LoadPlayerAnalytics event,
    Emitter<PlayerProfileState> emit,
  ) async {
    if (state is PlayerProfileLoaded) {
      final currentProfile = (state as PlayerProfileLoaded).profile;
      
      final result = await getPlayerAnalyticsUseCase();
      
      result.fold(
        (failure) {
          // Silently fail or log error, don't disrupt the profile view
          // Or maybe emit a state with error in analytics field?
          // For now, just keep the current state
        },
        (analytics) => emit(PlayerProfileLoaded(currentProfile, analytics: analytics)),
      );
    }
  }

  /// Handle create player profile event
  Future<void> _onCreatePlayerProfile(
    CreatePlayerProfile event,
    Emitter<PlayerProfileState> emit,
  ) async {
    emit(const PlayerProfileLoading());

    final result = await createPlayerProfileUseCase(
      firstName: event.firstName,
      lastName: event.lastName,
      nationality: event.nationality,
      city: event.city,
      country: event.country,
      gender: event.gender,
      heightCm: event.heightCm,
      weightKg: event.weightKg,
      preferredFoot: event.preferredFoot,
      primaryPosition: event.primaryPosition,
      secondaryPositions: event.secondaryPositions,
      currentClub: event.currentClub,
      academyId: event.academyId,
      academyName: event.academyName,
      jerseyNumber: event.jerseyNumber,
      careerStartDate: event.careerStartDate,
      bio: event.bio,
      achievements: event.achievements,
      agentName: event.agentName,
      agentEmail: event.agentEmail,
      contactEmail: event.contactEmail,
      phoneNumber: event.phoneNumber,
      socialLinks: event.socialLinks,
      privacyLevel: event.privacyLevel,
    );

    result.fold(
      (failure) => emit(PlayerProfileError(message: failure.message)),
      (profile) => emit(PlayerProfileCreated(profile)),
    );
  }

  /// Handle update player profile event
  Future<void> _onUpdatePlayerProfile(
    UpdatePlayerProfile event,
    Emitter<PlayerProfileState> emit,
  ) async {
    emit(const PlayerProfileLoading());

    final result = await updatePlayerProfileUseCase(
      profileId: event.profileId,
      firstName: event.firstName,
      lastName: event.lastName,
      nationality: event.nationality,
      city: event.city,
      country: event.country,
      gender: event.gender,
      heightCm: event.heightCm,
      weightKg: event.weightKg,
      preferredFoot: event.preferredFoot,
      primaryPosition: event.primaryPosition,
      secondaryPositions: event.secondaryPositions,
      currentClub: event.currentClub,
      academyId: event.academyId,
      academyName: event.academyName,
      careerHistory: event.careerHistory,
      jerseyNumber: event.jerseyNumber,
      careerStartDate: event.careerStartDate,
      bio: event.bio,
      achievements: event.achievements,
      trainingData: event.trainingData,
      technicalData: event.technicalData,
      tacticalData: event.tacticalData,
      physicalData: event.physicalData,
      agentName: event.agentName,
      agentEmail: event.agentEmail,
      contactEmail: event.contactEmail,
      phoneNumber: event.phoneNumber,
      socialLinks: event.socialLinks,
      privacyLevel: event.privacyLevel,
    );

    result.fold(
      (failure) => emit(PlayerProfileError(message: failure.message)),
      (profile) => emit(PlayerProfileUpdated(profile)),
    );
  }

  /// Handle upload profile photo event
  Future<void> _onUploadProfilePhoto(
    UploadProfilePhoto event,
    Emitter<PlayerProfileState> emit,
  ) async {
    emit(const UploadingMedia(progress: 0.0, type: 'profile_photo'));

    final result = await uploadProfilePhotoUseCase(event.photo);

    result.fold(
      (failure) => emit(PlayerProfileError(message: failure.message)),
      (photoUrl) {
        emit(ProfilePhotoUploaded(photoUrl));
        // Reload profile to get updated data
        add(const LoadPlayerProfile());
      },
    );
  }

  /// Handle upload gallery photo event
  Future<void> _onUploadGalleryPhoto(
    UploadGalleryPhoto event,
    Emitter<PlayerProfileState> emit,
  ) async {
    final mediaType = event.isHero ? 'hero_image' : 'gallery_photo';
    emit(UploadingMedia(progress: 0.0, type: mediaType));

    final result = await uploadGalleryPhotoUseCase(
      photo: event.photo,
      isHero: event.isHero,
      caption: event.caption,
    );

    result.fold(
      (failure) => emit(PlayerProfileError(message: failure.message)),
      (photoUrl) {
        emit(GalleryPhotoUploaded(photoUrl: photoUrl, isHero: event.isHero));
        // Reload profile to get updated data
        add(const LoadPlayerProfile());
      },
    );
  }

  /// Handle delete profile photo event
  Future<void> _onDeleteProfilePhoto(
    DeleteProfilePhoto event,
    Emitter<PlayerProfileState> emit,
  ) async {
    emit(const PlayerProfileLoading());

    final result = await deleteProfilePhotoUseCase();

    result.fold(
      (failure) => emit(PlayerProfileError(message: failure.message)),
      (_) {
        // Reload profile to get updated data
        add(const LoadPlayerProfile());
      },
    );
  }

  /// Handle delete hero image event
  Future<void> _onDeleteHeroImage(
    DeleteHeroImage event,
    Emitter<PlayerProfileState> emit,
  ) async {
    emit(const PlayerProfileLoading());

    final result = await deleteHeroImageUseCase();

    result.fold(
      (failure) => emit(PlayerProfileError(message: failure.message)),
      (_) {
        // Reload profile to get updated data
        add(const LoadPlayerProfile());
      },
    );
  }

  /// Handle delete gallery photo event
  Future<void> _onDeleteGalleryPhoto(
    DeleteGalleryPhoto event,
    Emitter<PlayerProfileState> emit,
  ) async {
    emit(const PlayerProfileLoading());

    final result = await deleteGalleryPhotoUseCase(event.photoId);

    result.fold(
      (failure) => emit(PlayerProfileError(message: failure.message)),
      (_) {
        // Reload profile to get updated data
        add(const LoadPlayerProfile());
      },
    );
  }

  /// Handle delete video event
  Future<void> _onDeleteVideo(
    DeleteVideo event,
    Emitter<PlayerProfileState> emit,
  ) async {
    emit(const PlayerProfileLoading());

    final result = await deleteVideoUseCase(event.videoId);

    result.fold(
      (failure) => emit(PlayerProfileError(message: failure.message)),
      (_) {
        // Reload profile to get updated data
        add(const LoadPlayerProfile());
      },
    );
  }
}
