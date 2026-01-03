import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../app/routes.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/widgets/scoutmena_logo.dart';
import '../../../injection.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _checkAuthAndNavigate();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.65, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.65, curve: Curves.easeOutBack),
      ),
    );

    _animationController.forward();
  }

  Future<void> _checkAuthAndNavigate() async {
    // Wait for animation to complete
    await Future.delayed(const Duration(milliseconds: 2500));

    if (!mounted) return;
    
    try {
      final storage = const FlutterSecureStorage();
      final prefs = await SharedPreferences.getInstance();

      // Check if user is authenticated
      final token = await storage.read(key: AppConstants.accessTokenKey);
      final isFirstLaunch = prefs.getBool('is_first_launch') ?? true;

      if (token != null && token.isNotEmpty) {
        // User is authenticated - fetch current user data
        try {
          final authService = getIt<AuthService>();
          final currentUser = await authService.getCurrentUser();
          
          // Register device for notifications
          try {
            final notificationService = getIt<NotificationService>();
            await notificationService.registerDevice();
          } catch (e) {
            debugPrint('Failed to register device: $e');
          }
          
          if (!mounted) return;

          // Check parental consent status for minors
          if (currentUser.requiresParentalConsent == true) {
            final consentStatus = currentUser.parentalConsentStatus?.status;
            
            if (consentStatus == 'pending') {
              // Waiting for parental approval
              Navigator.of(context).pushReplacementNamed(
                AppRoutes.awaitingApproval,
                arguments: {
                  'parentEmail': currentUser.parentalConsentStatus?.parentEmail ?? '',
                },
              );
              return;
            } else if (consentStatus == 'rejected') {
              // Parental consent rejected - logout and show message
              await authService.logout();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Parental consent was rejected. Please contact support.'),
                    backgroundColor: Colors.red,
                    duration: Duration(seconds: 5),
                  ),
                );
                Navigator.of(context).pushReplacementNamed(AppRoutes.main);
              }
              return;
            }
          }

          // Check if profile is completed
          if (currentUser.hasCompletedProfile == false) {
            // Navigate to profile setup based on role
            String profileRoute;
            switch (currentUser.accountType.toLowerCase()) {
              case 'player':
                profileRoute = AppRoutes.playerProfileSetup;
                break;
              case 'scout':
                // Check verification status
                if (currentUser.isVerified == false) {
                  profileRoute = '/verification-pending';
                } else {
                  profileRoute = AppRoutes.scoutProfileSetup;
                }
                break;
              case 'coach':
                if (currentUser.isVerified == false) {
                   profileRoute = '/verification-pending';
                } else {
                   profileRoute = AppRoutes.coachProfileSetup;
                }
                break;
              default:
                profileRoute = AppRoutes.playerProfileSetup;
            }
            
            if (mounted) {
              Navigator.of(context).pushReplacementNamed(profileRoute);
            }
          } else {
            // Profile completed - navigate to dashboard
            String dashboardRoute;
            switch (currentUser.accountType.toLowerCase()) {
              case 'player':
                dashboardRoute = AppRoutes.playerDashboard;
                break;
              case 'scout':
                dashboardRoute = AppRoutes.scoutDashboard;
                break;
              case 'coach':
                dashboardRoute = AppRoutes.coachDashboard;
                break;
              default:
                dashboardRoute = AppRoutes.playerDashboard;
            }
            
            if (mounted) {
              Navigator.of(context).pushReplacementNamed(dashboardRoute);
            }
          }
        } catch (e) {
          // Error fetching user data - clear auth and go to login
          debugPrint('Error fetching current user: $e');
          await storage.delete(key: AppConstants.accessTokenKey);
          if (mounted) {
            Navigator.of(context).pushReplacementNamed(AppRoutes.main);
          }
        }
      } else {
        // User is not authenticated
        if (isFirstLaunch) {
          // First time user - show onboarding
          await prefs.setBool('is_first_launch', false);
          if (mounted) {
            Navigator.of(context).pushReplacementNamed(AppRoutes.onboarding);
          }
        } else {
          // Returning user - go to auth main screen
          if (mounted) {
            Navigator.of(context).pushReplacementNamed(AppRoutes.main);
          }
        }
      }
    } catch (e) {
      // Error checking auth - navigate to main auth screen
      debugPrint('Error checking authentication: $e');
      if (mounted) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.main);
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: const ScoutMenaLogo(
                  width: 250,
                  height: 150,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
