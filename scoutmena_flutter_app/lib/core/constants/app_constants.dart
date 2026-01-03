class AppConstants {
  // App Info
  static const String appName = 'ScoutMena';
  static const String appVersion = '1.0.0';

  // Storage Keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userIdKey = 'user_id';
  static const String userRoleKey = 'user_role';
  static const String fcmTokenKey = 'fcm_token';
  static const String isFirstLaunchKey = 'is_first_launch';
  static const String selectedLanguageKey = 'selected_language';
  static const String selectedThemeKey = 'selected_theme';

  // Player Positions
  static const List<String> playerPositions = [
    'goalkeeper',
    'center_back',
    'right_back',
    'left_back',
    'defensive_midfielder',
    'central_midfielder',
    'attacking_midfielder',
    'right_winger',
    'left_winger',
    'striker',
    'second_striker',
  ];

  // Privacy Levels
  static const String privacyPublic = 'public';
  static const String privacyScoutsOnly = 'scouts_only';
  static const String privacyPrivate = 'private';

  // Account Types
  static const String accountTypePlayer = 'player';
  static const String accountTypeScout = 'scout';
  static const String accountTypeCoach = 'coach';
  static const String accountTypeAcademy = 'academy';

  // Media Limits
  static const int maxProfilePhotos = 1;
  static const int maxHeroImages = 1;
  static const int maxGalleryPhotos = 5;
  static const int maxImageSizeMB = 5;
  static const int maxVideoSizeMB = 100;

  // Pagination
  static const int defaultPageSize = 20;

  // Validation
  static const int minAge = 13;
  static const int maxAge = 25;
  static const int minorAge = 16;
  static const int maxBioLength = 500;
  static const int maxMessageLength = 500;

  // Social Login Providers
  static const String googleProvider = 'google';
  static const String facebookProvider = 'facebook';
  static const String appleProvider = 'apple';
}
