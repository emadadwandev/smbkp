import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'injection.dart';
import 'app/routes.dart';
import 'core/themes/app_themes.dart';
import 'core/themes/app_text_styles.dart';
import 'features/splash/presentation/splash_screen.dart';
import 'features/onboarding/presentation/onboarding_screen.dart';
import 'features/authentication/presentation/pages/auth_main_screen.dart';
import 'features/authentication/presentation/pages/login_screen.dart';
import 'features/authentication/presentation/pages/phone_login_screen.dart';
import 'features/authentication/presentation/pages/forgot_password_screen.dart';
import 'features/authentication/presentation/pages/role_selection_screen.dart';
import 'features/authentication/presentation/pages/otp_verification_screen.dart';
import 'features/authentication/presentation/pages/registration_screen.dart';
import 'features/authentication/presentation/pages/awaiting_consent_screen.dart';
import 'features/auth/presentation/pages/verification_documents_screen.dart';
import 'features/auth/presentation/pages/verification_pending_screen.dart';
import 'features/splash/presentation/backend_test_screen.dart';
import 'features/player/dashboard/presentation/pages/player_dashboard_screen.dart';
import 'features/coach/dashboard/presentation/pages/coach_dashboard_screen.dart';
import 'features/player/profile/presentation/bloc/player_profile_bloc.dart';
import 'features/player/profile/presentation/pages/profile_creation_screen.dart';
import 'features/scout/profile/presentation/bloc/scout_profile_bloc.dart';
import 'features/scout/dashboard/presentation/pages/scout_dashboard_screen.dart';
import 'features/coach/profile/presentation/bloc/coach_profile_bloc.dart';
import 'features/scout/profile/presentation/pages/scout_profile_setup_screen.dart';
import 'features/coach/profile/presentation/pages/coach_profile_setup_screen.dart';
import 'features/player/dashboard/presentation/pages/contact_requests_screen.dart';
import 'features/shared/presentation/pages/notifications_screen.dart';
import 'core/themes/theme_cubit.dart';
import 'features/settings/presentation/pages/settings_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/services/firebase_service.dart';
import 'core/services/notification_service.dart';
import 'features/coach/profile/presentation/pages/coach_edit_profile_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  try {
    await Firebase.initializeApp();
    print('✅ Firebase initialized successfully');
  } catch (e) {
    print('⚠️ Firebase initialization failed: $e');
    print('Note: Make sure google-services.json (Android) and GoogleService-Info.plist (iOS) are configured');
  }
  
  // Initialize EasyLocalization
  await EasyLocalization.ensureInitialized();
  
  // Initialize Dependency Injection
  await configureDependencies();

  // Setup Notifications
  try {
    final firebaseService = getIt<FirebaseService>();
    await firebaseService.requestNotificationPermission();
    
    // Register device with backend
    final notificationService = getIt<NotificationService>();
    await notificationService.registerDevice();
    
    firebaseService.setupForegroundMessageHandler((message) {
      print("Foreground Message: ${message.notification?.title}");
    });
    
    firebaseService.setupBackgroundMessageHandler((message) {
       print("Background Message: ${message.notification?.title}");
    });
  } catch (e) {
    print('⚠️ Notification setup failed: $e');
  }
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Enable Edge-to-Edge for Android 15 compliance
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarDividerColor: Colors.transparent,
  ));
  
  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ar')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: BlocProvider(
        create: (context) => ThemeCubit(),
        child: const ScoutMenaApp(),
      ),
    ),
  );
}

class ScoutMenaApp extends StatelessWidget {
  const ScoutMenaApp({super.key});

