# Password Change Logout Implementation Plan

## Problem Analysis

When a user changes their password, the application does NOT log them out. This is a **security vulnerability** because:

1. The old JWT token remains valid even after the password change
2. Anyone with access to the old token can continue to access the account
3. The user should be forced to re-authenticate with the new password

## Root Cause

### Backend Issue

- In [`Backend/repositories/userRepo.py`](Backend/repositories/userRepo.py:40), the `update()` function updates the password but does NOT invalidate the existing JWT token
- The backend has a token blacklist mechanism in [`Backend/JwtToken.py`](Backend/JwtToken.py:9) (`token_blacklist` set) but it's not being used during password change
  wha

### Frontend Issue

- In [`frontend/lib/features/home/presentation/widgets/change_password_bottom_sheet.dart`](frontend/lib/features/home/presentation/widgets/change_password_bottom_sheet.dart:109), after successful password change, it only:
  - Shows a success message
  - Pops the bottom sheet
  - Does NOT log out the user or redirect to login screen

## Implementation Plan

### Phase 1: Backend Changes

#### 1.1 Modify User Router to Accept Token for Invalidation

**File:** [`Backend/routers/user.py`](Backend/routers/user.py:25)

- Update the `update_user` endpoint to accept the current JWT token
- Pass the token to the repository layer for invalidation

```python
@router.put("/", response_model=schemas.ShowUserWithMessage)
def update_user(
    request: schemas.UserUpdate,
    db: Session = Depends(get_db),
    current_user: schemas.User = Depends(oauth2.get_current_user),
    current_token: str = Depends(oauth2.get_current_token)  # Add this
):
    # If password is being changed, invalidate the token
    if request.password and request.old_password:
        from JwtToken import DeleteToken
        credentials_exception = HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Not Authorized",
            headers={"WWW-Authenticate": "Bearer"},
        )
        DeleteToken(current_token, credentials_exception)

    return {"message": "User updated successfully", "user": userRepo.update(current_user.id, request, db)}
```

#### 1.2 Update Response Schema for Password Change

**File:** [`Backend/schemas.py`](Backend/schemas.py:101)

- Add a new response schema that includes a flag indicating if logout is required

```python
class ShowUserWithMessageAndLogout(BaseModel):
    message: str
    user: ShowUser
    requires_logout: bool = False
    class Config():
        from_attributes = True
```

#### 1.3 Update User Router Response

**File:** [`Backend/routers/user.py`](Backend/routers/user.py:25)

- Return `requires_logout: True` when password is changed

```python
@router.put("/", response_model=schemas.ShowUserWithMessageAndLogout)
def update_user(...):
    requires_logout = False
    if request.password and request.old_password:
        # Invalidate token logic
        requires_logout = True

    return {
        "message": "User updated successfully",
        "user": userRepo.update(current_user.id, request, db),
        "requires_logout": requires_logout
    }
```

### Phase 2: Frontend Changes

#### 2.1 Update User Repository to Handle Logout Response

**File:** [`frontend/lib/features/user/repo/user_repo.dart`](frontend/lib/features/user/repo/user_repo.dart)

- Update the `updateUser` method to return a response that includes logout flag
- Or create a new method specifically for password change

#### 2.2 Update User Cubit to Handle Password Change Logout

**File:** [`frontend/lib/features/user/presentation/manager/user_cubit.dart`](frontend/lib/features/user/presentation/manager/user_cubit.dart:83)

- Add a new method `changePassword()` that:
  1. Calls the API to change password
  2. If successful, calls `authRepository.logout()`
  3. Emits a special state `UserPasswordChanged` to trigger navigation

