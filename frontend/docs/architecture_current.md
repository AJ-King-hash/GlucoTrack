# GlucoTrack - Current Architecture Documentation

## Phase 0: Preparation & Safety Net

**Status:** ✅ Completed  
**Date:** 2026-03-21

---

## Project Overview

GlucoTrack is a Flutter-based glucose tracking application that helps users monitor their blood glucose levels, meals, and overall health metrics.

**Current Project Name:** `untitled10` (in pubspec.yaml)  
**Recommended Name:** `glucotrack`

---

## Current Folder Structure

```
frontend/
├── lib/
│   ├── main.dart
│   ├── core/
│   │   ├── injection_container.dart
│   │   ├── api/
│   │   │   ├── api_error.dart
│   │   │   ├── api_exceptions.dart
│   │   │   ├── api_service.dart
│   │   │   ├── auth_interceptor.dart
│   │   │   ├── dio_client.dart
│   │   │   └── end_point.dart
│   │   ├── base_usecase/
│   │   │   └── base_usecase.dart
│   │   ├── color/
│   │   │   └── app_color.dart
│   │   ├── constants/                    [NEW] Phase 0
│   │   │   └── app_constants.dart
│   │   ├── error/                        [NEW] Phase 0
│   │   │   └── app_exception.dart
│   │   ├── errors/
│   │   │   └── failure.dart
│   │   ├── hive/
│   │   │   └── hive_service.dart
│   │   ├── localization/
│   │   │   ├── locale_cubit.dart
│   │   │   └── locale_state.dart
│   │   ├── routes/
│   │   │   └── app_routes.dart
│   │   ├── services/
│   │   │   ├── navigation_service.dart
│   │   │   └── notification_service.dart
│   │   ├── utils/
│   │   │   ├── bmi_ui_logic.dart
│   │   │   ├── either.dart
│   │   │   ├── global_refresher.dart     [NEW] Phase 0
│   │   │   ├── handle_error.dart
│   │   │   ├── health_utils.dart
│   │   │   ├── logger.dart               [NEW] Phase 0
│   │   │   ├── pagination_params.dart
│   │   │   ├── pref_helper.dart
│   │   │   ├── show_meal_bottom_sheet.dart
│   │   │   ├── source_storage_service.dart
│   │   │   ├── time_formater.dart
│   │   │   └── toast_utility.dart
│   │   └── widgets/
│   │       ├── app_button.dart
│   │       ├── app_logo.dart
│   │       ├── app_text_feild.dart
│   │       ├── auth_background.dart
│   │       ├── custom_icon_widget.dart
│   │       ├── filter_widget.dart
│   │       ├── language_bottom_sheet.dart
│   │       ├── pagination_widget.dart
│   │       ├── search_bar_widget.dart
│   │       └── states/
│   │           ├── empty_state.dart
│   │           ├── error_state.dart
│   │           └── loading_state.dart
│   ├── features/
│   │   ├── archives/
│   │   ├── auth/
│   │   ├── chat/
│   │   ├── home/
│   │   ├── meal/
│   │   ├── notification/
│   │   ├── risk/
│   │   └── user/
│   └── l10n/
├── assets/
│   ├── images/
│   ├── lottie/
│   └── lan/
├── android/
├── ios/
└── docs/
    ├── NOTIFICATION_DEPLOYMENT.md
    └── architecture_current.md            [NEW] Phase 0
```

---

## Main Dependencies & Their Roles

### State Management

- **flutter_bloc** (^9.1.1) - Primary state management solution using BLoC pattern
- **equatable** (^2.0.7) - Value equality for BLoC states

### Networking

- **dio** (^5.9.0) - HTTP client for API calls
- **pretty_dio_logger** (^1.4.0) - HTTP request/response logging
- **jwt_decoder** (^2.0.1) - JWT token decoding and validation

### Local Storage

- **shared_preferences** (^2.5.3) - Simple key-value storage
- **hive** (^2.2.3) - NoSQL database for structured data
- **hive_flutter** (^1.1.0) - Flutter integration for Hive
- **flutter_secure_storage** (^10.0.0) - Secure storage for sensitive data

### UI & UX

- **flutter_screenutil** (^5.9.3) - Responsive screen adaptation
- **sizer** (^3.1.3) - Alternative responsive sizing
- **circular_bottom_navigation** (^2.4.0) - Bottom navigation UI
- **lottie** (^3.1.0) - Lottie animations
- **smooth_page_indicator** (^2.0.1) - Page indicators
- **fluttertoast** (^8.2.10) - Toast notifications

