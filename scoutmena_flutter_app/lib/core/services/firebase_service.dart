import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:injectable/injectable.dart';
import 'package:flutter/foundation.dart';

/// Comprehensive Firebase service for authentication and notifications
/// Handles Google, Facebook, and Apple sign-in with proper error handling
@lazySingleton
class FirebaseService {
  // Lazy initialization of Firebase services
  late final FirebaseAuth _auth;
  late final FirebaseMessaging _messaging;
  late final GoogleSignIn _googleSignIn;

  // Initialization flag
  bool _isInitialized = false;

  FirebaseService() {
    _initializeServices();
  }

  /// Initialize Firebase services - called immediately after construction
  void _initializeServices() {
    if (_isInitialized) return;

    try {
      // Get Firebase instances - these are safe to call as Firebase should be initialized in main()
      _auth = FirebaseAuth.instance;
      _messaging = FirebaseMessaging.instance;

      // Initialize Google Sign-In with required scopes and client ID for web
      _googleSignIn = GoogleSignIn(
        clientId: kIsWeb 
            ? '150527541857-67mtgipru5mnoqcsoqdf4oc4nc2ilvct.apps.googleusercontent.com'
            : null,
        scopes: [
          'email',
          'profile',
        ],
      );

      _isInitialized = true;
      if (kDebugMode) {
        print('✅ Firebase services initialized');
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Firebase initialization error: $e');
        print('Make sure Firebase.initializeApp() is called in main()');
      }
      rethrow;
    }
  }

  /// Check if Firebase is properly initialized
  bool get isInitialized => _isInitialized;

  /// Get current authenticated user
  User? get currentUser => _auth.currentUser;