  @override
  Widget build(BuildContext context) {
    final isArabic = context.locale.languageCode == 'ar';
    
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, themeMode) {
        return MaterialApp(
          title: 'ScoutMena',
          debugShowCheckedModeBanner: false,
          
          // Localization
          localizationsDelegates: [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            EasyLocalization.of(context)!.delegate,
          ],
          supportedLocales: context.supportedLocales,
          locale: context.locale,
          
          // Theme
          themeMode: themeMode,
          theme: AppThemes.lightTheme(
            fontFamily: isArabic 
              ? AppTextStyles.fontFamilyArabic 
              : AppTextStyles.fontFamilyEnglish,
          ),
          darkTheme: AppThemes.darkTheme(
            fontFamily: isArabic 
              ? AppTextStyles.fontFamilyArabic 
              : AppTextStyles.fontFamilyEnglish,
          ),
          
          // Routes
          initialRoute: AppRoutes.splash,
          routes: {
            AppRoutes.splash: (context) => const SplashScreen(),
            AppRoutes.onboarding: (context) => const OnboardingScreen(),
            AppRoutes.main: (context) => const AuthMainScreen(),
            AppRoutes.login: (context) => const LoginScreen(),
            AppRoutes.loginWithPhone: (context) => const PhoneLoginScreen(),
            AppRoutes.forgotPassword: (context) => const ForgotPasswordScreen(),
            AppRoutes.backendTest: (context) => const BackendTestScreen(),
            AppRoutes.settings: (context) => const SettingsScreen(),
            AppRoutes.playerDashboard: (context) => BlocProvider(
              create: (context) => getIt<PlayerProfileBloc>(),
              child: const PlayerDashboardScreen(),
            ),
            // AppRoutes.playerProfileSetup moved to onGenerateRoute to handle arguments
            // AppRoutes.scoutProfileSetup moved to onGenerateRoute to handle arguments
            AppRoutes.scoutDashboard: (context) => BlocProvider(
              create: (context) => getIt<ScoutProfileBloc>(),
              child: const ScoutDashboardScreen(),
            ),
            // AppRoutes.coachProfileSetup moved to onGenerateRoute to handle arguments
            AppRoutes.coachDashboard: (context) => BlocProvider(
              create: (context) => getIt<CoachProfileBloc>(),
              child: const CoachDashboardScreen(),
            ),
            '/coach/edit-profile': (context) => BlocProvider(
              create: (context) => getIt<CoachProfileBloc>(),
              child: const CoachEditProfileScreen(),
            ),
            AppRoutes.contactRequests: (context) => const ContactRequestsScreen(),
            AppRoutes.notifications: (context) => const NotificationsScreen(),
            // Role selection moved to onGenerateRoute to handle arguments
            // TODO: Add other routes as screens are implemented
          },
          onGenerateRoute: (settings) {
            // Handle routes with arguments
            if (settings.name == AppRoutes.otp) {
              final args = settings.arguments as Map<String, dynamic>?;
              print('DEBUG: Navigating to OTP Screen with args: $args'); // Debug print
              return MaterialPageRoute(
                builder: (context) => OTPVerificationScreen(
                  phoneNumber: args?['phone'] ?? '',
                  verificationType: args?['verificationType'] ?? 'login',
                  verificationId: args?['verificationId'],
                  expiresAt: args?['expiresAt'],
                  accountType: args?['accountType'],
                ),
              );
            }
            
            if (settings.name == AppRoutes.roleSelection) {
              final args = settings.arguments as Map<String, dynamic>?;
              return MaterialPageRoute(
                builder: (context) => RoleSelectionScreen(
                  phoneNumber: args?['phone'],
                ),
              );
            }
            
            if (settings.name == AppRoutes.register) {
              final args = settings.arguments as Map<String, dynamic>?;
              return MaterialPageRoute(
                builder: (context) => RegistrationScreen(
                  phoneNumber: args?['phone'] ?? '',
                  role: args?['role'] ?? 'player',
                ),
              );
            }
            
            if (settings.name == '/awaiting-consent') {
              final args = settings.arguments as Map<String, dynamic>?;
              return MaterialPageRoute(
                builder: (context) => AwaitingConsentScreen(
                  parentEmail: args?['parentEmail'] ?? '',
                ),
              );
            }
            
            if (settings.name == AppRoutes.verificationDocuments) {
              final args = settings.arguments as Map<String, dynamic>?;
              return MaterialPageRoute(
                builder: (context) => VerificationDocumentsScreen(
                  userId: args?['userId'] ?? '',
                  accountType: args?['accountType'] ?? 'scout',
                  onComplete: () {
                    // Navigate to pending screen after successful upload
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => const VerificationPendingScreen(),
                      ),
                    );
                  },
                ),
              );
            }
            
            if (settings.name == '/verification-pending') {
              return MaterialPageRoute(
                builder: (context) => const VerificationPendingScreen(),
              );
            }
            
            if (settings.name == AppRoutes.scoutProfileSetup) {
              final args = settings.arguments as Map<String, dynamic>?;
              return MaterialPageRoute(
                builder: (context) => BlocProvider(
                  create: (context) => getIt<ScoutProfileBloc>(),
                  child: ScoutProfileSetupScreen(initialData: args),
                ),
              );
            }

            if (settings.name == AppRoutes.coachProfileSetup) {
              final args = settings.arguments as Map<String, dynamic>?;
              return MaterialPageRoute(
                builder: (context) => BlocProvider(
                  create: (context) => getIt<CoachProfileBloc>(),
                  child: CoachProfileSetupScreen(initialData: args),
                ),
              );
            }
            
            if (settings.name == AppRoutes.playerProfileSetup) {
              final args = settings.arguments as Map<String, dynamic>?;
              return MaterialPageRoute(
                builder: (context) => BlocProvider(
                  create: (context) => getIt<PlayerProfileBloc>(),
                  child: ProfileCreationScreen(initialData: args ?? {}),
                ),
              );
            }
            
            return null;
          },
        );
      },
    );
  }
}
