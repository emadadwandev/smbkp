# Mobile Social Login Setup Guide (Android & iOS)

This guide provides step-by-step instructions for configuring Google, Facebook, and Apple Sign-In for Android and iOS apps using Firebase Authentication.

## Prerequisites

- Firebase project created: `scoutmena-app`
- `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) already added
- Flutter packages installed: `firebase_auth`, `google_sign_in`, `flutter_facebook_auth`, `sign_in_with_apple`

---

## 🤖 Android Configuration

### 1. Google Sign-In for Android

#### Step 1: Get SHA-1 and SHA-256 Fingerprints

**For Debug Build:**
```bash
cd android
./gradlew signingReport
```

**For Release Build (if you have a keystore):**
```bash
keytool -list -v -keystore upload-keystore.jks -alias upload
```

You'll get output like:
```
SHA1: A1:B2:C3:D4:E5:F6:... (40 characters)
SHA256: 1A:2B:3C:4D:5E:6F:... (64 characters)
```

#### Step 2: Add SHA Fingerprints to Firebase Console

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select project: **scoutmena-app**
3. Go to **Project Settings** → **Your apps** → **Android app**
4. Scroll to **SHA certificate fingerprints**
5. Click **Add fingerprint** and paste both SHA-1 and SHA-256
6. **Download new `google-services.json`** and replace in `android/app/`
7. Click **Save**

#### Step 3: Verify AndroidManifest.xml

Your `AndroidManifest.xml` should already have internet permissions (✅ already present):
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
```

✅ **Google Sign-In is now configured for Android!**

---

### 2. Facebook Sign-In for Android

#### Step 1: Create Facebook App