```dart
Future<void> changePassword({
  required String oldPassword,
  required String newPassword,
}) async {
  emit(UserLoading());
  try {
    final result = await userRepository.changePassword(
      oldPassword: oldPassword,
      newPassword: newPassword,
    );
    result.fold(
      (failure) {
        ToastUtility.showError(failure.message);
        emit(UserError(failure.message));
      },
      (success) {
        // Logout the user after password change
        authRepository.logout();
        emit(UserPasswordChanged());
      },
    );
  } catch (e) {
    String errorMsg = "Error changing password";
    if (e is ApiError) {
      errorMsg = e.message;
    }
    ToastUtility.showError(errorMsg);
    emit(UserError(errorMsg));
  }
}
```

#### 2.3 Add New User State for Password Change

**File:** [`frontend/lib/features/user/presentation/manager/user_state.dart`](frontend/lib/features/user/presentation/manager/user_state.dart)

- Add a new state class `UserPasswordChanged`

```dart
class UserPasswordChanged extends UserState {
  const UserPasswordChanged();
}
```

#### 2.4 Update Change Password Bottom Sheet

**File:** [`frontend/lib/features/home/presentation/widgets/change_password_bottom_sheet.dart`](frontend/lib/features/home/presentation/widgets/change_password_bottom_sheet.dart:109)

- Update the `_changePassword()` method to:
  1. Use the new `changePassword()` method from UserCubit
  2. Listen for `UserPasswordChanged` state
  3. Navigate to login screen when password is changed

```dart
Future<void> _changePassword() async {
  if (!_validatePasswords()) {
    return;
  }

  setState(() => _isLoading = true);

  try {
    await context.read<UserCubit>().changePassword(
      oldPassword: _oldPasswordController.text.trim(),
      newPassword: _newPasswordController.text.trim(),
    );

    if (!mounted) return;

    // The UserCubit will emit UserPasswordChanged state
    // which will be handled by the BlocListener in the parent widget
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.read<LocaleCubit>().translate('password_change_failed'),
          ),
          backgroundColor: AppColor.negative,
        ),
      );
    }
  } finally {
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }
}
```

#### 2.5 Add BlocListener in Parent Widget

**File:** [`frontend/lib/features/home/presentation/widgets/home_content.dart`](frontend/lib/features/home/presentation/widgets/home_content.dart)

- Add a BlocListener to listen for `UserPasswordChanged` state
- Navigate to login screen when password is changed

```dart
BlocListener<UserCubit, UserState>(
  listener: (context, state) {
    if (state is UserPasswordChanged) {
      // Navigate to login screen
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/login',
        (route) => false,
      );
    }
  },
  child: // ... existing widgets
)
```

### Phase 3: Testing

#### 3.1 Backend Testing

- Test password change endpoint with valid old password
- Test password change endpoint with invalid old password
- Verify token is invalidated after password change
- Verify old token cannot be used after password change

#### 3.2 Frontend Testing

- Test password change flow
- Verify user is logged out after password change
- Verify user is redirected to login screen
- Verify user can login with new password
- Verify user cannot login with old password

## Files to Modify

### Backend

1. [`Backend/routers/user.py`](Backend/routers/user.py) - Add token invalidation logic
2. [`Backend/schemas.py`](Backend/schemas.py) - Add new response schema with logout flag

### Frontend

1. [`frontend/lib/features/user/repo/user_repo.dart`](frontend/lib/features/user/repo/user_repo.dart) - Add changePassword method
2. [`frontend/lib/features/user/presentation/manager/user_cubit.dart`](frontend/lib/features/user/presentation/manager/user_cubit.dart) - Add changePassword method
3. [`frontend/lib/features/user/presentation/manager/user_state.dart`](frontend/lib/features/user/presentation/manager/user_state.dart) - Add UserPasswordChanged state
4. [`frontend/lib/features/home/presentation/widgets/change_password_bottom_sheet.dart`](frontend/lib/features/home/presentation/widgets/change_password_bottom_sheet.dart) - Update to use new changePassword method
5. [`frontend/lib/features/home/presentation/widgets/home_content.dart`](frontend/lib/features/home/presentation/widgets/home_content.dart) - Add BlocListener for password change

## Security Considerations