### Localization

- **intl** (0.20.2) - Internationalization support
- **flutter_localizations** (SDK) - Flutter localization framework

### Firebase & Notifications

- **firebase_core** (^3.12.1) - Firebase initialization
- **firebase_messaging** (^15.2.4) - Push notifications
- **flutter_local_notifications** (^18.0.1) - Local notifications
- **timezone** (^0.10.0) - Timezone handling for notifications

### Dependency Injection

- **get_it** (^9.2.0) - Service locator for dependency injection

### Code Generation

- **json_annotation** (^4.9.0) - JSON serialization annotations
- **json_serializable** (^6.7.1) - JSON code generation
- **hive_generator** (^2.0.1) - Hive type adapter generation
- **build_runner** (^2.4.8) - Code generation runner

### Development

- **flutter_lints** (^6.0.0) - Linting rules

---

## Current Pain Points & Observations

### 1. Inconsistent State Handling

- Multiple error/failure classes exist (`api_error.dart`, `api_exceptions.dart`, `failure.dart`)
- No unified exception hierarchy (now addressed with `app_exception.dart`)
- Error handling patterns vary across features

### 2. Logic in Widgets

- Business logic appears to be embedded in widget files
- `show_meal_bottom_sheet.dart` (11KB) suggests complex UI logic
- `bmi_ui_logic.dart` indicates UI-specific calculations

### 3. Missing Refresh Pattern

- No centralized mechanism for cross-screen data refresh
- Each feature likely implements its own refresh logic
- Now addressed with `global_refresher.dart`

### 4. Project Structure Issues

- Flutter project nested inside `frontend/` directory (should be at repo root)
- Project name is `untitled10` instead of `glucotrack`
- Duplicate error handling folders (`error/` and `errors/`)

### 5. API Configuration

- API base URL appears to be hardcoded in `end_point.dart`
- No centralized constants file (now addressed with `app_constants.dart`)

### 6. Logging

- No structured logging mechanism (now addressed with `logger.dart`)
- Likely using `print` statements throughout codebase

### 7. Feature Organization

- Features are organized by domain (auth, home, meal, etc.)
- Each feature likely has its own data/domain/presentation layers
- No clear separation of concerns visible at top level

---

## Phase 0 Completed — Safety Net & Docs

### New Files Created

1. **`lib/core/constants/app_constants.dart`**
   - Centralized application constants
   - API configuration, storage keys, glucose ranges
   - Animation durations, notification channels

2. **`lib/core/error/app_exception.dart`**
   - Unified exception hierarchy
   - Base `AppException` class
   - Specialized exceptions: `ServerException`, `CacheException`, `NetworkException`, `UnauthorizedException`, `ValidationException`, `NotFoundException`, `TimeoutException`

3. **`lib/core/utils/logger.dart`**
   - Structured logging utility
   - Log levels: debug, info, warning, error, fatal
   - Tag-based logging for component identification
   - Debug-mode only output

4. **`lib/core/utils/global_refresher.dart`**
   - Cross-screen refresh mechanism
   - Stream-based refresh events
   - Key-based refresh for targeted updates
   - Singleton pattern for global access

5. **`docs/architecture_current.md`** (this file)
   - Current architecture documentation
   - Folder structure overview
   - Dependency analysis
   - Pain points identification

### Configuration Updates

- **`analysis_options.yaml`** - Added `avoid_print: false` rule (temporary allowance during refactor)

### CI/CD Setup

- **`.github/workflows/flutter.yml`** - Basic CI pipeline for analysis and build

---

## Next Steps (Phase 1+)

1. **Move Flutter project to repo root** - Eliminate `frontend/` nesting
2. **Rename project** - Change from `untitled10` to `glucotrack`
3. **Unify error handling** - Migrate to `app_exception.dart` hierarchy
4. **Implement clean architecture** - Separate data/domain/presentation layers
5. **Add unit tests** - Establish test coverage baseline
6. **Refactor large widgets** - Extract business logic from UI components
7. **Standardize state management** - Consistent BLoC patterns across features

---

## Notes

- All Phase 0 changes are **additive only** - no existing code was modified
- App behavior remains **exactly the same** as before Phase 0
- New utilities are available for use but not yet integrated
- This documentation serves as a baseline for future refactoring phases
