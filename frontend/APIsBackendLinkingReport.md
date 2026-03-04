# GlucoTrack Frontend APIs and Backend Linking Analysis

## Overview

This report analyzes the API architecture, backend integration, and service implementations in the GlucoTrack Flutter frontend application. The codebase follows a clean architecture pattern with separate layers for presentation, domain, and data, with API communication handled through Dio HTTP client.

---

## API Architecture Analysis

### 1. Duplicate ApiService Classes

**Issue:** There are two separate `ApiService` implementations causing confusion:

1. **Simple API Service** ([`api_service.dart`](lib/core/api/api_service.dart:1-48))
   - Basic CRUD operations with Dio
   - Returns raw dynamic data
   - Uses ApiExceptions for error handling
   - Used by: AuthRepositoryImpl, UserRepositoryImpl

2. **Enhanced API Service** ([`api_service.dart`](lib/core/helperfile/api_service.dart:1-147))
   - Generic API service with ResponseModel wrapper
   - Type-safe response handling
   - Comprehensive error mapping
   - Implements all chat functionality
   - Used by: BotRepositoryImpl

**Recommendation:** Refactor to a single, unified ApiService class following the ResponseModel pattern for consistency.

---

### 2. API Endpoints Configuration

**File:** [`end_point.dart`](lib/core/api/end_point.dart:1-41)

The application uses a centralized endpoint configuration with the following API groups:

| Feature              | Endpoints                                                                       | Methods                |
| -------------------- | ------------------------------------------------------------------------------- | ---------------------- |
| **Auth**             | `/auth/login`                                                                   | POST                   |
| **User**             | `/user/`, `/user/{id}`                                                          | GET, POST, PUT         |
| **Bot Conversation** | `/bot/conversation`, `/bot/conversation/{id}`, `/bot/conversation/all/{userId}` | GET, POST, DELETE      |
| **Bot Messages**     | `/bot/message`, `/bot/message/all/{convId}`                                     | GET, POST              |
| **Risk**             | `/risk/`, `/risk/{id}`                                                          | GET, POST, PUT, DELETE |
| **Meal**             | `/meal/`, `/meal/{id}`                                                          | GET, POST              |
| **Analysis**         | `/analyse/all/{id}`, `/analyse/{id}`                                            | GET, DELETE            |
| **OTP**              | `/otp/check`, `/otp/forgot-password`, `/otp/verify-otp`, `/otp/reset-password`  | GET, POST              |

---

## Repository Implementations

### 1. Bot (Chat) Repository

**File:** [`chat_repo_impl.dart`](lib/features/chat/repo/chat_repo_impl.dart:1-113)

**Features Implemented:**

- Create conversation
- Get conversation by ID
- Get all conversations for user
- Delete conversation
- Send message
- Get all messages in conversation

**Architecture:**

- Uses helperfile ApiService (with ResponseModel)
- Converts data models to entities
- Handles failures with Either<Failure, T> pattern
- Comprehensive error mapping (401, 422, 500, network errors)

**Backend Linking:**

```
BotRepositoryImpl → ApiService (helperfile) → DioClient → Backend API
```

---

### 2. Auth Repository

**File:** [`auth_repo_impl.dart`](lib/features/auth/repo/auth_repo_impl.dart:1-95)

**Features Implemented:**

- Login
- Logout
- OTP verification
- Auto-login (token-based)
- Current user management

**Architecture:**

- Uses core ApiService (simple CRUD)
- Direct Dio exception handling
- Token management via PrefHelper
- Dependency on UserRepository for auto-login

**Backend Linking:**

```
AuthRepoImpl → ApiService (core) → DioClient → Backend API
```

**Issues:**

- Uses different ApiService implementation than chat feature
- Manual response parsing without type safety
- Token management is tightly coupled

---

### 3. User Repository

**File:** [`user_repo_impl.dart`](lib/features/user/repo/user_repo_impl.dart:1-105)

**Features Implemented:**

- Create user
- Get user profile
- Update user profile

**Architecture:**

- Uses core ApiService (simple CRUD)
- Direct Dio exception handling
- Token management via PrefHelper
- Returns UserModel objects

**Backend Linking:**

```
UserRepositoryImpl → ApiService (core) → DioClient → Backend API
```

**Issues:**

- Uses different ApiService implementation than chat feature
- Manual response parsing
- Token handling duplicated across repositories

---

### 4. Archive Repository

**File:** [`archive_repo_impl.dart`](lib/features/archives/repo/archive_repo_impl.dart:1-26)

**Features Implemented:**

- Get user archives
- Delete archive

**Architecture:**

- Direct Dio usage (bypasses ApiService)
- Minimal error handling
- Simple data mapping

**Backend Linking:**

```
ArchiveRepositoryImpl → Dio → Backend API
```

**Issues:**

- Bypasses ApiService abstraction
- No error handling or response validation
- No type safety
- Least robust implementation

---

## Dependency Injection & Service Locator

**File:** [`main.dart`](lib/main.dart:1-91)

**Current Implementation:**

