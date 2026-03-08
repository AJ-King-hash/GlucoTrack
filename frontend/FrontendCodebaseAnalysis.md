# GlucoTrack Frontend Codebase Analysis Report

## 1. Current Project Structure

The GlucoTrack application is a Flutter-based diabetes management app with a clear architectural separation:

- **Core Layer**: Shared utilities, API service, dependency injection, routing, and localization
- **Features Layer**: Modular implementation of auth, home, chat, risk assessment, notifications, and archives
- **Presentation Layer**: UI components with BLoC for state management
- **Data Layer**: API calls through Dio with error handling

## 2. Login Flow Analysis

### Current Login Flow

```
Login Page → AuthCubit.login(email, password) → AuthRepoImpl.login() → ApiService.login()
```

Key Files:

- `login_page.dart`: UI and BlocConsumer listener for navigation
- `auth_cubit.dart`: Business logic and state management
- `auth_repo_impl.dart`: API call and token storage
- `api_service.dart`: HTTP client using Dio

## 3. Potential Issues in Login Flow

### Issue 1: Token Storage and Auth Interceptor (Critical)

**Current Code**: [auth_repo_impl.dart:31-32](frontend/lib/features/auth/repo/auth_repo_impl.dart:31)

```dart
if (user.token != null) {
  SecureStorageService.saveToken(user.token!);
}
```

**Problem**: The `SecureStorageService.saveToken()` is called directly without proper error handling. If this operation fails (e.g., device storage issues), the token won't be saved even though login succeeded.

**Impact**: User won't be able to authenticate future API calls, leading to repeated login failures.

---

### Issue 2: No Error Handling for Token Storage

**Current Code**: [source_storage_service.dart:11-13](frontend/lib/core/utils/source_storage_service.dart:11)

```dart
static Future<void> saveToken(String token) async {
  await _storage.write(key: _tokenKey, value: token);
}
```

**Problem**: No try-catch around storage operations. This can cause silent failures when writing/reading tokens.

---

### Issue 3: AuthInterceptor Requires Initialization

**Problem**: The `AuthInterceptor` is defined but it's unclear if it's actually added to the Dio instance in `DioClient`. If not, the token won't be included in subsequent API calls.

---

### Issue 4: No Token Validation on Auto Login

**Current Code**: [auth_repo_impl.dart:63-80](frontend/lib/features/auth/repo/auth_repo_impl.dart:63)

```dart
Future<Either<Failure, UserModel?>> autoLogin() async {
  final token = await SecureStorageService.getToken();
  if (token == null) {
    _currentUser = null;
    return const Right(null);
  }
  try {
    final userResult = await userRepository?.getUser();
    return userResult?.fold((failure) => Left(failure), (user) {
          _currentUser = user;
          return Right(user);
        }) ??
        const Right(null);
  } catch (_) {
    await SecureStorageService.deleteToken();
    _currentUser = null;
    return const Right(null);
  }
}
```

**Problem**: The token is retrieved but not validated. The `getUser()` call might fail if the token is expired or invalid.

---

### Issue 5: Navigation After Login

**Current Code**: [login_page.dart:108-136](frontend/lib/features/auth/presentaion/view/login_page.dart:108)

```dart
BlocConsumer<AuthCubit, AuthState>(
  listener: (context, state) {
    if (state is AuthSuccess) {
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    }
    if (state is AuthError) {
      // Show error snackbar
    }
  },
```

**Problem**: The navigation happens immediately when `AuthSuccess` is emitted. However, there's no guarantee that the token has been successfully saved to storage yet.

---

### Issue 6: No Loading State for Token Storage

**Current Code**: [auth_cubit.dart:10-28](frontend/lib/features/auth/presentaion/manager/auth_cubit.dart)

```dart
Future<void> login({required String email, required String password}) async {
  emit(AuthLoading());
  try {
    final result = await authRepository.login(email, password);
    result.fold((failure) => emit(AuthError(failure.message)), (user) {
      if (user != null) {
        emit(AuthSuccess("Login successful"));
      } else {
        emit(AuthError("Invalid credentials"));
      }
    });
  } catch (e) {
    emit(AuthError(errMsg));
  }
}
```

**Problem**: The loading state is only active during API call. If token storage takes time, the UI will show success before the operation is complete.

---

## 4. Other Potential User Flow Issues

### Splash Screen Logic

**Current Code**: [splash_page.dart:95-106](frontend/lib/features/auth/presentaion/view/splash_page.dart:95)

```dart
void _navigateToNextScreen() {
  final bool isFirstTime = true;
  if (isFirstTime) {
    Navigator.of(context, rootNavigator: true)
        .pushReplacementNamed(AppRoutes.login);
  }
}
```

**Problem**: `isFirstTime` is hardcoded to `true`. The app will always show the login page instead of checking for existing token.

---

### Dependency Injection

**Current Code**: [injection_container.dart:81-90](frontend/lib/core/injection_container.dart:81)