1. Go to [Facebook Developers](https://developers.facebook.com/)
2. Click **My Apps** → **Create App**
3. Select **Consumer** → **Next**
4. App Name: **ScoutMena**
5. Contact Email: Your email
6. Click **Create App**
7. Copy your **App ID** (e.g., `1234567890123456`)

#### Step 2: Configure Facebook App for Android

1. In Facebook Dashboard, go to **Settings** → **Basic**
2. Click **Add Platform** → **Android**
3. Enter:
   - **Package Name:** `com.scoutmena.app` (from your AndroidManifest.xml)
   - **Class Name:** `com.scoutmena.app.MainActivity`
   - **Key Hashes:** Generate using:

**Generate Key Hash for Debug:**
```bash
keytool -exportcert -alias androiddebugkey -keystore %USERPROFILE%\.android\debug.keystore | openssl sha1 -binary | openssl base64
# Password: android
```

**Generate Key Hash for Release:**
```bash
keytool -exportcert -alias upload -keystore android\app\upload-keystore.jks | openssl sha1 -binary | openssl base64
```

4. Paste the Key Hash in Facebook Console
5. Enable **Single Sign On** → **Yes**
6. Click **Save Changes**

#### Step 3: Configure Firebase Console for Facebook

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select **scoutmena-app**
3. Go to **Authentication** → **Sign-in method**
4. Enable **Facebook**
5. Enter:
   - **App ID:** Your Facebook App ID
   - **App Secret:** From Facebook Dashboard → Settings → Basic
6. Copy the **OAuth redirect URI** from Firebase
7. Paste it in Facebook Dashboard → **Facebook Login** → **Settings** → **Valid OAuth Redirect URIs**
8. Click **Save**

#### Step 4: Add Facebook App ID to Android Project

Create `android/app/src/main/res/values/strings.xml`:
```xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string name="app_name">ScoutMena</string>
    <string name="facebook_app_id">YOUR_FACEBOOK_APP_ID</string>
    <string name="fb_login_protocol_scheme">fbYOUR_FACEBOOK_APP_ID</string>
    <string name="facebook_client_token">YOUR_FACEBOOK_CLIENT_TOKEN</string>
</resources>
```

**Replace:**
- `YOUR_FACEBOOK_APP_ID` with your actual Facebook App ID
- `YOUR_FACEBOOK_CLIENT_TOKEN` from Facebook Dashboard → Settings → Advanced → Client Token

#### Step 5: Update AndroidManifest.xml

Add inside `<application>` tag:
```xml
<!-- Facebook Configuration -->
<meta-data 
    android:name="com.facebook.sdk.ApplicationId" 
    android:value="@string/facebook_app_id"/>
    
<meta-data 
    android:name="com.facebook.sdk.ClientToken" 
    android:value="@string/facebook_client_token"/>

<!-- Facebook Login Activity -->
<activity 
    android:name="com.facebook.FacebookActivity"
    android:configChanges="keyboard|keyboardHidden|screenLayout|screenSize|orientation"
    android:label="@string/app_name" />
    
<activity
    android:name="com.facebook.CustomTabActivity"
    android:exported="true">
    <intent-filter>
        <action android:name="android.intent.action.VIEW" />
        <category android:name="android.intent.category.DEFAULT" />
        <category android:name="android.intent.category.BROWSABLE" />
        <data android:scheme="@string/fb_login_protocol_scheme" />
    </intent-filter>
</activity>
```

✅ **Facebook Sign-In is now configured for Android!**

---

### 3. Apple Sign-In for Android (Web-based OAuth)

Apple Sign-In on Android uses web-based OAuth flow, which requires Apple Developer account configuration.

#### Step 1: Enable Apple Sign-In in Firebase

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select **scoutmena-app**
3. Go to **Authentication** → **Sign-in method**
4. Enable **Apple**
5. No additional Android configuration needed (handled by Firebase)

✅ **Apple Sign-In is now configured for Android (via Firebase)!**

---

## 🍎 iOS Configuration

### 1. Google Sign-In for iOS

#### Step 1: Add URL Schemes to Info.plist

The `GoogleService-Info.plist` already contains your configuration. Now add URL schemes:

Open `ios/Runner/Info.plist` and add before `</dict>`:
```xml
<!-- Google Sign-In URL Schemes -->
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>com.googleusercontent.apps.150527541857-67mtgipru5mnoqcsoqdf4oc4nc2ilvct</string>
        </array>
    </dict>
</array>

<!-- Google Sign-In Client ID -->
<key>GIDClientID</key>
<string>150527541857-67mtgipru5mnoqcsoqdf4oc4nc2ilvct.apps.googleusercontent.com</string>
```

**Get your REVERSED_CLIENT_ID:**
1. Open `ios/Runner/GoogleService-Info.plist`
2. Find `REVERSED_CLIENT_ID` value (e.g., `com.googleusercontent.apps.150527541857-67mtgipru5mnoqcsoqdf4oc4nc2ilvct`)
3. Use it in the URL scheme above

✅ **Google Sign-In is now configured for iOS!**

---

### 2. Facebook Sign-In for iOS

#### Step 1: Configure Facebook App for iOS

1. In [Facebook Developers](https://developers.facebook.com/), go to your app
2. Click **Settings** → **Basic**
3. Click **Add Platform** → **iOS**
4. Enter:
   - **Bundle ID:** `com.scoutmena.app` (from Xcode or Info.plist)
   - **Single Sign On:** Enable

#### Step 2: Add Facebook Configuration to Info.plist

Add before `</dict>` in `ios/Runner/Info.plist`:
```xml
<!-- Facebook Configuration -->
<key>FacebookAppID</key>
<string>YOUR_FACEBOOK_APP_ID</string>

<key>FacebookClientToken</key>
<string>YOUR_FACEBOOK_CLIENT_TOKEN</string>

<key>FacebookDisplayName</key>
<string>ScoutMena</string>

<!-- Facebook URL Schemes -->
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>fbYOUR_FACEBOOK_APP_ID</string>
        </array>
    </dict>
</array>

<!-- Facebook Queries Scheme -->
<key>LSApplicationQueriesSchemes</key>
<array>
    <string>fbapi</string>
    <string>fb-messenger-share-api</string>
    <string>fbauth2</string>
    <string>fbshareextension</string>
</array>
```

**Replace:**
- `YOUR_FACEBOOK_APP_ID` with your Facebook App ID
- `YOUR_FACEBOOK_CLIENT_TOKEN` from Facebook Dashboard

✅ **Facebook Sign-In is now configured for iOS!**

---

### 3. Apple Sign-In for iOS (Native)

#### Step 1: Enable Sign in with Apple Capability

1. Open project in **Xcode**: `open ios/Runner.xcworkspace`
2. Select **Runner** project in left sidebar
3. Go to **Signing & Capabilities** tab
4. Click **+ Capability**
5. Search and add **Sign in with Apple**

#### Step 2: Configure Apple Developer Account

1. Go to [Apple Developer Console](https://developer.apple.com/account/)
2. Go to **Certificates, Identifiers & Profiles** → **Identifiers**
3. Select your app's Bundle ID: `com.scoutmena.app`
4. Enable **Sign in with Apple**
5. Click **Edit** → **Configure**
6. Select **Primary App ID** (same bundle ID)
7. Click **Save**

#### Step 3: Enable Apple Sign-In in Firebase

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select **scoutmena-app**
3. Go to **Authentication** → **Sign-in method**
4. Enable **Apple**
5. No additional Info.plist configuration needed for native iOS

✅ **Apple Sign-In is now configured for iOS!**

---

## Testing Checklist

### Android Testing
```bash
# Run on Android device/emulator
flutter run -d android

# Test each login:
1. Tap Google Sign-In → Should open Google account picker
2. Tap Facebook Sign-In → Should open Facebook login
3. Tap Apple Sign-In → Should open web-based Apple login
```

### iOS Testing
```bash
# Run on iOS device/simulator
flutter run -d ios

# Test each login:
1. Tap Google Sign-In → Should open Google account picker
2. Tap Facebook Sign-In → Should open Facebook login
3. Tap Apple Sign-In → Should open native Apple Sign in with Apple dialog
```

---

## Troubleshooting

### Google Sign-In Issues

**Android:**
- ❌ **PlatformException(sign_in_failed)** → Check SHA-1/SHA-256 fingerprints in Firebase Console
- ❌ **Error 10** → Download new `google-services.json` after adding SHA fingerprints

**iOS:**
- ❌ **No valid credential** → Check `GIDClientID` in Info.plist matches OAuth client ID
- ❌ **URL scheme not found** → Verify `REVERSED_CLIENT_ID` in URL schemes

### Facebook Sign-In Issues

**Android:**
- ❌ **Invalid Key Hash** → Regenerate key hash and add to Facebook Console
- ❌ **App not setup** → Ensure app is in **Live** mode in Facebook Dashboard

**iOS:**
- ❌ **Can't load URL** → Check `CFBundleURLSchemes` has `fbYOUR_FACEBOOK_APP_ID`
- ❌ **Invalid bundle ID** → Match bundle ID in Xcode with Facebook Console

### Apple Sign-In Issues

**iOS:**
- ❌ **Sign in with Apple not available** → Enable capability in Xcode
- ❌ **Invalid_client** → Check Bundle ID matches in Apple Developer Console

---

## Next Steps

1. ✅ Configure SHA fingerprints for Android
2. ✅ Create Facebook App and add App ID/Secret
3. ✅ Update Info.plist for iOS with URL schemes
4. ✅ Enable Apple Sign-In capability in Xcode
5. ✅ Test all three social logins on Android and iOS devices

## Backend Integration

After mobile social login is working, implement backend verification:
- See `docs/BACKEND_FIREBASE_INTEGRATION.md` for API endpoint setup
- Endpoint: `POST /api/auth/firebase-login`
- Verify Firebase ID tokens on backend
- Create/update user accounts in Laravel database

---

**Need Help?**
- [Firebase Authentication Docs](https://firebase.google.com/docs/auth)
- [Google Sign-In Flutter Plugin](https://pub.dev/packages/google_sign_in)
- [Facebook Login Flutter Plugin](https://pub.dev/packages/flutter_facebook_auth)
- [Apple Sign-In Flutter Plugin](https://pub.dev/packages/sign_in_with_apple)
