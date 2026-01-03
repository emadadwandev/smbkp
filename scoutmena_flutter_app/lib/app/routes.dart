class AppRoutes {
  // Root
  static const String splash = '/';
  
  // Onboarding
  static const String onboarding = '/onboarding';
  
  // Authentication
  static const String main = '/main';
  static const String login = '/login';
  static const String loginWithPhone = '/login-with-phone';
  static const String forgotPassword = '/forgot-password';
  static const String register = '/register';
  static const String otp = '/otp';
  static const String roleSelection = '/role-selection';
  static const String verificationDocuments = '/auth/verification-documents';
  
  // Player
  static const String playerProfileSetup = '/player/profile-setup';
  static const String playerDashboard = '/player/dashboard';
  static const String playerProfile = '/player/profile';
  static const String playerSettings = '/player/settings';
  static const String playerMediaUpload = '/player/media-upload';
  
  // Scout
  static const String scoutProfileSetup = '/scout/profile-setup';
  static const String scoutDashboard = '/scout/dashboard';
  static const String scoutProfile = '/scout/profile';
  static const String scoutSearch = '/scout/search';
  static const String scoutBookmarks = '/scout/bookmarks';
  
  // Coach
  static const String coachProfileSetup = '/coach/profile-setup';
  static const String coachDashboard = '/coach/dashboard';
  static const String coachProfile = '/coach/profile';
  
  // Shared
  static const String contactRequests = '/contact-requests';
  static const String notifications = '/notifications';
  static const String settings = '/settings';
  static const String parentalConsent = '/parental-consent';
  static const String awaitingApproval = '/awaiting-approval';
  
  // Development/Testing
  static const String backendTest = '/backend-test';
}
