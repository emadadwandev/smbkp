// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i558;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:shared_preferences/shared_preferences.dart' as _i460;

import 'core/network/api_client.dart' as _i871;
import 'core/services/academy_service.dart' as _i1070;
import 'core/services/auth_service.dart' as _i630;
import 'core/services/firebase_service.dart' as _i891;
import 'core/services/notification_service.dart' as _i1011;
import 'core/services/otp_service.dart' as _i718;
import 'core/services/player_service.dart' as _i116;
import 'core/services/player_stats_service.dart' as _i233;
import 'core/services/scout_service.dart' as _i748;
import 'features/authentication/data/repositories/auth_repository_impl.dart'
    as _i446;
import 'features/authentication/domain/repositories/auth_repository.dart'
    as _i877;
import 'features/coach/profile/data/repositories/coach_profile_repository_impl.dart'
    as _i208;
import 'features/coach/profile/domain/repositories/coach_profile_repository.dart'
    as _i6;
import 'features/coach/profile/domain/usecases/create_coach_profile.dart'
    as _i153;
import 'features/coach/profile/domain/usecases/get_coach_profile.dart' as _i206;
import 'features/coach/profile/domain/usecases/update_coach_profile.dart'
    as _i293;
import 'features/coach/profile/domain/usecases/upload_coach_profile_photo.dart'
    as _i311;
import 'features/coach/profile/domain/usecases/upload_coach_verification_documents.dart'
    as _i526;
import 'features/coach/profile/presentation/bloc/coach_profile_bloc.dart'
    as _i882;
import 'features/player/profile/data/repositories/player_match_repository_impl.dart'
    as _i334;
import 'features/player/profile/data/repositories/player_profile_repository_impl.dart'
    as _i249;
import 'features/player/profile/domain/repositories/player_match_repository.dart'
    as _i557;
import 'features/player/profile/domain/repositories/player_profile_repository.dart'
    as _i315;
import 'features/player/profile/domain/usecases/add_player_match_stat_usecase.dart'
    as _i420;
import 'features/player/profile/domain/usecases/create_player_profile_usecase.dart'
    as _i735;
import 'features/player/profile/domain/usecases/delete_gallery_photo_usecase.dart'
    as _i49;
import 'features/player/profile/domain/usecases/delete_hero_image_usecase.dart'
    as _i43;
import 'features/player/profile/domain/usecases/delete_player_match_stat_usecase.dart'
    as _i315;
import 'features/player/profile/domain/usecases/delete_profile_photo_usecase.dart'
    as _i825;
import 'features/player/profile/domain/usecases/delete_video_usecase.dart'
    as _i999;
import 'features/player/profile/domain/usecases/get_academies_usecase.dart'
    as _i976;
import 'features/player/profile/domain/usecases/get_player_analytics_usecase.dart'
    as _i935;
import 'features/player/profile/domain/usecases/get_player_match_stats_usecase.dart'
    as _i524;
import 'features/player/profile/domain/usecases/get_player_profile_usecase.dart'
    as _i1016;
import 'features/player/profile/domain/usecases/update_player_match_stat_usecase.dart'
    as _i1025;
import 'features/player/profile/domain/usecases/update_player_profile_usecase.dart'
    as _i342;
import 'features/player/profile/domain/usecases/upload_gallery_photo_usecase.dart'
    as _i835;
import 'features/player/profile/domain/usecases/upload_profile_photo_usecase.dart'
    as _i1069;
import 'features/player/profile/presentation/bloc/player_match_stats_bloc.dart'
    as _i1042;
import 'features/player/profile/presentation/bloc/player_profile_bloc.dart'
    as _i1002;
import 'features/scout/profile/data/repositories/scout_profile_repository_impl.dart'
    as _i321;
import 'features/scout/profile/domain/repositories/scout_profile_repository.dart'
    as _i87;
import 'features/scout/profile/domain/usecases/create_scout_profile.dart'
    as _i6;
import 'features/scout/profile/domain/usecases/get_scout_profile.dart' as _i785;
import 'features/scout/profile/domain/usecases/update_scout_profile.dart'
    as _i820;
import 'features/scout/profile/domain/usecases/upload_scout_profile_photo.dart'
    as _i791;
import 'features/scout/profile/domain/usecases/upload_verification_documents.dart'
    as _i280;
import 'features/scout/profile/presentation/bloc/scout_profile_bloc.dart'
    as _i214;
