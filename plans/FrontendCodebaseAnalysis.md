# GlucoTrack Frontend Codebase Analysis Report

## Commit Message

fix: add translation keys and fix duplicate height key in locale cubit

## Summary

- Updated `locale_cubit.dart` with new translation keys for English and Arabic
- Fixed duplicate "weight" key in Arabic section
- Fixed import error in `settings_page.dart` by changing from hyphen to underscore
- Added translation for "are_you_sure_logout"
- Renamed "height" activity level key to "high_activity" to avoid conflict

## Changes Made

1. Updated `locale_cubit.dart` with new translation keys
2. Fixed duplicate "weight" key in Arabic section
3. Changed import from switch-item.dart to switch_item.dart in settings_page.dart
4. Added "high_activity" translation key to replace "height" for activity level

## Next Steps (System Prompt)

**Goal**: Continue improving the GlucoTrack frontend codebase by addressing remaining issues and implementing new features.

### High Priority Tasks:

1. **Complete Risk Management Features**: Implement missing CRUD operations for risk assessment
2. **Chat Functionality**: Fix message sending and conversation management
3. **Home Content Page**: Localize remaining hardcoded text and implement notifications
4. **API Integration**: Connect all features to backend APIs for real data management

### Technical Debt:

1. **Deprecation Warnings**: Replace `withOpacity` with `withValues()`
2. **Dependency Injection**: Implement proper DI for repository instantiation
3. **Error Handling**: Improve error recovery and user feedback
4. **State Management**: Complete settings persistence and risk state management

### Future Features:

1. **Biometric Authentication**: Implement biometric login functionality
2. **Push Notifications**: Add push notification integration
3. **Dark Mode**: Implement dark/light theme toggle
4. **Analytics**: Add user engagement and usage analytics

---

## 1. Current Project Structure

The GlucoTrack application is a Flutter-based diabetes management app with a clear architectural separation:

- **Core Layer**: Shared utilities, API service, dependency injection, routing, and localization
- **Features Layer**: Modular implementation of auth, home, chat, risk assessment, notifications, and archives
- **Presentation Layer**: UI components with BLoC for state management
- **Data Layer**: API calls through Dio with error handling

## 2. Home Tabs Analysis

### 2.1 Home Page (Main Tab)

**File**: [home_page.dart](frontend/lib/features/home/presentation/view/home_page.dart)

```dart
class HomePage extends StatelessWidget {
  HomePage({super.key});
  final List<Widget> screens = [
    const HomeContent(),
    const ChatPage(),
    const ArchivesPage(),
    const SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<HomeCubit>()),
        BlocProvider(create: (_) => BottomNavCubit()),
      ],

      child: Scaffold(
        backgroundColor: AppColor.backgroundNeutral,

        body: BlocBuilder<BottomNavCubit, int>(
          builder: (context, index) {
            if (index < 0 || index >= screens.length) {
              return const HomeContent();
            }
            return screens[index];
          },
        ),

        bottomNavigationBar: const CustomBottomNav(),
      ),
    );
  }
}
```

**Status**: Fixed

1. **Navigation Logic Fixed**: Changed from switch case to direct list access with bounds checking
2. **Consistent Instantiation**: All screens now use `const` keyword
3. **Screens List Updated**: Now includes HomeContent as index 0, followed by ChatPage, ArchivesPage, and SettingsPage

---

### 2.2 Home Content Widget

**File**: [home_content.dart](frontend/lib/features/home/presentation/widgets/home_content.dart)

```dart
class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        final locale = context.read<LocaleCubit>();

        return Scaffold(
          backgroundColor: AppColor.info,
          appBar: AppBar(
            title: Text(
              'GlucoTrack',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: AppColor.textNeutral,
              ),
            ),
            centerTitle: true,
            backgroundColor: AppColor.backgroundNeutral,
            actions: [
              IconButton(
                icon: const Icon(CupertinoIcons.bell, color: AppColor.info),
                onPressed: () {},
              ),
            ],
          ),
```

**Issues**:

1. **Hardcoded App Title**: 'GlucoTrack' is hardcoded instead of using localization
2. **Empty Bell Icon Action**: The bell icon button has an empty `onPressed` function (no navigation to notifications)
3. **Static Content**: Some UI elements like "Risk Management" button text are hardcoded instead of using translation

---

### 2.3 Home Cubit

**File**: [home_cubit.dart](frontend/lib/features/home/presentation/manager/home_cubit.dart)

