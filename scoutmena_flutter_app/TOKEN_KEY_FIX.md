# Token Storage Key Inconsistency Fix

## Problem Summary

The Flutter app was making API requests without including the authentication Bearer token in the headers, resulting in **401 Unauthorized** errors with the message "No authentication token provided".

### Root Cause

There was an inconsistency in the secure storage key used to save and retrieve the authentication token:

**ApiClient (reading token):**
```dart
final token = await _secureStorage.read(key: AppConstants.accessTokenKey);
// AppConstants.accessTokenKey = 'access_token'
```

**Login Screen & Auth Repository (saving token):**
```dart
await _secureStorage.write(key: 'auth_token', value: token);
// Hardcoded 'auth_token' instead of using AppConstants
```

This meant:
1. After successful login, token was saved as `'auth_token'`
2. When making API requests, ApiClient looked for `'access_token'`
3. Token not found → No Authorization header → 401 error

## Solution Applied

### 1. Standardized Token Key Usage

All authentication-related code now uses `AppConstants.accessTokenKey` consistently:

**Files Modified:**

#### `lib/features/authentication/data/repositories/auth_repository_impl.dart`
```diff
+ import '../../../../core/constants/app_constants.dart';

- static const String _authTokenKey = 'auth_token';
  static const String _firebaseTokenKey = 'firebase_token';

  Future<String?> getAuthToken() async {
-   return await _secureStorage.read(key: _authTokenKey);
+   return await _secureStorage.read(key: AppConstants.accessTokenKey);
  }

  Future<void> saveAuthToken(String token) async {
-   await _secureStorage.write(key: _authTokenKey, value: token);
+   await _secureStorage.write(key: AppConstants.accessTokenKey, value: token);
  }

  Future<bool> isAuthenticated() async {
-   final token = await _secureStorage.read(key: _authTokenKey);
+   final token = await _secureStorage.read(key: AppConstants.accessTokenKey);
    return token != null && token.isNotEmpty;
  }

  Future<void> clearAuthData() async {
-   await _secureStorage.delete(key: _authTokenKey);
+   await _secureStorage.delete(key: AppConstants.accessTokenKey);
    await _secureStorage.delete(key: _firebaseTokenKey);
  }
```

#### `lib/features/authentication/presentation/pages/login_screen.dart`
```diff
+ import '../../../../core/constants/app_constants.dart';

- await _secureStorage.write(key: 'auth_token', value: response.token);
+ await _secureStorage.write(key: AppConstants.accessTokenKey, value: response.token);

- await _secureStorage.write(key: 'user_role', value: response.user.accountType);
+ await _secureStorage.write(key: AppConstants.userRoleKey, value: response.user.accountType);

- await _secureStorage.write(key: 'user_id', value: response.user.id);
+ await _secureStorage.write(key: AppConstants.userIdKey, value: response.user.id);
```

#### `lib/features/splash/presentation/splash_screen.dart`
```diff
+ import '../../../core/constants/app_constants.dart';

- final token = await storage.read(key: 'auth_token');
+ final token = await storage.read(key: AppConstants.accessTokenKey);

- final userRole = await storage.read(key: 'user_role');
+ final userRole = await storage.read(key: AppConstants.userRoleKey);
```

### 2. AppConstants Reference

All storage keys are now centralized in `lib/core/constants/app_constants.dart`:

```dart
class AppConstants {
  // Storage Keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userIdKey = 'user_id';
  static const String userRoleKey = 'user_role';
  static const String fcmTokenKey = 'fcm_token';
  // ... other constants
}
```

## Verification

### Before Fix

**API Request Log:**
```
╔╣ Request ║ GET 
║  http://192.168.1.6:8000/api/v1/player/profile
╚══════════════════════════════════════════════════════════════════════════════
╔ Headers 
╟ Content-Type: application/json
╟ Accept: application/json
╚══════════════════════════════════════════════════════════════════════════════
```
❌ **No Authorization header present**

**Response:**
```json
{
  "success": false,
  "message": "No authentication token provided",
  "error_code": "TOKEN_MISSING"
}
```

### After Fix

Expected behavior:
1. User logs in with email/password
2. Token saved to secure storage as `'access_token'`
3. API requests include: `Authorization: Bearer {token}`
4. Backend validates token and returns profile data

**Expected Request Log:**
```
╔╣ Request ║ GET 
║  http://192.168.1.6:8000/api/v1/player/profile
╚══════════════════════════════════════════════════════════════════════════════
╔ Headers 
╟ Content-Type: application/json
╟ Accept: application/json
╟ Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
╚══════════════════════════════════════════════════════════════════════════════
```
✅ **Authorization header now included**

## Testing Checklist