  /// Stream of authentication state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Get Firebase ID Token for current user
  Future<String?> getIdToken() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        return await user.getIdToken();
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting ID token: $e');
      }
      rethrow;
    }
  }

  /// Refresh Firebase ID Token
  Future<String?> refreshIdToken() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        return await user.getIdToken(true);
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error refreshing ID token: $e');
      }
      rethrow;
    }
  }

  /// Sign in with Google
  /// Returns UserCredential on success, null if user cancels
  /// Throws exception on error
  Future<UserCredential?> signInWithGoogle() async {
    try {
      if (kDebugMode) {
        print('🔵 Starting Google Sign-In...');
      }

      // Trigger Google sign-in flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        if (kDebugMode) {
          print('❌ Google sign-in cancelled by user');
        }
        return null; // User cancelled
      }

      if (kDebugMode) {
        print('✅ Google user authenticated: ${googleUser.email}');
      }

      // Get authentication details
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      if (googleAuth.idToken == null) {
        throw Exception('Failed to obtain ID token from Google');
      }

      if (googleAuth.accessToken == null) {
        throw Exception('Failed to obtain access token from Google');
      }

      // Create Firebase credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      if (kDebugMode) {
        print('🔐 Signing in to Firebase with Google credential...');
      }

      // Sign in to Firebase
      final userCredential = await _auth.signInWithCredential(credential);

      if (kDebugMode) {
        print('✅ Successfully signed in to Firebase: ${userCredential.user?.email}');
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('❌ Firebase Auth Error: ${e.code} - ${e.message}');
      }
      throw Exception('Firebase authentication error: ${e.message}');
    } catch (e) {
      if (kDebugMode) {
        print('❌ Google sign-in error: $e');
      }
      throw Exception('Google sign-in failed: ${e.toString()}');
    }
  }

  /// Sign in with Facebook
  /// Returns UserCredential on success, null if user cancels
  /// Throws exception on error
  Future<UserCredential?> signInWithFacebook() async {
    try {
      if (kDebugMode) {
        print('🔵 Starting Facebook Sign-In...');
      }

      // Trigger Facebook login
      final LoginResult result = await FacebookAuth.instance.login(
        permissions: ['email', 'public_profile'],
      );

      if (result.status == LoginStatus.success) {
        final AccessToken accessToken = result.accessToken!;

        if (kDebugMode) {
          print('✅ Facebook user authenticated');
        }

        // Create Firebase credential from Facebook access token
        final OAuthCredential credential =
            FacebookAuthProvider.credential(accessToken.tokenString);

        if (kDebugMode) {
          print('🔐 Signing in to Firebase with Facebook credential...');
        }

        // Sign in to Firebase
        final userCredential = await _auth.signInWithCredential(credential);

        if (kDebugMode) {
          print('✅ Successfully signed in to Firebase: ${userCredential.user?.email}');
        }

        return userCredential;
      } else if (result.status == LoginStatus.cancelled) {
        if (kDebugMode) {
          print('❌ Facebook sign-in cancelled by user');
        }
        return null; // User cancelled
      } else {
        throw Exception('Facebook sign-in failed: ${result.message}');
      }
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('❌ Firebase Auth Error: ${e.code} - ${e.message}');
      }
      throw Exception('Firebase authentication error: ${e.message}');
    } catch (e) {
      if (kDebugMode) {
        print('❌ Facebook sign-in error: $e');
      }
      throw Exception('Facebook sign-in failed: ${e.toString()}');
    }
  }

  /// Sign in with Apple (iOS/macOS/Web)
  /// Returns UserCredential on success, null if user cancels
  /// Throws exception on error
  Future<UserCredential?> signInWithApple() async {
    try {
      if (kDebugMode) {
        print('🔵 Starting Apple Sign-In...');
      }

      // Request Apple ID credential
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      if (kDebugMode) {
        print('✅ Apple user authenticated');
      }

      if (appleCredential.identityToken == null) {
        throw Exception('Failed to obtain identity token from Apple');
      }

      // Create Firebase credential from Apple credentials
      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      if (kDebugMode) {
        print('🔐 Signing in to Firebase with Apple credential...');
      }

      // Sign in to Firebase
      final userCredential = await _auth.signInWithCredential(oauthCredential);

      if (kDebugMode) {
        print('✅ Successfully signed in to Firebase: ${userCredential.user?.email}');
      }

      return userCredential;
    } on SignInWithAppleAuthorizationException catch (e) {
      if (kDebugMode) {
        print('❌ Apple Sign-In Authorization Error: ${e.code} - ${e.message}');
      }
      // User cancelled
      if (e.code == AuthorizationErrorCode.canceled) {
        return null;
      }
      throw Exception('Apple sign-in authorization failed: ${e.message}');
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('❌ Firebase Auth Error: ${e.code} - ${e.message}');
      }
      throw Exception('Firebase authentication error: ${e.message}');
    } catch (e) {
      if (kDebugMode) {
        print('❌ Apple sign-in error: $e');
      }
      throw Exception('Apple sign-in failed: ${e.toString()}');
    }
  }

  /// Sign out from all providers
  Future<void> signOut() async {
    try {
      if (kDebugMode) {
        print('🔴 Signing out from all providers...');
      }

      // Sign out from Firebase
      await _auth.signOut();

      // Sign out from Google
      try {
        await _googleSignIn.signOut();
      } catch (e) {
        if (kDebugMode) {
          print('⚠️ Google sign-out error: $e');
        }
      }

      // Sign out from Facebook
      try {
        await FacebookAuth.instance.logOut();
      } catch (e) {
        if (kDebugMode) {
          print('⚠️ Facebook sign-out error: $e');
        }
      }

      if (kDebugMode) {
        print('✅ Successfully signed out from all providers');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Sign-out error: $e');
      }
      rethrow;
    }
  }

  /// Get Firebase Cloud Messaging token
  Future<String?> getFCMToken() async {
    try {
      final token = await _messaging.getToken();
      if (kDebugMode && token != null) {
        print('✅ FCM Token: $token');
      }
      return token;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to get FCM token: $e');
      }
      return null; // Gracefully handle FCM failures (e.g., web)
    }
  }

  /// Request notification permissions
  Future<NotificationSettings> requestNotificationPermission() async {
    try {
      final settings = await _messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (kDebugMode) {
        print('✅ Notification permission: ${settings.authorizationStatus}');
      }

      return settings;
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Failed to request notification permission: $e');
      }
      rethrow;
    }
  }

  /// Setup handler for foreground messages
  void setupForegroundMessageHandler(
    Function(RemoteMessage) onMessageReceived,
  ) {
    FirebaseMessaging.onMessage.listen(onMessageReceived);
  }

  /// Setup handler for messages when app is opened from notification
  void setupBackgroundMessageHandler(
    Function(RemoteMessage) onMessageReceived,
  ) {
    FirebaseMessaging.onMessageOpenedApp.listen(onMessageReceived);
  }

  /// Delete FCM token (usually called on logout)
  Future<void> deleteFCMToken() async {
    try {
      await _messaging.deleteToken();
      if (kDebugMode) {
        print('✅ FCM token deleted');
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Failed to delete FCM token: $e');
      }
    }
  }
}
