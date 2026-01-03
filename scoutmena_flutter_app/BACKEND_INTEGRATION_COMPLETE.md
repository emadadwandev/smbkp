# Real Backend Integration - Implementation Complete

## Summary

Successfully replaced all mock repository implementations with real backend-integrated repositories. The app now communicates with the Laravel backend API for all profile operations.

## Changes Made

### 1. Created Real Repository Implementations

#### Player Profile Repository
**File:** `lib/features/player/profile/data/repositories/player_profile_repository_impl.dart`

**Features:**
- ✅ Get player profile (`GET /player/profile`)
- ✅ Create player profile (`POST /player/profile`)
- ✅ Update player profile (`PUT /player/profile`)
- ✅ Upload profile photo (`POST /player/profile/photo`)
- ✅ Delete profile photo (`DELETE /player/profile/photo`)
- ✅ Upload gallery photo (`POST /player/profile/photos`)
- ✅ Get gallery photos (`GET /player/profile/photos`)
- ✅ Delete gallery photo (`DELETE /player/profile/photos/{photoId}`)
- ✅ Update privacy settings (`PUT /player/profile/privacy`)

**Error Handling:**
- Network failures
- Authentication errors (401)
- Not found errors (404)
- Validation errors (422)
- Server errors (5xx)
- Timeout errors

#### Scout Profile Repository
**File:** `lib/features/scout/profile/data/repositories/scout_profile_repository_impl.dart`

**Features:**
- ✅ Get scout profile (`GET /scout/profile`)
- ✅ Create scout profile (`POST /scout/profile`)
- ✅ Update scout profile (`PUT /scout/profile`)
- ✅ Upload verification documents (`POST /scout/profile/verification-documents`)
- ✅ Upload profile photo (`POST /scout/profile/photo`)
- ✅ Delete profile photo (`DELETE /scout/profile/photo`)
- ✅ Refresh profile data

#### Coach Profile Repository
**File:** `lib/features/coach/profile/data/repositories/coach_profile_repository_impl.dart`

**Features:**
- ✅ Get coach profile (`GET /coach/profile`)
- ✅ Create coach profile (`POST /coach/profile`)
- ✅ Update coach profile (`PUT /coach/profile`)
- ✅ Upload verification documents (`POST /coach/profile/verification-documents`)
- ✅ Upload profile photo (`POST /coach/profile/photo`)
- ✅ Delete profile photo (`DELETE /coach/profile/photo`)
- ✅ Refresh profile data

### 2. Dependency Injection Updates

**Modified:** `lib/injection.dart`
- Removed mock repository imports
- Removed mock repository registrations from `RegisterModule`
- Real implementations auto-registered via `@LazySingleton` annotation

**Generated:** `lib/injection.config.dart`
- Automatically registers real repository implementations
- Properly wires all dependencies (ApiClient → Repository → UseCase → BLoC)

### 3. Removed Mock Files

**Deleted:**
- `lib/core/mocks/mock_player_profile_repository.dart`
- `lib/core/mocks/mock_scout_profile_repository.dart`
- `lib/core/mocks/mock_coach_profile_repository.dart`
- `lib/core/mocks/` directory

## API Integration Details

### Authentication
All API requests automatically include the Firebase ID token in the `Authorization` header via the `ApiClient` auth interceptor.

### Request/Response Format

**Request Example:**
```dart
final response = await apiClient.post('/player/profile', data: {
  'first_name': 'Ahmed',
  'last_name': 'Hassan',
  'country': 'Egypt',
  'primary_position': 'striker',
  'privacy_level': 'scouts_only',
});
```

**Response Format:**
```json
{
  "success": true,
  "message": "Profile created successfully",
  "data": {
    "id": "123",
    "first_name": "Ahmed",
    "last_name": "Hassan",
    ...
  }
}
```

### Error Handling Pattern

All repositories use `Either<Failure, T>` pattern for consistent error handling:

```dart
final result = await repository.getProfile();

result.fold(
  (failure) {
    // Handle error: NetworkFailure, AuthFailure, ServerFailure, etc.
    print(failure.message);
  },
  (profile) {
    // Success: Use profile data
    print(profile.fullName);
  },
);
```

### File Upload

Uses `multipart/form-data` for photo/document uploads:

```dart
final formData = FormData.fromMap({
  'photo': await MultipartFile.fromFile(
    photo.path,
    filename: photo.path.split('/').last,
  ),
});

final response = await apiClient.upload('/player/profile/photo', formData);
```