- [ ] **Logout and Login Again** - Old token with wrong key may still be in storage
  - Go to Settings → Logout
  - Login with valid credentials
  - Verify token is saved with correct key (`'access_token'`)

- [ ] **Test Player Dashboard** - Navigate to player dashboard
  - Should load profile data successfully
  - No 401 errors in console

- [ ] **Test API Requests** - Make various API calls
  - Upload profile photo
  - Update profile info
  - All should include Authorization header

- [ ] **Test Token Persistence** - Close and reopen app
  - Should remember logged-in state
  - Should navigate to dashboard automatically
  - Should make authenticated requests

## Technical Notes

### How ApiClient Auth Interceptor Works

```dart
class _AuthInterceptor extends Interceptor {
  final FlutterSecureStorage _secureStorage;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Read token from secure storage
    final token = await _secureStorage.read(key: AppConstants.accessTokenKey);
    
    if (token != null) {
      // Inject token into all outgoing requests
      options.headers['Authorization'] = 'Bearer $token';
    }
    
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      // Token expired or invalid - could trigger logout or refresh
      // TODO: Implement token refresh logic
    }
    handler.next(err);
  }
}
```

**Key Points:**
1. Interceptor runs **before every API request**
2. Reads token from secure storage using `AppConstants.accessTokenKey`
3. If token exists, adds `Authorization: Bearer {token}` header
4. If 401 error occurs, can handle token refresh or logout

### Backend Token Validation

The Laravel backend expects:
```
Authorization: Bearer {sanctum_token_or_firebase_id_token}
```

Backend validates via middleware in `app/Http/Middleware/Authenticate.php`:
```php
$token = $request->bearerToken();
if (!$token) {
    return response()->json([
        'success' => false,
        'message' => 'No authentication token provided',
        'error_code' => 'TOKEN_MISSING'
    ], 401);
}
```

## Future Improvements

### 1. Token Refresh Mechanism
Currently no automatic token refresh. Consider:
```dart
@override
void onError(DioException err, ErrorInterceptorHandler handler) async {
  if (err.response?.statusCode == 401) {
    // Try to refresh token
    final refreshToken = await _secureStorage.read(key: AppConstants.refreshTokenKey);
    
    if (refreshToken != null) {
      // Call refresh endpoint
      final newToken = await _refreshToken(refreshToken);
      
      if (newToken != null) {
        // Retry original request with new token
        err.requestOptions.headers['Authorization'] = 'Bearer $newToken';
        final response = await _dio.fetch(err.requestOptions);
        return handler.resolve(response);
      }
    }
    
    // Refresh failed - logout user
    await _authRepository.logout();
  }
  handler.next(err);
}
```

### 2. Token Expiration Tracking
Store token expiration time:
```dart
await _secureStorage.write(key: 'token_expires_at', value: expiresAt.toIso8601String());

// Check before making requests
final expiresAt = await _secureStorage.read(key: 'token_expires_at');
if (DateTime.parse(expiresAt).isBefore(DateTime.now())) {
  // Token expired - refresh proactively
}
```

### 3. Secure Storage Migration
If users have old `'auth_token'` in storage:
```dart
Future<void> migrateOldToken() async {
  final oldToken = await _secureStorage.read(key: 'auth_token');
  
  if (oldToken != null) {
    // Copy to new key
    await _secureStorage.write(key: AppConstants.accessTokenKey, value: oldToken);
    
    // Delete old key
    await _secureStorage.delete(key: 'auth_token');
  }
}
```

## Related Files

All files using authentication tokens:

### Core
- `lib/core/constants/app_constants.dart` - Storage key constants
- `lib/core/network/api_client.dart` - Auth interceptor

### Authentication Feature
- `lib/features/authentication/data/repositories/auth_repository_impl.dart` - Token management
- `lib/features/authentication/presentation/pages/login_screen.dart` - Login flow
- `lib/features/splash/presentation/splash_screen.dart` - Auth state check

### Profile Features
- `lib/features/player/profile/data/repositories/player_profile_repository_impl.dart` - Uses ApiClient
- `lib/features/scout/profile/data/repositories/scout_profile_repository_impl.dart` - Uses ApiClient
- `lib/features/coach/profile/data/repositories/coach_profile_repository_impl.dart` - Uses ApiClient

## Summary

✅ **Fixed:** Token storage key inconsistency  
✅ **Result:** All API requests now include authentication token  
✅ **Impact:** Eliminates 401 "No authentication token provided" errors  
✅ **Status:** Ready for testing with Laravel backend  

**Next Steps:**
1. Logout from app
2. Login again with valid credentials
3. Navigate to player/scout/coach dashboard
4. Verify profile data loads successfully
5. Monitor PrettyDioLogger output to confirm Authorization header present