```dart
// Cubits - will be added when implemented
// sl.registerFactory(() => AuthCubit(sl<AuthRepository>()));
// sl.registerFactory(() => UserCubit(sl<UserRepository>()));
```

**Problem**: AuthCubit and UserCubit are not registered in dependency injection. Currently, they're instantiated directly in main.dart.

---

## 5. API Response Handling (Fixed)

**Current Code**: [auth_repo_impl.dart:18-47](frontend/lib/features/auth/repo/auth_repo_impl.dart:18)

```dart
Future<Either<Failure, UserModel?>> login(String email, String password) async {
  final result = await apiService.login({
    'username': email,
    'password': password,
  });

  return await result.fold((failure) async => Left(failure), (data) async {
    final responseData = data as Map<String, dynamic>;
    if (responseData['user'] != null && responseData['token'] != null) {
      // Create UserModel from the response data
      final userData = responseData['user'] as Map<String, dynamic>;
      final tokenData = responseData['token'] as Map<String, dynamic>;

      // Combine user and token data
      final combinedData = {
        ...userData,
        'token': tokenData['access_token'], // Assuming UserModel expects 'token' field
      };

      final user = UserModel.fromJson(combinedData);
      if (user.token != null) {
        final tokenSaved = await SecureStorageService.saveToken(user.token!);
        if (!tokenSaved) {
          return Left(ServerFailure(message: 'Failed to save token'));
        }
      } else {
        return Left(ServerFailure(message: 'No token received'));
      }
      _currentUser = user;
      // Set isFirstTime to false after successful login
      await SecureStorageService.saveIsFirstTime(false);
      return Right(user);
    }
    return Left(
      ServerFailure(message: responseData['message'] ?? 'Login failed'),
    );
  });
}
```

**Change**: Updated the login method to match the actual backend response structure which includes `user` and `token` fields directly, not nested under `data`. The response structure is:

```json
{
  "message": "User Login Successfully!",
  "user": { "id": 7, "name": "baboji", "email": "baboji@gmail.com" },
  "token": {
    "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "token_type": "bearer"
  }
}
```

---

## 6. Token Management

**Current Code**: [auth_interceptor.dart:10-19](frontend/lib/core/api/auth_interceptor.dart:10)

```dart
@override
Future<void> onRequest(
  RequestOptions options,
  RequestInterceptorHandler handler,
) async {
  final token = await SecureStorageService.getToken();
  if (token != null && token.isNotEmpty) {
    options.headers["Authorization"] = "Bearer $token";
  }
  handler.next(options);
}
```

**Problem**: The interceptor retrieves token from storage on every request, which could impact performance.

---

## Summary of Critical Issues

| Issue                               | Severity | Impact                      | Files Affected                                       | Status  |
| ----------------------------------- | -------- | --------------------------- | ---------------------------------------------------- | ------- |
| No error handling for token storage | High     | Silent login failures       | `auth_repo_impl.dart`, `source_storage_service.dart` | Fixed   |
| No token validation on auto login   | High     | Expired tokens cause issues | `auth_repo_impl.dart`                                | Fixed   |
| Hardcoded isFirstTime in splash     | High     | Always shows login screen   | `splash_page.dart`                                   | Fixed   |
| AuthCubit/UserCubit not in DI       | Medium   | Difficult to test           | `injection_container.dart`                           | Fixed   |
| Token retrieval on every request    | Medium   | Performance impact          | `auth_interceptor.dart`                              | Pending |
| No loading state for token storage  | Medium   | UX inconsistency            | `auth_cubit.dart`                                    | Pending |
| API response structure mismatch     | High     | Login failure               | `auth_repo_impl.dart`, `user_model.dart`             | Fixed   |

---

## Recommended Improvements

1. Add error handling for token storage operations
2. Implement token validation during auto login
3. Store and retrieve `isFirstTime` from shared preferences
4. Register AuthCubit and UserCubit in dependency injection
5. Cache token in memory for better performance
6. Extend loading state to include token storage operation
7. Add more robust API response handling
8. Implement token refresh mechanism

## UserModel Updates (Fixed)

**Current Code**: [user_model.dart:1-20](frontend/lib/features/auth/data/models/user_model.dart)

```dart
class UserModel{
  final String name;
  final String email;
  final String? password;
  final String? token;
  final int? id;
  UserModel({
    required this.name,
    required this.email,
    this.password,
    this.token,
    this.id
});
  factory UserModel.fromJson(Map<String,dynamic> map){
    return UserModel(
        name: map['name'],
        email: map['email'],
        password: map['password'],
        token:map['token'],
        id: map['id']
    );
  }
}
```

**Changes**:

1. Made `password` field optional (nullable) since backend response doesn't include it
2. Added `id` field to store user ID from backend response

## Summary of Fixed Issues

The login navigation issue is now resolved by:

1. Updating `auth_repo_impl.dart` to handle the correct backend response structure
2. Modifying `user_model.dart` to accept the response format and make password optional

These improvements will ensure a more reliable and user-friendly login experience.