## Testing the Integration

### 1. Player Flow
```dart
// After successful login
1. User navigates to player dashboard
2. PlayerProfileBloc calls GetPlayerProfileUseCase
3. UseCase calls PlayerProfileRepository.getProfile()
4. Repository makes API call: GET /api/v1/player/profile
5. Backend returns profile data or 404 if not exists
6. Profile displayed or "Create Profile" prompt shown
```

### 2. Scout Flow
```dart
// After admin verification
1. Scout logs in
2. ScoutProfileBloc checks profile status
3. Repository calls: GET /api/v1/scout/profile
4. If verified: Display dashboard with search features
5. If pending: Show "Awaiting Verification" screen
```

### 3. Coach Flow
```dart
// After registration
1. Coach creates profile
2. CoachProfileBloc calls CreateCoachProfile usecase
3. Repository posts to: POST /api/v1/coach/profile
4. Backend validates and creates profile
5. Dashboard displayed with browse players feature
```

## Next Steps

### For Testing
1. ✅ Ensure Laravel backend is running
2. ✅ Update `ApiConstants.apiBaseUrl` to point to backend
3. ✅ Test login flow (token should be saved)
4. ✅ Navigate to dashboard (profile API call should execute)
5. ✅ Monitor network logs in Flutter DevTools

### For Production
1. Configure environment-based API URLs (dev/staging/prod)
2. Implement retry logic for failed requests
3. Add offline caching for profile data
4. Implement optimistic updates for better UX
5. Add analytics tracking for API calls
6. Setup error monitoring (Sentry, Firebase Crashlytics)

## API Endpoints Reference

### Base URL
```
http://localhost:8000/api/v1/
```

### Player Endpoints
- `GET /player/profile` - Get profile
- `POST /player/profile` - Create profile
- `PUT /player/profile` - Update profile
- `POST /player/profile/photo` - Upload profile photo
- `DELETE /player/profile/photo` - Delete profile photo
- `POST /player/profile/photos` - Upload gallery photo
- `GET /player/profile/photos` - Get gallery photos
- `DELETE /player/profile/photos/{id}` - Delete gallery photo
- `PUT /player/profile/privacy` - Update privacy

### Scout Endpoints
- `GET /scout/profile` - Get profile
- `POST /scout/profile` - Create profile
- `PUT /scout/profile` - Update profile
- `POST /scout/profile/photo` - Upload profile photo
- `POST /scout/profile/verification-documents` - Upload verification docs

### Coach Endpoints
- `GET /coach/profile` - Get profile
- `POST /coach/profile` - Create profile
- `PUT /coach/profile` - Update profile
- `POST /coach/profile/photo` - Upload profile photo
- `POST /coach/profile/verification-documents` - Upload verification docs

## Troubleshooting

### Common Issues

**1. "Network error occurred"**
- Check if backend is running
- Verify `ApiConstants.apiBaseUrl` is correct
- Check device/emulator network connectivity

**2. "401 Unauthorized"**
- Token not saved after login
- Token expired (check token refresh logic)
- Backend authentication middleware issue

**3. "404 Not Found"**
- Profile doesn't exist (expected for new users)
- API route not registered in backend
- Wrong endpoint path in repository

**4. "422 Validation Error"**
- Check required fields in request
- Verify field names match backend expectations
- Review validation rules in backend

### Debug Tips

1. Enable verbose logging in ApiClient (already enabled via PrettyDioLogger)
2. Use Flutter DevTools Network tab to inspect requests
3. Check backend logs for detailed error messages
4. Test endpoints directly with Postman/Insomnia first
5. Verify token in secure storage: `await secureStorage.read(key: 'access_token')`

## Architecture Benefits

### Clean Architecture Maintained
```
Presentation (BLoC) → Domain (UseCase) → Data (Repository) → Network (API)
```

### Testability
- Mock repositories can be injected for testing
- Use cases can be tested independently
- BLoCs can be tested with mock use cases

### Flexibility
- Easy to switch between different data sources
- Can add caching layer without changing domain logic
- Can implement offline-first architecture

### Type Safety
- Strong typing with domain entities
- Compile-time error checking
- Auto-completion support in IDEs

## Conclusion

The app is now fully integrated with the Laravel backend. All mock data has been removed and replaced with real API calls. The dependency injection system automatically wires all components, and error handling is consistent across all repositories.

**Status:** ✅ Ready for testing with real backend
