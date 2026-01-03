import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Current User
  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get Firebase ID Token
  Future<String?> getIdToken() async {
    final user = _auth.currentUser;
    if (user != null) {
      return await user.getIdToken();
    }
    return null;
  }

  // Refresh ID Token
  Future<String?> refreshIdToken() async {
    final user = _auth.currentUser;
    if (user != null) {
      return await user.getIdToken(true);
    }
    return null;
  }

  // Google Sign-In
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        return null; // User cancelled
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      return await _auth.signInWithCredential(credential);
    } catch (e) {
      throw Exception('Google sign-in failed: $e');
    }
  }

  // Facebook Sign-In
  Future<UserCredential?> signInWithFacebook() async {
    try {
      // Trigger the Facebook authentication flow
      final LoginResult result = await FacebookAuth.instance.login();

      if (result.status == LoginStatus.success) {
        // Create a credential from the access token
        final OAuthCredential credential = 
            FacebookAuthProvider.credential(result.accessToken!.tokenString);

        // Sign in to Firebase with the Facebook credential
        return await _auth.signInWithCredential(credential);
      } else if (result.status == LoginStatus.cancelled) {
        return null; // User cancelled
      } else {
        throw Exception('Facebook sign-in failed: ${result.message}');
      }
    } catch (e) {
      throw Exception('Facebook sign-in failed: $e');
    }
  }

  // Apple Sign-In (iOS only)
  Future<UserCredential?> signInWithApple() async {
    try {
      // Request credential for the currently signed in Apple account
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      // Create an `OAuthCredential` from the credential returned by Apple
      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      // Sign in to Firebase with the Apple credential
      return await _auth.signInWithCredential(oauthCredential);
    } catch (e) {
      throw Exception('Apple sign-in failed: $e');
    }
  }

  // Sign Out
  Future<void> signOut() async {
    await Future.wait([
      _auth.signOut(),
      _googleSignIn.signOut(),
      FacebookAuth.instance.logOut(),
    ]);
  }

  // FCM Token Management
  Future<String?> getFCMToken() async {
    try {
      final token = await _messaging.getToken();
      return token;
    } catch (e) {
      throw Exception('Failed to get FCM token: $e');
    }
  }

  // Request Notification Permission
  Future<NotificationSettings> requestNotificationPermission() async {
    return await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
  }

  // Setup FCM Foreground Message Handler
  void setupForegroundMessageHandler(
    Function(RemoteMessage) onMessageReceived,
  ) {
    FirebaseMessaging.onMessage.listen(onMessageReceived);
  }

  // Setup FCM Background Message Handler
  void setupBackgroundMessageHandler(
    Function(RemoteMessage) onMessageReceived,
  ) {
    FirebaseMessaging.onMessageOpenedApp.listen(onMessageReceived);
  }

  // Delete FCM Token (on logout)
  Future<void> deleteFCMToken() async {
    await _messaging.deleteToken();
  }
}
