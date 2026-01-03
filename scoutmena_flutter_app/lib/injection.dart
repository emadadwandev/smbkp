import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/network/api_client.dart';
import 'core/services/academy_service.dart';
import 'core/services/notification_service.dart';
import 'core/services/support_service.dart';
import 'injection.config.dart';

final getIt = GetIt.instance;

@InjectableInit(
  initializerName: 'init',
  preferRelativeImports: true,
  asExtension: true,
)
Future<void> configureDependencies() async {
  await getIt.init();

  // Manual registration since we can't run build_runner in this environment
  if (!getIt.isRegistered<AcademyService>()) {
    getIt.registerLazySingleton(() => AcademyService(getIt<ApiClient>()));
  }

  if (!getIt.isRegistered<NotificationService>()) {
    getIt.registerLazySingleton(
      () => NotificationService(
        getIt<ApiClient>(),
        getIt<FlutterSecureStorage>(),
      ),
    );
  }

  if (!getIt.isRegistered<SupportService>()) {
    getIt.registerLazySingleton(() => SupportService(getIt<ApiClient>()));
  }
}

@module
abstract class RegisterModule {
  @lazySingleton
  FlutterSecureStorage get secureStorage => const FlutterSecureStorage();

  @preResolve
  @lazySingleton
  Future<SharedPreferences> get prefs => SharedPreferences.getInstance();

  @lazySingleton
  ApiClient apiClient(FlutterSecureStorage secureStorage) =>
      ApiClient(secureStorage);
}