```dart
class HomeCubit extends Cubit<HomeState> {
  final GetRiskUsecase _getRiskUsecase;

  HomeCubit(this._getRiskUsecase)
    : super(const HomeState(mealTime: 1, activity: 1, weight: 1, age: 1)) {
    _initializeUserData();
  }

  Future<void> _initializeUserData() async {
    try {
      // Assume user id is 0 - backend actually uses token to identify user
      final result = await _getRiskUsecase(0);
      result.fold(
        (failure) => _handleFailure(failure),
        (risk) => _updateStateFromRisk(risk),
      );
    } catch (e) {
      _handleError(e);
    }
  }
```

**Issues**:

1. **Hardcoded User ID**: Passes `0` as user ID to `_getRiskUsecase` - backend should use token for identification
2. **Incomplete State Initialization**: Initial state has hardcoded `weight: 1, age: 1` values
3. **Limited Error Handling**: Failure and error handling just print messages without user feedback
4. **Incomplete Risk Mapping**: `_updateStateFromRisk` only updates age, weight, and activity - ignores gender and marital status

---

### 2.4 Chat Page

**File**: [chat_page.dart](frontend/lib/features/chat/presentation/view/chat_page.dart)

```dart
class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (_) => BotCubit(
            createConversationUseCase: CreateConversationUseCase(
              BotRepositoryImpl(ApiService()),
            ),
            getConversationUseCase: GetConversationUseCase(
              BotRepositoryImpl(ApiService()),
            ),
            getAllConversationsUseCase: GetAllConversationUseCase(
              BotRepositoryImpl(ApiService()),
            ),
            deleteConversationUseCase: DeleteConversationUseCase(
              BotRepositoryImpl(ApiService()),
            ),
            sendMessageUseCase: SendMessageUseCase(
              BotRepositoryImpl(ApiService()),
            ),
            getAllMessagesUseCase: GetAllMessageUseCase(
              BotRepositoryImpl(ApiService()),
            ),
          ),
```

**Issues**:

1. **Direct Repository Instantiation**: BotCubit is created directly with new instances instead of using dependency injection
2. **No Initial Data Fetch**: Doesn't call `getAllConversations()` or `getAllMessages()` on initialization
3. **Hardcoded Conversation ID**: When sending messages, uses `conversationId: 0` which is hardcoded
4. **ListenWhen False**: BlocListener has `listenWhen: (previous, current) => false` which prevents scroll-to-bottom functionality

---

### 2.5 Archives Page

**File**: [archive_page.dart](frontend/lib/features/archives/presentaiton/view/archive_page.dart)

```dart
class ArchivesPage extends StatelessWidget {
  const ArchivesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = context.read<LocaleCubit>();

    return BlocProvider(
      create: (context) => sl<ArchiveCubit>()..fetchArchives(),
      child: BlocBuilder<ArchiveCubit, ArchiveState>(
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(title: Text(locale.translate('archives_page_title'))),
            body: _buildBody(state, locale),
          );
        },
      ),
    );
  }

  Widget _buildBody(ArchiveState state, LocaleCubit locale) {
    switch (state.status) {
      case ArchiveStatus.loading:
        return const Center(child: CircularProgressIndicator());
      case ArchiveStatus.error:
        return Center(
          child: Text(state.errorMessage ?? locale.translate('archives_error_message')),
        );
      case ArchiveStatus.success:
        if (state.archives.isEmpty) {
          return Center(child: Text(locale.translate('archives_empty_message')));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: state.archives.length,
          itemBuilder: (context, index) {
            final archive = state.archives[index];
            return ArchiveCard(
              archive: archive,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ArchiveDetailsPage(archive: archive),
                  ),
                );
              },
            );
          },
        );
      default:
        return const Center(child: CircularProgressIndicator());
    }
  }
}
```

**Status**: Fixed

1. **Localization Implemented**: AppBar title and messages now use localized strings
2. **Bloc Integration**: Uses ArchiveCubit to fetch and manage archives data
3. **State Management**: Handles loading, error, and empty states
4. **Direct Data Fetching**: No longer relies on parent widget to pass data

---

### 2.6 Settings Page

**File**: [settings_page.dart](frontend/lib/features/home/presentation/view/settings_page.dart)

```dart
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SettingsCubit(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            context.read<LocaleCubit>().translate('app_title'),
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: AppColor.textNeutral,
            ),
          ),
          centerTitle: true,
          backgroundColor: AppColor.backgroundNeutral,
          actions: [
            IconButton(
              icon: const Icon(CupertinoIcons.bell, color: AppColor.info),
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.notifications);
              },
            ),
          ],
```

**Status**: Fixed

1. **Localization Implemented**: AppBar title now uses `app_title` translation key
2. **Bell Icon Action**: Now navigates to notifications page using `AppRoutes.notifications`
3. **Logout Functionality**: Added logout button with confirmation dialog using `AuthCubit.logout()`
4. **Translated UI**: All text elements now use localization keys
5. **Formatted Code**: Improved code readability with proper indentation