```dart
BlocProvider(create: (context) {
  final apiService = ApiService();
  final userRepo = UserRepositoryImpl(apiService);
  final authRepo = AuthRepoImpl(apiService, null, userRepo);
  return AuthCubit(authRepo);
}),
BlocProvider(create: (_)=>UserCubit(UserRepositoryImpl(ApiService()))),
```

**Issues:**

- Manual dependency injection in main.dart
- No service locator pattern
- Duplicate ApiService instances created
- Tight coupling between providers

---

## Data Flow Architecture

### Success Flow

```
UI Layer (Flutter Widgets)
    ↓
Presentation Layer (Bloc Cubits)
    ↓
Domain Layer (Use Cases)
    ↓
Data Layer (Repositories)
    ↓
API Layer (ApiService → DioClient)
    ↓
Backend API (REST endpoints)
```

### Error Flow

```
Backend Error (HTTP status code)
    ↓
ApiService (error handling)
    ↓
Repository (Failure mapping)
    ↓
Bloc Cubit (state management)
    ↓
UI Layer (error display)
```

---

## Key Technical Issues

### 1. Inconsistent ApiService Usage

- **Auth & User Repos:** Use core/api_service.dart (simple CRUD)
- **Chat Repo:** Uses helperfile/api_service.dart (ResponseModel)
- **Archive Repo:** Direct Dio usage

### 2. Missing API Methods

- User repository missing update endpoint in ApiEndpoints
- Archive repository endpoints not defined in ApiEndpoints
- No endpoints for meal update/delete operations

### 3. Response Handling

- Chat repo uses ResponseModel<dynamic> - should use specific types
- Auth and user repos have manual response parsing
- No consistent error mapping across all repositories

### 4. Token Management

- Token stored in SharedPreferences (PrefHelper)
- No interceptor for automatic token refresh
- Token validation logic duplicated

### 5. Dependency Management

- No service locator (get_it or provider)
- Manual dependency injection
- Duplicate instances of ApiService

---

## Features & Services Analysis

### Implemented Features

1. **Authentication**
   - Login with email/password
   - OTP verification
   - Forgot/reset password
   - Auto-login with token

2. **User Management**
   - Create user
   - Get user profile
   - Update profile
   - Logout

3. **Chat/Bot System**
   - Create conversations
   - Get conversations
   - Send messages
   - Get messages
   - Delete conversations

4. **Archives**
   - Get user archives
   - Delete archives

5. **Risk Management** (API endpoints only)
   - Create risk
   - Get risk
   - Update risk
   - Delete risk

6. **Meal Tracking** (API endpoints only)
   - Create meal
   - Get meal

---

## Backend Integration Status

### Fully Implemented

- ✅ Authentication flow (login, OTP, forgot password)
- ✅ User profile management
- ✅ Chat/bot conversations
- ✅ Archive management

### Partially Implemented

- ⚠️ Risk management (API endpoints only, no UI)
- ⚠️ Meal tracking (API endpoints only, no UI)

### Not Implemented

- ❌ Analysis retrieval (API endpoints exist, no implementation)
- ❌ Real-time chat functionality
- ❌ Push notifications
- ❌ Data synchronization

---

## Code Quality & Best Practices

### Strengths

1. Clean architecture separation
2. Type-safe entity/data model conversion
3. Comprehensive error handling in chat feature
4. Centralized endpoint configuration

### Weaknesses

1. Duplicate ApiService implementations
2. Inconsistent response handling patterns
3. Missing type safety in some repositories
4. No proper dependency injection
5. Direct Dio usage bypassing ApiService abstraction
6. Token management duplication

---

## Recommendations

### 1. ApiService Refactor (Priority: High)

```
Create a single, unified ApiService following the ResponseModel pattern
that includes all missing methods:
- User update endpoints
- Meal update/delete endpoints
- Archive endpoints
- Analysis endpoints
```

### 2. Repository Standardization (Priority: High)

```
Update all repositories to use the unified ApiService:
- AuthRepoImpl
- UserRepoImpl
- ArchiveRepoImpl

Standardize response handling and error mapping
```

### 3. Dependency Injection (Priority: Medium)

```
Implement get_it package for service locator pattern
Create module for dependencies:
- ApiService instance
- Repositories
- Cubits
```

### 4. Type Safety Improvements (Priority: Medium)

```
Add type parameters to ApiService:
- ResponseModel<T> instead of ResponseModel<dynamic>
- Type-safe converters for all API responses
```

### 5. Token Management (Priority: High)

```
Implement Dio interceptor for:
- Automatic token injection in headers
- Token refresh on 401 errors
- Centralized token validation
```

### 6. Error Handling (Priority: Medium)

```
Create unified failure classes for all features
Standardize error mapping across repositories
Add error reporting/logging mechanism
```

---

## Overall Assessment

The GlucoTrack frontend codebase has a solid architectural foundation with clean separation of concerns. However, the API layer suffers from inconsistencies due to duplicate ApiService implementations and varying response handling patterns. The chat feature has the most robust implementation, while other features lack type safety and proper error handling.

**Score:** 6.5/10

**Key Improvements Needed:**

1. Unified ApiService architecture
2. Standardized repository implementations
3. Proper dependency injection
4. Enhanced error handling and type safety

With these improvements, the codebase will become more maintainable, scalable, and resilient to future changes.
