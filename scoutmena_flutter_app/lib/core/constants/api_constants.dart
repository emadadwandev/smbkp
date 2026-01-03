class ApiConstants {
  // Base URLs
  // Use your machine's IP address for physical devices (e.g., http://192.168.1.6:8000)
  // Ensure you run: php artisan serve --host 0.0.0.0 --port 8000
  static const String baseUrl = 'https://scoutmena.com';
  static const String apiVersion = '/api/v1';
  static const String apiBaseUrl = '$baseUrl$apiVersion';

  // Authentication Endpoints
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String firebaseLogin = '/auth/firebase-login';
  static const String sendOtp = '/auth/send-otp';
  static const String verifyOtp = '/auth/verify-otp';
  static const String registerWithOtp = '/auth/register-with-otp';
  static const String loginWithOtp = '/auth/login-with-otp';
  static const String uploadVerificationDocuments = '/auth/upload-verification-documents';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String me = '/auth/me';
  static const String logout = '/auth/logout';

  // Player Profile Endpoints
  static const String playerProfile = '/player/profile';
  static const String playerProfilePhoto = '/player/profile/photo';
  static const String playerProfilePhotos = '/player/profile/photos';
  static const String playerProfileVideos = '/player/profile/videos';
  static const String playerProfileStats = '/player/profile/stats';
  static const String playerProfileAnalytics = '/player/profile/analytics';
  static const String playerProfilePrivacy = '/player/profile/privacy';

  // Scout Profile Endpoints
  static const String scoutProfile = '/scout/profile';
  static const String scoutPlayersSearch = '/scout/players/search';
  static const String scoutSavedSearches = '/scout/saved-searches';

  // Coach Profile Endpoints
  static const String coachProfile = '/coach/profile';
  static const String coachPlayersSearch = '/coach/players/search';

  // Parental Consent Endpoints
  static const String parentalConsent = '/parent/consent';
  static const String parentChildren = '/parent/children';

  // Device Management
  static const String deviceRegister = '/device/register';
  static const String deviceUnregister = '/device/unregister';
  static const String device = '/device';

  // Contact Requests
  static const String contactRequests = '/contact-requests';
  static const String contactRequestsForMe = '/contact-requests/for-me';

  // Request Timeouts
  static const int connectTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds
  static const int sendTimeout = 30000; // 30 seconds
}