---

### 2.7 Settings Cubit

**File**: [settings_cubit.dart](frontend/lib/features/home/presentation/manager/settings_cubit.dart)

```dart
class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit() : super(SettingsInitial.initial());

  void toggleSugarReminder(bool value) {
    if (state is SettingsInitial) {
      final current = state as SettingsInitial;
      emit(current.copyWith(sugarReminder: value));
    }
  }

  void toggleMedicineReminder(bool value) {
    if (state is SettingsInitial) {
      final current = state as SettingsInitial;
      emit(current.copyWith(medicineReminder: value));
    }
  }

  void toggleBiometric(bool value) {
    if (state is SettingsInitial) {
      final current = state as SettingsInitial;
      emit(current.copyWith(biometricLogin: value));
    }
  }
}
```

**Issues**:

1. **No API Integration**: Only toggles local state - doesn't update backend
2. **Limited State Management**: No methods for fetching or saving settings
3. **No Error Handling**: No handling for API failures
4. **Pseudo-Implementation**: Settings changes are not persistent

---

## 3. CRUD Operations Analysis

### 3.1 Chat CRUD Operations

**File**: [chat_cubit.dart](frontend/lib/features/chat/presentation/manager/chat_cubit.dart)

```dart
class BotCubit extends Cubit<BotState> {
  final CreateConversationUseCase createConversationUseCase;
  final GetConversationUseCase getConversationUseCase;
  final GetAllConversationUseCase getAllConversationsUseCase;
  final DeleteConversationUseCase deleteConversationUseCase;
  final SendMessageUseCase sendMessageUseCase;
  final GetAllMessageUseCase getAllMessagesUseCase;

  BotCubit({
    required this.createConversationUseCase,
    required this.getConversationUseCase,
    required this.getAllConversationsUseCase,
    required this.deleteConversationUseCase,
    required this.sendMessageUseCase,
    required this.getAllMessagesUseCase,
  }) : super(const BotInitial());

  Future<void> sendMessage(MessageEntity message) async {
    emit(const BotLoading());
    final result = await sendMessageUseCase(message);
    result.fold(
      (failure) => emit(BotError(failure)),
      (data) => emit(BotSuccess(data)),
    );
  }
```

**Issues**:

1. **Pseudo-Implementation**: Methods exist but are not properly connected to UI
2. **No Conversation Management**: Doesn't handle creating or managing conversations
3. **Message Flow Issues**: No logic to associate messages with conversations
4. **No Error Recovery**: Failed operations just show error state without retry options

---

### 3.2 Archives CRUD Operations

**File**: [archives_cubit.dart](frontend/lib/features/archives/presentaiton/manager/archives_cubit.dart)

```dart
class ArchiveCubit extends Cubit<ArchiveState> {
  final ArchiveRepository repository;

  ArchiveCubit({required this.repository}) : super(const ArchiveState());

  Future<void> fetchArchives() async {
    emit(state.copyWith(status: ArchiveStatus.loading));

    final result = await repository.getUserArchives();

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: ArchiveStatus.error,
          errorMessage: failure.message,
        ),
      ),
      (archives) => emit(
        state.copyWith(status: ArchiveStatus.success, archives: archives),
      ),
    );
  }

  Future<void> deleteArchive(int archiveId) async {
    final result = await repository.deleteArchive(archiveId);

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: ArchiveStatus.error,
          errorMessage: failure.message,
        ),
      ),
      (_) {
        final updatedList =
            state.archives.where((archive) => archive.id != archiveId).toList();

        emit(state.copyWith(archives: updatedList));
      },
    );
  }
}
```

**Issues**:

1. **Never Called**: fetchArchives() is defined but never called from UI
2. **No Update/Create**: Only fetch and delete operations implemented
3. **No Error Handling in UI**: Error states are emitted but not displayed to user
4. **No Loading State**: Loading status is emitted but not shown in UI

---

### 3.3 Risk CRUD Operations

**File**: [risk_page.dart](frontend/lib/features/risk/presentation/view/risk_page.dart)

```dart
class RiskPage extends StatefulWidget {
  const RiskPage({super.key});

  @override
  State<RiskPage> createState() => _RiskPageState();
}

class _RiskPageState extends State<RiskPage> {
  int? selectedRiskId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Risk Management')),
      body: BlocConsumer<RiskCubit, RiskState>(
        listener: (context, state) {
          if (state is RiskFailure) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          } else if (state is RiskCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Risk created successfully')),
            );
          } else if (state is RiskUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Risk updated successfully')),
            );
          } else if (state is RiskDeleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Risk deleted successfully')),
            );
            selectedRiskId = null;
          }
        },
```

**Issues**:

1. **Hardcoded UI Text**: All dialog texts ("Create New Risk", "Update Risk", etc.) are hardcoded
2. **No Initial Load**: Doesn't fetch existing risks on page load
3. **Risk Selection**: selectedRiskId is managed but not used to load specific risk
4. **Pregnancy Field**: Sugar pregnancy field is present but not properly explained
5. **No Validation**: Form fields have basic validation but no business logic validation

---

## 4. Summary of Hardcoded Values

| Page/Component | Hardcoded Value          | File               | Line |
| -------------- | ------------------------ | ------------------ | ---- |
| Home Content   | 'Risk Management' button | home_content.dart  | 279  |
| Home Cubit     | user id = 0              | home_cubit.dart    | 18   |
| Chat Page      | conversationId: 0        | chat_page.dart     | 183  |
| Chat Page      | listenWhen: false        | chat_page.dart     | 134  |
| Settings Page  | 'GlucoTrack' title       | settings_page.dart | 24   |
| Settings Page  | Logout button action     | settings_page.dart | 111  |
| Settings Page  | Bell icon action         | settings_page.dart | 36   |
| Risk Page      | "Risk Management" title  | risk_page.dart     | 20   |
| Risk Page      | "Create New Risk" dialog | risk_page.dart     | 81   |
| Risk Page      | "Update Risk" dialog     | risk_page.dart     | 308  |

---

## 5. Summary of Pseudo-Implemented CRUD Operations

### 5.1 Archives

- **Fetch**: Defined but never called from UI
- **Delete**: Implemented but UI doesn't have delete button
- **Create**: Not implemented
- **Update**: Not implemented

### 5.2 Chat

- **Send Message**: Implemented but uses hardcoded conversationId
- **Fetch Messages**: Defined but never called
- **Create Conversation**: Defined but never called
- **Fetch Conversations**: Defined but never called
- **Delete Conversation**: Defined but never called

### 5.3 Settings

- **Toggle Reminders**: Only updates local state, no backend call
- **Change Password**: UI exists but no implementation
- **Update Profile**: Navigation exists but implementation incomplete
- **Logout**: UI exists but no implementation

### 5.4 Risk

- **Create**: Implemented with basic form
- **Update**: Implemented with basic form
- **Delete**: Implemented
- **Fetch**: Not implemented (no initial load)

---

## 6. Recommended Fixes

### 6.1 Home Page Fixes

1. Replace hardcoded ArchivesPage with BlocBuilder to fetch real data
2. Initialize ArchiveCubit and call fetchArchives() on page load
3. Add loading/error states for archives

### 6.2 Home Content Fixes

1. Use localization for all text elements
2. Implement notifications navigation for bell icon
3. Connect Risk Management button to actual risk assessment

### 6.3 Home Cubit Fixes

1. Remove hardcoded user id - use token for authentication
2. Complete state initialization with proper defaults
3. Add proper error handling with user feedback
4. Complete risk to state mapping

### 6.4 Chat Page Fixes

1. Use dependency injection for BotCubit
2. Fetch conversations and messages on initialization
3. Implement conversation management
4. Fix scroll-to-bottom functionality

### 6.5 Archives Page Fixes

1. Use BlocBuilder with ArchiveCubit
2. Add loading/error/empty states
3. Add delete functionality
4. Implement pull-to-refresh

### 6.6 Settings Page Fixes

1. Implement logout functionality
2. Connect reminder toggles to backend API
3. Implement change password functionality
4. Add biometric login support

### 6.7 Settings Cubit Fixes

1. Add API calls for updating settings
2. Add method to fetch settings from backend
3. Implement proper error handling
4. Add loading states for API calls

---

## 7. Priority Levels

### High Priority

1. **Archives Data Fetch**: Implement real data fetching
2. **Chat Initialization**: Fix chat data loading
3. **Risk Initial Load**: Fetch existing risks on page load
4. **Settings Functionality**: Implement logout and password change

### Medium Priority

1. **Localization**: Fix all hardcoded text
2. **Error Handling**: Improve error feedback to users
3. **Conversation Management**: Implement proper chat flow

### Low Priority

1. **Biometric Login**: Implement biometric authentication
2. **Advanced Validation**: Add business logic validation
3. **UI Improvements**: Enhance loading and empty states

---

## 8. Conclusion

The home pages and tabs contain several hardcoded values and pseudo-implementations of CRUD operations. The most critical issues are:

1. Archives page showing empty data
2. Chat page not initializing with conversations
3. Settings page having non-functional buttons
4. Risk page not fetching existing risks
5. Hardcoded user ID in HomeCubit

These issues need to be addressed to provide a functional and user-friendly experience. The fixes should focus on connecting UI components to real backend API calls and properly managing application state using BLoC.

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