1. **Token Invalidation**: The old JWT token must be invalidated immediately after password change
2. **Force Re-authentication**: User must be forced to login with the new password
3. **Session Termination**: All active sessions should be terminated (if multiple devices are supported)
4. **Password Verification**: Old password must be verified before allowing password change

## Alternative Approach (Simpler)

If the above approach is too complex, a simpler alternative is:

### Backend Only Change

1. In [`Backend/routers/user.py`](Backend/routers/user.py:25), when password is changed:
   - Invalidate the current token using `DeleteToken()`
   - Return a response indicating logout is required

### Frontend Only Change

1. In [`frontend/lib/features/home/presentation/widgets/change_password_bottom_sheet.dart`](frontend/lib/features/home/presentation/widgets/change_password_bottom_sheet.dart:109):
   - After successful password change, call `authRepository.logout()`
   - Navigate to login screen

This simpler approach doesn't require changing the response schema or adding new states.

## Recommended Approach

I recommend the **simpler approach** because:

1. It requires fewer changes
2. It's easier to implement and test
3. It achieves the same security goal
4. It's less likely to introduce bugs

## Implementation Steps (Simpler Approach)

### Step 1: Backend - Invalidate Token on Password Change

**File:** [`Backend/routers/user.py`](Backend/routers/user.py:25)

```python
@router.put("/", response_model=schemas.ShowUserWithMessage)
def update_user(
    request: schemas.UserUpdate,
    db: Session = Depends(get_db),
    current_user: schemas.User = Depends(oauth2.get_current_user),
    current_token: str = Depends(oauth2.get_current_token)
):
    # If password is being changed, invalidate the token
    if request.password and request.old_password:
        from JwtToken import DeleteToken
        credentials_exception = HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Not Authorized",
            headers={"WWW-Authenticate": "Bearer"},
        )
        DeleteToken(current_token, credentials_exception)

    return {"message": "User updated successfully", "user": userRepo.update(current_user.id, request, db)}
```

### Step 2: Frontend - Logout After Password Change

**File:** [`frontend/lib/features/home/presentation/widgets/change_password_bottom_sheet.dart`](frontend/lib/features/home/presentation/widgets/change_password_bottom_sheet.dart:109)

```dart
Future<void> _changePassword() async {
  if (!_validatePasswords()) {
    return;
  }

  setState(() => _isLoading = true);

  try {
    // Get the current user from the cubit
    final userState = context.read<UserCubit>().state;

    if (userState is! UserLoaded) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.read<LocaleCubit>().translate('password_change_failed'),
            ),
            backgroundColor: AppColor.negative,
          ),
        );
      }
      return;
    }

    final currentUser = userState.userModel;

    // Call the updateUser method with current data and new password
    await context.read<UserCubit>().updateUser(
      name: currentUser.name,
      email: currentUser.email,
      password: _newPasswordController.text.trim(),
      oldPassword: _oldPasswordController.text.trim(),
    );

    // Check the state after the update (captured after await)
    if (!mounted) return;
    final newState = context.read<UserCubit>().state;

    if (newState is UserError) {
      // Show the error message from the API (e.g., "Incorrect old password")
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(newState.message),
          backgroundColor: AppColor.negative,
        ),
      );
      return;
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.read<LocaleCubit>().translate(
              'password_changed_successfully',
            ),
          ),
          backgroundColor: AppColor.positive,
        ),
      );

      // Logout the user after password change
      await context.read<AuthCubit>().logout();

      // Navigate to login screen
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/login',
        (route) => false,
      );
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.read<LocaleCubit>().translate('password_change_failed'),
          ),
          backgroundColor: AppColor.negative,
        ),
      );
    }
  } finally {
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }
}
```

## Summary

The issue is that when a user changes their password, the JWT token is not invalidated and the user is not logged out. This is a security vulnerability.

The solution involves:

1. **Backend**: Invalidate the JWT token when password is changed
2. **Frontend**: Logout the user and redirect to login screen after password change

The recommended approach is the simpler one, which requires minimal changes to both backend and frontend.
