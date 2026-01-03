# Firebase Configuration for ScoutMena Flutter App

## Overview
This app uses Firebase for:
- **Social Authentication** (Google, Facebook, Apple Sign-In)
- **Push Notifications** (Firebase Cloud Messaging - FCM)
- **Crashlytics** (optional, for production monitoring)

**Note:** We are using **Infobip** for OTP verification (SMS/WhatsApp), NOT Firebase Phone Authentication.

## Setup Instructions

### 1. iOS Configuration (Already Completed)
✅ The `GoogleService-Info.plist` file has been copied to `ios/Runner/` directory.

To verify the setup:
1. Open `ios/Runner.xcworkspace` in Xcode
2. Ensure `GoogleService-Info.plist` is in the Runner target
3. Check that Bundle Identifier matches: `com.scoutmena.scoutmenaApp`

### 2. Android Configuration (Requires Action)

#### Step 2.1: Download google-services.json
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your ScoutMena project
3. Click on the Android app (or add a new Android app if not exists)
4. Package name should be: `com.scoutmena.scoutmena_app`
5. Download the `google-services.json` file
6. Place it in: `android/app/google-services.json`

#### Step 2.2: Verify Gradle Configuration
✅ Already configured in the project:
- Added `google-services` plugin to `android/build.gradle.kts`
- Applied plugin in `android/app/build.gradle.kts`
- Set `minSdk = 21` (required for Firebase)
- Added `multiDexEnabled = true`

### 3. Firebase Services Used

#### 3.1 Social Authentication
The app supports:
- **Google Sign-In**: Uses `google_sign_in` package + Firebase Auth
- **Facebook Login**: Uses `flutter_facebook_auth` package + Firebase Auth  
- **Apple Sign-In**: Uses `sign_in_with_apple` package + Firebase Auth (iOS only)

**Implementation:**
- Service: `lib/core/services/firebase_service.dart`
- Methods: `signInWithGoogle()`, `signInWithFacebook()`, `signInWithApple()`
- Flow: Social provider → Firebase credential → Backend with Firebase ID token

#### 3.2 OTP Verification (Infobip)
**Important:** We do NOT use Firebase Phone Authentication.

Instead, we use Infobip through the backend:
- Service: `lib/core/services/otp_service.dart`
- Backend handles Infobip API calls
- Endpoints:
  - `POST /api/v1/auth/send-otp` - Send OTP via SMS/WhatsApp
  - `POST /api/v1/auth/verify-otp` - Verify OTP code
  - `POST /api/v1/auth/register-with-otp` - Register with phone
  - `POST /api/v1/auth/login-with-otp` - Login with phone

#### 3.3 Push Notifications (FCM)
- Uses Firebase Cloud Messaging for push notifications
- Token registration: `lib/core/services/firebase_service.dart`
- Backend registration: `POST /api/v1/device/register`
- Notification types:
  - Profile views
  - Contact requests
  - Account approvals
  - Video processing status

### 4. Additional Platform Configuration

#### iOS: Info.plist Additions
Add these keys to `ios/Runner/Info.plist` for social login:

```xml
<!-- Google Sign-In -->
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleTypeRole</key>
    <string>Editor</string>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>com.googleusercontent.apps.YOUR_REVERSED_CLIENT_ID</string>
    </array>
  </dict>
</array>

<!-- Facebook Login -->
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>fbYOUR_FACEBOOK_APP_ID</string>
    </array>
  </dict>
</array>
<key>FacebookAppID</key>
<string>YOUR_FACEBOOK_APP_ID</string>
<key>FacebookDisplayName</key>
<string>ScoutMena</string>

<!-- Apple Sign-In (Automatic with capability) -->
```

#### Android: Manifest Additions
These are already handled by the Flutter plugins, but verify in `android/app/src/main/AndroidManifest.xml`:

```xml
<!-- Internet Permission -->
<uses-permission android:name="android.permission.INTERNET"/>

<!-- Google Sign-In -->
<meta-data
    android:name="com.google.android.gms.version"
    android:value="@integer/google_play_services_version" />
```

### 5. Social Login Setup

#### Google Sign-In
1. Enable Google Sign-In in Firebase Console
2. Add SHA-1 certificate fingerprint for Android
3. Download updated `google-services.json`
4. iOS: Reversed Client ID is in `GoogleService-Info.plist`

#### Facebook Login
1. Create Facebook App at [Facebook Developers](https://developers.facebook.com/)
2. Enable Facebook Login product
3. Add Android and iOS platforms with package names/bundle IDs
4. Copy App ID and App Secret to Firebase Console (Facebook provider)
5. Update Info.plist (iOS) with Facebook App ID

#### Apple Sign-In
1. Enable Apple Sign-In capability in Xcode (iOS)
2. Enable Apple provider in Firebase Console
3. Configure Service ID and Key ID in Firebase
4. iOS only (automatically available on iOS 13+)

### 6. Testing Firebase Setup

Run this command to verify Firebase initialization:
```bash
cd scoutmena_flutter_app
flutter run
```

Check logs for:
- ✅ Firebase initialized successfully
- ✅ FCM token generated
- ❌ Any Firebase configuration errors

### 7. Environment-Specific Configuration

For multiple environments (dev/staging/prod), use different Firebase projects:

**Development:**
- Project: scoutmena-dev
- Files: `google-services-dev.json`, `GoogleService-Info-dev.plist`

**Production:**
- Project: scoutmena-prod
- Files: `google-services.json`, `GoogleService-Info.plist`

Use flavor configuration to switch between environments.

## Troubleshooting

### Android Issues
- **Error: "Default FirebaseApp is not initialized"**
  - Ensure `google-services.json` is in `android/app/`
  - Verify package name matches in Firebase Console
  - Clean build: `flutter clean && flutter pub get`

- **Multidex error**
  - Already enabled in `build.gradle.kts`
  - If still occurring, check `minSdk >= 21`

### iOS Issues
- **GoogleService-Info.plist not found**
  - Open Xcode, verify file is in Runner target
  - Check Bundle Identifier matches

- **Google Sign-In failed**
  - Verify Reversed Client ID in Info.plist
  - Check URL schemes are configured

### Common Issues
- **FCM Token is null**
  - Request notification permission first
  - Check device has Google Play Services (Android)
  
- **Social login returns null**
  - User cancelled the flow
  - Check provider is enabled in Firebase Console
  - Verify platform-specific configuration

## Security Notes

1. **Never commit `google-services.json` or `GoogleService-Info.plist` to public repos**
   - Add to `.gitignore` if project is public
   - Use environment variables or secure CI/CD for distribution

2. **API Keys in these files are restricted**
   - Set restrictions in Google Cloud Console
   - Android: SHA-1 fingerprint restriction
   - iOS: Bundle ID restriction

3. **Backend Token Verification**
   - Backend MUST verify Firebase ID tokens
   - Use Firebase Admin SDK on backend
   - Never trust tokens from client-side only

## Next Steps

After Firebase is configured:
1. Test social login flows
2. Implement push notification handlers
3. Set up FCM topic subscriptions (if needed)
4. Configure Crashlytics for production monitoring
5. Set up deep linking for notifications

## Support

For Firebase-specific issues:
- [Firebase Documentation](https://firebase.google.com/docs/flutter/setup)
- [FlutterFire Documentation](https://firebase.flutter.dev/)
- [Firebase Console](https://console.firebase.google.com/)