import 'injection.dart' as _i464;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final registerModule = _$RegisterModule();
    gh.lazySingleton<_i891.FirebaseService>(() => _i891.FirebaseService());
    gh.lazySingleton<_i558.FlutterSecureStorage>(
      () => registerModule.secureStorage,
    );
    await gh.lazySingletonAsync<_i460.SharedPreferences>(
      () => registerModule.prefs,
      preResolve: true,
    );
    gh.lazySingleton<_i871.ApiClient>(
      () => registerModule.apiClient(gh<_i558.FlutterSecureStorage>()),
    );
    gh.lazySingleton<_i87.ScoutProfileRepository>(
      () => _i321.ScoutProfileRepositoryImpl(gh<_i871.ApiClient>()),
    );
    gh.lazySingleton<_i557.PlayerMatchRepository>(
      () => _i334.PlayerMatchRepositoryImpl(gh<_i871.ApiClient>()),
    );
    gh.lazySingleton<_i630.AuthService>(
      () => _i630.AuthService(
        gh<_i871.ApiClient>(),
        gh<_i558.FlutterSecureStorage>(),
      ),
    );
    gh.lazySingleton<_i1011.NotificationService>(
      () => _i1011.NotificationService(
        gh<_i871.ApiClient>(),
        gh<_i558.FlutterSecureStorage>(),
      ),
    );
    gh.factory<_i6.CreateScoutProfile>(
      () => _i6.CreateScoutProfile(gh<_i87.ScoutProfileRepository>()),
    );
    gh.factory<_i785.GetScoutProfile>(
      () => _i785.GetScoutProfile(gh<_i87.ScoutProfileRepository>()),
    );
    gh.factory<_i820.UpdateScoutProfile>(
      () => _i820.UpdateScoutProfile(gh<_i87.ScoutProfileRepository>()),
    );
    gh.factory<_i791.UploadScoutProfilePhoto>(
      () => _i791.UploadScoutProfilePhoto(gh<_i87.ScoutProfileRepository>()),
    );
    gh.factory<_i280.UploadVerificationDocuments>(
      () =>
          _i280.UploadVerificationDocuments(gh<_i87.ScoutProfileRepository>()),
    );
    gh.factory<_i214.ScoutProfileBloc>(
      () => _i214.ScoutProfileBloc(
        getScoutProfile: gh<_i785.GetScoutProfile>(),
        createScoutProfile: gh<_i6.CreateScoutProfile>(),
        updateScoutProfile: gh<_i820.UpdateScoutProfile>(),
        uploadVerificationDocuments: gh<_i280.UploadVerificationDocuments>(),
        uploadScoutProfilePhoto: gh<_i791.UploadScoutProfilePhoto>(),
      ),
    );
    gh.lazySingleton<_i315.PlayerProfileRepository>(
      () => _i249.PlayerProfileRepositoryImpl(gh<_i871.ApiClient>()),
    );
    gh.lazySingleton<_i1070.AcademyService>(
      () => _i1070.AcademyService(gh<_i871.ApiClient>()),
    );
    gh.lazySingleton<_i718.OtpService>(
      () => _i718.OtpService(gh<_i871.ApiClient>()),
    );
    gh.lazySingleton<_i116.PlayerService>(
      () => _i116.PlayerService(gh<_i871.ApiClient>()),
    );
    gh.lazySingleton<_i233.PlayerStatsService>(
      () => _i233.PlayerStatsService(gh<_i871.ApiClient>()),
    );
    gh.lazySingleton<_i748.ScoutService>(
      () => _i748.ScoutService(gh<_i871.ApiClient>()),
    );
    gh.lazySingleton<_i6.CoachProfileRepository>(
      () => _i208.CoachProfileRepositoryImpl(gh<_i871.ApiClient>()),
    );
    gh.factory<_i420.AddPlayerMatchStatUseCase>(
      () => _i420.AddPlayerMatchStatUseCase(gh<_i557.PlayerMatchRepository>()),
    );
    gh.factory<_i315.DeletePlayerMatchStatUseCase>(
      () =>
          _i315.DeletePlayerMatchStatUseCase(gh<_i557.PlayerMatchRepository>()),
    );
    gh.factory<_i524.GetPlayerMatchStatsUseCase>(
      () => _i524.GetPlayerMatchStatsUseCase(gh<_i557.PlayerMatchRepository>()),
    );
    gh.factory<_i1025.UpdatePlayerMatchStatUseCase>(
      () => _i1025.UpdatePlayerMatchStatUseCase(
        gh<_i557.PlayerMatchRepository>(),
      ),
    );
    gh.lazySingleton<_i877.AuthRepository>(
      () => _i446.AuthRepositoryImpl(
        gh<_i718.OtpService>(),
        gh<_i558.FlutterSecureStorage>(),
        gh<_i630.AuthService>(),
        gh<_i871.ApiClient>(),
      ),
    );
    gh.factory<_i1042.PlayerMatchStatsBloc>(
      () => _i1042.PlayerMatchStatsBloc(
        getPlayerMatchStatsUseCase: gh<_i524.GetPlayerMatchStatsUseCase>(),
        addPlayerMatchStatUseCase: gh<_i420.AddPlayerMatchStatUseCase>(),
        updatePlayerMatchStatUseCase: gh<_i1025.UpdatePlayerMatchStatUseCase>(),
        deletePlayerMatchStatUseCase: gh<_i315.DeletePlayerMatchStatUseCase>(),
      ),
    );
    gh.lazySingleton<_i49.DeleteGalleryPhotoUseCase>(
      () => _i49.DeleteGalleryPhotoUseCase(gh<_i315.PlayerProfileRepository>()),
    );
    gh.lazySingleton<_i43.DeleteHeroImageUseCase>(
      () => _i43.DeleteHeroImageUseCase(gh<_i315.PlayerProfileRepository>()),
    );
    gh.lazySingleton<_i825.DeleteProfilePhotoUseCase>(
      () =>
          _i825.DeleteProfilePhotoUseCase(gh<_i315.PlayerProfileRepository>()),
    );
    gh.lazySingleton<_i999.DeleteVideoUseCase>(
      () => _i999.DeleteVideoUseCase(gh<_i315.PlayerProfileRepository>()),
    );
    gh.lazySingleton<_i976.GetAcademiesUseCase>(
      () => _i976.GetAcademiesUseCase(gh<_i315.PlayerProfileRepository>()),
    );
    gh.factory<_i735.CreatePlayerProfileUseCase>(
      () =>
          _i735.CreatePlayerProfileUseCase(gh<_i315.PlayerProfileRepository>()),
    );
    gh.factory<_i935.GetPlayerAnalyticsUseCase>(
      () =>
          _i935.GetPlayerAnalyticsUseCase(gh<_i315.PlayerProfileRepository>()),
    );
    gh.factory<_i1016.GetPlayerProfileUseCase>(
      () => _i1016.GetPlayerProfileUseCase(gh<_i315.PlayerProfileRepository>()),
    );
    gh.factory<_i342.UpdatePlayerProfileUseCase>(
      () =>
          _i342.UpdatePlayerProfileUseCase(gh<_i315.PlayerProfileRepository>()),
    );
    gh.factory<_i835.UploadGalleryPhotoUseCase>(
      () =>
          _i835.UploadGalleryPhotoUseCase(gh<_i315.PlayerProfileRepository>()),
    );
    gh.factory<_i1069.UploadProfilePhotoUseCase>(
      () =>
          _i1069.UploadProfilePhotoUseCase(gh<_i315.PlayerProfileRepository>()),
    );
    gh.factory<_i153.CreateCoachProfile>(
      () => _i153.CreateCoachProfile(gh<_i6.CoachProfileRepository>()),
    );
    gh.factory<_i206.GetCoachProfile>(
      () => _i206.GetCoachProfile(gh<_i6.CoachProfileRepository>()),
    );
    gh.factory<_i293.UpdateCoachProfile>(
      () => _i293.UpdateCoachProfile(gh<_i6.CoachProfileRepository>()),
    );
    gh.factory<_i311.UploadCoachProfilePhoto>(
      () => _i311.UploadCoachProfilePhoto(gh<_i6.CoachProfileRepository>()),
    );
    gh.factory<_i526.UploadCoachVerificationDocuments>(
      () => _i526.UploadCoachVerificationDocuments(
        gh<_i6.CoachProfileRepository>(),
      ),
    );
    gh.factory<_i882.CoachProfileBloc>(
      () => _i882.CoachProfileBloc(
        getCoachProfile: gh<_i206.GetCoachProfile>(),
        createCoachProfile: gh<_i153.CreateCoachProfile>(),
        updateCoachProfile: gh<_i293.UpdateCoachProfile>(),
        uploadCoachProfilePhoto: gh<_i311.UploadCoachProfilePhoto>(),
        uploadVerificationDocuments:
            gh<_i526.UploadCoachVerificationDocuments>(),
      ),
    );
    gh.factory<_i1002.PlayerProfileBloc>(
      () => _i1002.PlayerProfileBloc(
        getPlayerProfileUseCase: gh<_i1016.GetPlayerProfileUseCase>(),
        createPlayerProfileUseCase: gh<_i735.CreatePlayerProfileUseCase>(),
        updatePlayerProfileUseCase: gh<_i342.UpdatePlayerProfileUseCase>(),
        uploadProfilePhotoUseCase: gh<_i1069.UploadProfilePhotoUseCase>(),
        uploadGalleryPhotoUseCase: gh<_i835.UploadGalleryPhotoUseCase>(),
        deleteProfilePhotoUseCase: gh<_i825.DeleteProfilePhotoUseCase>(),
        deleteHeroImageUseCase: gh<_i43.DeleteHeroImageUseCase>(),
        deleteGalleryPhotoUseCase: gh<_i49.DeleteGalleryPhotoUseCase>(),
        deleteVideoUseCase: gh<_i999.DeleteVideoUseCase>(),
        getPlayerAnalyticsUseCase: gh<_i935.GetPlayerAnalyticsUseCase>(),
        getAcademiesUseCase: gh<_i976.GetAcademiesUseCase>(),
      ),
    );
    return this;
  }
}

class _$RegisterModule extends _i464.RegisterModule {}
