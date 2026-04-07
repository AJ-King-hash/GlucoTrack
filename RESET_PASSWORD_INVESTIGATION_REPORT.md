ouhe# Reset Password Feature - Comprehensive Investigation Report

## Executive Summary

This report provides a detailed analysis of the reset password feature in the GlucoTrack application, identifying critical issues and providing a comprehensive implementation plan. The investigation covers both frontend (Flutter/Dart) and backend (Python/FastAPI) components.

---

## Table of Contents

1. [Issue #1: OTP Digit Mismatch (6-digit vs 4-digit)](#issue-1-otp-digit-mismatch)
2. [Issue #2: Missing Toast on Submit Error](#issue-2-missing-toast-on-submit-error)
3. [Issue #3: Navigation Flow After OTP Verification](#issue-3-navigation-flow-after-otp-verification)
4. [Issue #4: Redirect to Login After Password Reset](#issue-4-redirect-to-login-after-password-reset)
5. [Issue #5: UI/UX Improvements](#issue-5-uiux-improvements)
6. [Implementation Plan](#implementation-plan)
7. [Code Changes Required](#code-changes-required)
8. [Testing Checklist](#testing-checklist)

---

## Issue #1: OTP Digit Mismatch (6-digit vs 4-digit)

### Problem Description

**Critical Mismatch:** The backend generates and sends a **6-digit OTP** to the user's email, but the frontend UI only accepts **4 digits**.

### Backend Analysis

**File:** [`Backend/routers/otp.py`](Backend/routers/otp.py:66)

```python
# Line 66: Backend generates 6-digit OTP
otp = secrets.randbelow(900000) + 100000  # 6 digits
otp_str = str(otp)
```

**File:** [`Backend/repositories/otpRepo.py`](Backend/repositories/otpRepo.py:75)

```python
# Line 75: OTP is stored as 6-digit string
new_otp=models.Otp(email=email,otp=otp,expires=expiry_time)
```

**File:** [`Backend/templates/email_otp.html`](Backend/templates/email_otp.html:22)

```html
<!-- Line 22: Email displays the 6-digit OTP -->
<h1>{{ otp }}</h1>
```

### Frontend Analysis

**File:** [`frontend/lib/features/auth/presentaion/view/otp_page.dart`](frontend/lib/features/auth/presentaion/view/otp_page.dart:31)

```dart
// Line 31: Frontend creates only 4 OTP input boxes
controllers = List.generate(4, (_) => TextEditingController());
```

**File:** [`frontend/lib/features/auth/presentaion/view/otp_page.dart`](frontend/lib/features/auth/presentaion/view/otp_page.dart:126-142)

```dart
// Lines 126-142: UI renders only 4 OTP boxes
Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: List.generate(
    4,  // ← Only 4 boxes!
    (index) => SizedBox(
      width: 65.w,
      child: OtpBox(
        controller: controllers[index],
        autoFocus: index == 0,
        onChanged: (value) {
          if (value.length == 1 && index < 3) {  // ← Only checks up to index 3
            FocusScope.of(context).nextFocus();
          }
        },
        validator: (value) => value!.isEmpty ? '' : null,
      ),
    ),
  ),
),
```

**File:** [`frontend/lib/features/auth/presentaion/view/otp_page.dart`](frontend/lib/features/auth/presentaion/view/otp_page.dart:158-160)

```dart
// Lines 158-160: OTP is concatenated from 4 controllers
final otp = controllers.map((e) => e.text).join();
cubit.verifyOtp(widget.email!, otp);
```

### Root Cause

The frontend was designed with a 4-digit OTP in mind, but the backend was implemented with a 6-digit OTP. This mismatch causes:

1. **User cannot enter the full 6-digit code** - Only 4 input boxes are available
2. **Verification always fails** - Even if user enters first 4 digits, the full 6-digit code won't match
3. **Poor user experience** - User receives 6-digit code but can only enter 4 digits

### Impact

- **Severity:** CRITICAL
- **User Impact:** Password reset feature is completely broken
- **Business Impact:** Users cannot reset their passwords, potentially losing access to their accounts

---

## Issue #2: Missing Toast on Submit Error

### Problem Description

When the user presses the submit button and something goes wrong (network error, invalid OTP, etc.), the error handling may not consistently show a toast message to the user.

### Current Implementation Analysis

**File:** [`frontend/lib/features/auth/presentaion/view/otp_page.dart`](frontend/lib/features/auth/presentaion/view/otp_page.dart:46-77)

```dart
// Lines 46-77: BlocListener handles AuthError state
BlocListener<AuthCubit, AuthState>(
  listener: (context, state) {
    if (state is AuthSuccess) {
      // Show success toast
      ToastUtility.showSuccessDismissibleToast(
        context,
        message: state.message,
      );
      // Navigate after a brief delay
      Future.delayed(const Duration(milliseconds: 3500), () {
        if (context.mounted) {
          Navigator.pushReplacementNamed(
            context,
            AppRoutes.newPassword,
            arguments: widget.email,
          );
        }
      });
    }
    if (state is AuthError) {
      // Show error toast with retry action
      ToastUtility.showErrorWithRetryToast(
        context,
        message: state.message,
        onRetry: () {
          if (_formKey.currentState!.validate()) {
            final otp = controllers.map((e) => e.text).join();
            cubit.verifyOtp(widget.email!, otp);
          }
        },
      );
    }
  },
  // ...
)
```

**File:** [`frontend/lib/features/auth/presentaion/view/reset_password.dart`](frontend/lib/features/auth/presentaion/view/reset_password.dart:24-50)

```dart
// Lines 24-50: Reset password page also handles errors
BlocConsumer<AuthCubit, AuthState>(
  listener: (context, state) {
    if (state is AuthSuccess) {
      ToastUtility.showSuccessDismissibleToast(
        context,
        message: state.message,
      );
      Future.delayed(const Duration(milliseconds: 3500), () {
        if (context.mounted) {
          Navigator.pushNamed(
            context,
            AppRoutes.otp,
            arguments: emailController.text.trim(),
          );
        }
      });
    }
    if (state is AuthError) {
      ToastUtility.showErrorDismissibleToast(
        context,
        message: state.message,
      );
    }
  },
  // ...
)
```

### Issues Identified

1. **Inconsistent Error Handling:**
   - OTP page uses `showErrorWithRetryToast` (with retry button)
   - Reset password page uses `showErrorDismissibleToast` (without retry button)
   - This inconsistency may confuse users

2. **Form Validation Errors:**
   - When form validation fails (empty fields), no toast is shown
   - Only inline validation messages appear
   - User may not notice the validation errors

3. **Network Errors:**
   - Network errors are caught in the cubit and emit `AuthError`
   - These should show toast messages, which they do
   - However, the error message may not be user-friendly

### Current Toast Implementation

**File:** [`frontend/lib/core/utils/toast_utility.dart`](frontend/lib/core/utils/toast_utility.dart:1-214)

The toast utility provides:

- `showSuccessDismissibleToast()` - Green success toast
- `showErrorDismissibleToast()` - Red error toast
- `showErrorWithRetryToast()` - Red error toast with retry button
- `showDismissibleToast()` - Generic dismissible toast

### Impact

- **Severity:** HIGH
- **User Impact:** Users may not understand why their submission failed
- **Business Impact:** Poor user experience, increased support requests

---

## Issue #3: Navigation Flow After OTP Verification

### Problem Description

After successful OTP verification, the user should be navigated to the reset password page. Let's verify this flow is working correctly.

### Current Navigation Flow

**File:** [`frontend/lib/features/auth/presentaion/view/otp_page.dart`](frontend/lib/features/auth/presentaion/view/otp_page.dart:48-63)

```dart
// Lines 48-63: Navigation after successful OTP verification
if (state is AuthSuccess) {
  // Show success toast
  ToastUtility.showSuccessDismissibleToast(
    context,
    message: state.message,
  );
  // Navigate after a brief delay
  Future.delayed(const Duration(milliseconds: 3500), () {
    if (context.mounted) {
      Navigator.pushReplacementNamed(
        context,
        AppRoutes.newPassword,
        arguments: widget.email,
      );
    }
  });
}
```

**File:** [`frontend/lib/core/routes/app_routes.dart`](frontend/lib/core/routes/app_routes.dart:38-41)

```dart
// Lines 38-41: New password route configuration
newPassword: (context) {
  final email = ModalRoute.of(context)?.settings.arguments as String? ?? '';
  return NewPasswordPage(email: email);
},
```

### Analysis

✅ **Navigation is correctly implemented:**

- After OTP verification success, user is navigated to `AppRoutes.newPassword`
- Email is passed as an argument to the new password page
- `pushReplacementNamed` is used to prevent going back to OTP page

✅ **Email is properly passed:**

- The email is received from the previous page (reset password page)
- It's passed to the new password page via route arguments
- The new password page receives it in the constructor

### Potential Issues

1. **Delay Timing:** 3500ms delay may be too long for some users
2. **No Loading Indicator:** During the delay, user doesn't see any progress
3. **Context Check:** `context.mounted` check is good practice

### Impact

- **Severity:** LOW
- **User Impact:** Minor - navigation works but could be more responsive
- **Business Impact:** Minimal

---

## Issue #4: Redirect to Login After Password Reset

### Problem Description

After successfully resetting the password, the user should be redirected to the login page.

### Current Implementation

**File:** [`frontend/lib/features/auth/presentaion/view/new_password_page.dart`](frontend/lib/features/auth/presentaion/view/new_password_page.dart:28-44)

```dart
// Lines 28-44: Navigation after successful password reset
if (state is AuthSuccess) {
  // Show success toast
  ToastUtility.showSuccessDismissibleToast(
    context,
    message: state.message,
  );

  // Navigate after delay to allow toast to show
  Future.delayed(const Duration(milliseconds: 3500), () {
    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.login,
        (route) => false,
      );
    }
  });
}
```

### Analysis

✅ **Redirect is correctly implemented:**

- After password reset success, user is navigated to `AppRoutes.login`
- `pushNamedAndRemoveUntil` is used with `(route) => false` to clear the entire navigation stack
- This prevents user from going back to reset password flow

✅ **Toast is shown:**

- Success toast is displayed before navigation
- 3500ms delay allows user to see the toast

### Potential Issues

1. **Delay Timing:** Same 3500ms delay as OTP page
2. **No Auto-Login:** User must manually log in after password reset
3. **Session Cleared:** Any existing session is not automatically cleared

### Impact

- **Severity:** LOW
- **User Impact:** Minor - user must log in again after password reset
- **Business Impact:** Minimal - this is actually a security best practice

---

## Issue #5: UI/UX Improvements

### Problem Description

The UI of the reset password and OTP code pages needs improvements in fonts, colors, and spacing.

### Current UI Analysis

#### Reset Password Page

**File:** [`frontend/lib/features/auth/presentaion/view/reset_password.dart`](frontend/lib/features/auth/presentaion/view/reset_password.dart:54-166)

**Current Styling:**

- Title: 26sp, bold, `AppColor.info` (blue)
- Subtitle: 15sp, `AppColor.textNeutral` (dark gray)
- Input field: Standard `AppTextField` widget
- Button: `AppColor.positive` (green) background, `AppColor.textNeutral` text
- Back to login: 14sp, `AppColor.warning` (yellow), medium weight

**Issues:**

1. **Title color:** Using `AppColor.info` (blue) instead of a more prominent color
2. **Subtitle spacing:** Only 16.h spacing between title and subtitle
3. **Input field spacing:** 40.h spacing before input field may be too much
4. **Button styling:** Green background with dark gray text may not have enough contrast
5. **Back to login:** Yellow color may not be accessible

#### OTP Page

**File:** [`frontend/lib/features/auth/presentaion/view/otp_page.dart`](frontend/lib/features/auth/presentaion/view/otp_page.dart:80-190)

**Current Styling:**

- Title: 26sp, bold, `AppColor.textNeutral` (dark gray)
- Subtitle: 15sp, `AppColor.textNeutral`, height 1.4
- OTP boxes: 65w width, 60x60 size, 22sp font, bold
- Button: 50.h height, 16sp font, white text, green background
- Resend OTP: 15sp, `AppColor.warning` (yellow), bold

**Issues:**

1. **OTP box size:** 65w may be too small for 6 digits
2. **OTP box styling:** No border, only background color
3. **Spacing:** 40.h before OTP boxes may be too much
4. **Resend button:** Yellow color may not be accessible
5. **No visual feedback:** When OTP is entered, no visual change

#### OTP Box Widget

**File:** [`frontend/lib/features/auth/presentaion/widgets/otp_box.dart`](frontend/lib/features/auth/presentaion/widgets/otp_box.dart:1-44)

**Current Styling:**

- Size: 60x60
- Font: 22sp, bold
- Background: `AppColor.backgroundNeutral` (light gray)
- Border: None (only rounded corners)
- Border radius: 12

**Issues:**

1. **No border:** Makes it hard to see the input field
2. **No focus state:** No visual indication when focused
3. **No filled state:** No visual indication when digit is entered
4. **Size:** May be too small for some devices

#### New Password Page

**File:** [`frontend/lib/features/auth/presentaion/view/new_password_page.dart`](frontend/lib/features/auth/presentaion/view/new_password_page.dart:55-198)

**Current Styling:**

- Title: 26sp, bold, `AppColor.info` (blue)
- Subtitle: 15sp, `AppColor.textNeutral`
- Input fields: Standard `AppTextField` widgets
- Button: `AppColor.positive` (green) background, `AppColor.textNeutral` text
- Back to login: 14sp, `AppColor.warning` (yellow), medium weight

**Issues:**

1. **Same issues as reset password page**
2. **Password requirements:** No visual indication of password requirements
3. **Password strength:** No password strength indicator

### Color Scheme Analysis

**File:** [`frontend/lib/core/color/app_color.dart`](frontend/lib/core/color/app_color.dart:1-20)

```dart
class AppColor {
  // Neutrals
  static const textNeutral = Color(0xFF4A4A4A);        // Dark gray for text
  static const backgroundNeutral = Color(0xFFF5F7FA);  // Light background
  static const cardBackground = Color(0xFFFFFFFF);     // White card background
  static const borderNeutral = Color(0xFFE0E0E0);      // Soft borders

  // Semantic Colors
  static const positive = Color(0xFF28A745);           // Green for success
  static const negative = Color(0xFFDC3545);           // Red for errors
  static const warning = Color(0xFFFFC107);            // Yellow for warnings
  static const info = Color(0xFF007BFF);               // Blue for info
  static const special = Color(0xFF6F42C1);            // Purple for special

  // Optional: subtle shades
  static const lightBlueBackground = Color(0xFFE9F2FF);
  static const lightGreenBackground = Color(0xFFE6F4EA);
}
```

**Issues:**

1. **Warning color (yellow):** Used for "Back to login" and "Resend OTP" - may not be accessible
2. **Info color (blue):** Used for titles - could be more prominent
3. **No primary color:** No dedicated primary brand color
4. **Contrast:** Some color combinations may not meet WCAG contrast requirements

### Impact

- **Severity:** MEDIUM
- **User Impact:** Poor visual design affects user experience and accessibility
- **Business Impact:** May affect user trust and app store ratings

---

## Implementation Plan

### Phase 1: Fix Critical Issues (Priority: HIGH)

#### 1.1 Fix OTP Digit Mismatch

**Frontend Changes:**

**File:** [`frontend/lib/features/auth/presentaion/view/otp_page.dart`](frontend/lib/features/auth/presentaion/view/otp_page.dart)

**Changes Required:**

1. Change `List.generate(4, ...)` to `List.generate(6, ...)` on line 31
2. Update `index < 3` to `index < 5` on line 134
3. Update OTP box width from `65.w` to `55.w` to fit 6 boxes on screen
4. Update validation logic if needed

**Estimated Time:** 30 minutes

#### 1.2 Ensure Toast on All Errors

**Frontend Changes:**

**File:** [`frontend/lib/features/auth/presentaion/view/otp_page.dart`](frontend/lib/features/auth/presentaion/view/otp_page.dart)

**Changes Required:**

1. Add form validation toast when validation fails
2. Ensure all error states show appropriate toast messages
3. Consider adding loading toast during API calls

**File:** [`frontend/lib/features/auth/presentaion/view/reset_password.dart`](frontend/lib/features/auth/presentaion/view/reset_password.dart)

**Changes Required:**

1. Add form validation toast when validation fails
2. Ensure consistent error handling across all auth pages

**Estimated Time:** 1 hour

### Phase 2: UI/UX Improvements (Priority: MEDIUM)

#### 2.1 Improve OTP Box Styling

**File:** [`frontend/lib/features/auth/presentaion/widgets/otp_box.dart`](frontend/lib/features/auth/presentaion/widgets/otp_box.dart)

**Changes Required:**

1. Add border with `AppColor.borderNeutral`
2. Add focus state with `AppColor.info` border
3. Add filled state with different background color
4. Increase size to 60x60 or add responsive sizing
5. Add subtle shadow for depth

**Estimated Time:** 45 minutes

#### 2.2 Improve Page Layouts

**File:** [`frontend/lib/features/auth/presentaion/view/otp_page.dart`](frontend/lib/features/auth/presentaion/view/otp_page.dart)

**Changes Required:**

1. Adjust spacing between elements
2. Improve title styling
3. Add better visual hierarchy
4. Improve button styling

**File:** [`frontend/lib/features/auth/presentaion/view/reset_password.dart`](frontend/lib/features/auth/presentaion/view/reset_password.dart)

**Changes Required:**

1. Adjust spacing between elements
2. Improve title styling
3. Add better visual hierarchy
4. Improve button styling

**File:** [`frontend/lib/features/auth/presentaion/view/new_password_page.dart`](frontend/lib/features/auth/presentaion/view/new_password_page.dart)

**Changes Required:**

1. Adjust spacing between elements
2. Improve title styling
3. Add password requirements display
4. Improve button styling

**Estimated Time:** 2 hours

#### 2.3 Improve Color Scheme

**File:** [`frontend/lib/core/color/app_color.dart`](frontend/lib/core/color/app_color.dart)

**Changes Required:**

1. Add primary brand color
2. Improve warning color for better accessibility
3. Add more color variations for different states
4. Ensure WCAG contrast compliance

**Estimated Time:** 30 minutes

### Phase 3: Enhanced Features (Priority: LOW)

#### 3.1 Add Password Strength Indicator

**New File:** `frontend/lib/features/auth/presentaion/widgets/password_strength_indicator.dart`

**Features:**

- Visual password strength meter
- Real-time feedback as user types
- Color-coded strength levels
- Requirements checklist

**Estimated Time:** 2 hours

#### 3.2 Add Resend OTP Timer

**File:** [`frontend/lib/features/auth/presentaion/view/otp_page.dart`](frontend/lib/features/auth/presentaion/view/otp_page.dart)

**Features:**

- Countdown timer for resend button
- Disable resend button during countdown
- Visual feedback for timer

**Estimated Time:** 1 hour

#### 3.3 Add Auto-Submit on OTP Complete

**File:** [`frontend/lib/features/auth/presentaion/view/otp_page.dart`](frontend/lib/features/auth/presentaion/view/otp_page.dart)

**Features:**

- Auto-submit when all 6 digits are entered
- Reduce friction for user
- Improve user experience

**Estimated Time:** 30 minutes

---

## Code Changes Required

### Summary of All Changes

| File                               | Change                         | Priority | Estimated Time |
| ---------------------------------- | ------------------------------ | -------- | -------------- |
| `otp_page.dart`                    | Change 4 to 6 OTP boxes        | HIGH     | 30 min         |
| `otp_page.dart`                    | Update focus logic for 6 boxes | HIGH     | 5 min          |
| `otp_page.dart`                    | Adjust OTP box width           | HIGH     | 5 min          |
| `otp_page.dart`                    | Add form validation toast      | HIGH     | 30 min         |
| `otp_page.dart`                    | Improve UI styling             | MEDIUM   | 1 hour         |
| `otp_page.dart`                    | Add resend timer               | LOW      | 1 hour         |
| `otp_page.dart`                    | Add auto-submit                | LOW      | 30 min         |
| `reset_password.dart`              | Add form validation toast      | HIGH     | 30 min         |
| `reset_password.dart`              | Improve UI styling             | MEDIUM   | 30 min         |
| `new_password_page.dart`           | Improve UI styling             | MEDIUM   | 30 min         |
| `new_password_page.dart`           | Add password requirements      | LOW      | 1 hour         |
| `otp_box.dart`                     | Improve styling                | MEDIUM   | 45 min         |
| `app_color.dart`                   | Add primary color              | MEDIUM   | 30 min         |
| `password_strength_indicator.dart` | New widget                     | LOW      | 2 hours        |

**Total Estimated Time:** ~10 hours

---

## Testing Checklist

### Functional Testing

- [ ] Backend generates 6-digit OTP
- [ ] Frontend accepts 6-digit OTP
- [ ] OTP verification works with 6-digit code
- [ ] Toast shows on form validation error
- [ ] Toast shows on API error
- [ ] Toast shows on network error
- [ ] Navigation to new password page after OTP verification
- [ ] Navigation to login page after password reset
- [ ] Email is passed correctly between pages
- [ ] Password reset updates user password in database

### UI/UX Testing

- [ ] OTP boxes are properly sized for 6 digits
- [ ] OTP boxes have visible borders
- [ ] OTP boxes show focus state
- [ ] OTP boxes show filled state
- [ ] Spacing is consistent across all pages
- [ ] Colors meet WCAG contrast requirements
- [ ] Text is readable on all devices
- [ ] Buttons are properly styled
- [ ] Loading states are visible
- [ ] Error messages are clear and helpful

### Edge Cases

- [ ] User enters less than 6 digits
- [ ] User enters more than 6 digits
- [ ] User enters non-numeric characters
- [ ] OTP expires during entry
- [ ] Network connection lost during submission
- [ ] User navigates back during process
- [ ] User closes app during process
- [ ] Multiple rapid submissions
- [ ] Invalid email format
- [ ] Password mismatch

### Accessibility Testing

- [ ] Screen reader can read all text
- [ ] Color contrast meets WCAG AA standards
- [ ] Touch targets are at least 44x44 pixels
- [ ] Focus indicators are visible
- [ ] Error messages are announced
- [ ] Loading states are announced

---

## Additional Recommendations

### 1. Error Message Improvements

**Current Error Messages:**

- "No OTP found"
- "OTP has expired"
- "Invalid OTP"
- "User with email {email} does not exist"

**Recommended Improvements:**

- Add more user-friendly messages
- Include actionable instructions
- Provide context for errors
- Add error codes for support

### 2. Security Enhancements

**Recommendations:**

- Add rate limiting for OTP requests
- Add CAPTCHA after multiple failed attempts
- Log all password reset attempts
- Send notification email after successful reset
- Add session invalidation after password change

### 3. Performance Optimizations

**Recommendations:**

- Cache OTP verification result
- Implement request debouncing
- Add offline support for OTP entry
- Optimize image loading
- Reduce API call frequency

### 4. Analytics & Monitoring

**Recommendations:**

- Track password reset success rate
- Track OTP verification success rate
- Monitor error rates by type
- Track user drop-off points
- Monitor API response times

---

## Conclusion

The reset password feature has several critical issues that need immediate attention:

1. **CRITICAL:** OTP digit mismatch (6-digit backend vs 4-digit frontend)
2. **HIGH:** Inconsistent error toast handling
3. **MEDIUM:** UI/UX improvements needed
4. **LOW:** Enhanced features for better user experience

The implementation plan provides a structured approach to fixing these issues, with clear priorities and time estimates. The testing checklist ensures all changes are properly validated before deployment.

**Recommended Action:** Start with Phase 1 (Critical Issues) immediately, then proceed to Phase 2 (UI/UX Improvements) and Phase 3 (Enhanced Features) based on available resources and timeline.

---

## Appendix

### A. File Locations

**Backend Files:**

- [`Backend/routers/otp.py`](Backend/routers/otp.py) - OTP API endpoints
- [`Backend/repositories/otpRepo.py`](Backend/repositories/otpRepo.py) - OTP repository
- [`Backend/templates/email_otp.html`](Backend/templates/email_otp.html) - Email template
- [`Backend/schemas.py`](Backend/schemas.py) - Data schemas
- [`Backend/models.py`](Backend/models.py) - Database models

**Frontend Files:**

- [`frontend/lib/features/auth/presentaion/view/otp_page.dart`](frontend/lib/features/auth/presentaion/view/otp_page.dart) - OTP page
- [`frontend/lib/features/auth/presentaion/view/reset_password.dart`](frontend/lib/features/auth/presentaion/view/reset_password.dart) - Reset password page
- [`frontend/lib/features/auth/presentaion/view/new_password_page.dart`](frontend/lib/features/auth/presentaion/view/new_password_page.dart) - New password page
- [`frontend/lib/features/auth/presentaion/widgets/otp_box.dart`](frontend/lib/features/auth/presentaion/widgets/otp_box.dart) - OTP box widget
- [`frontend/lib/features/auth/presentaion/manager/auth_cubit.dart`](frontend/lib/features/auth/presentaion/manager/auth_cubit.dart) - Auth state management
- [`frontend/lib/features/auth/presentaion/manager/auth_state.dart`](frontend/lib/features/auth/presentaion/manager/auth_state.dart) - Auth states
- [`frontend/lib/features/auth/repo/auth_repo.dart`](frontend/lib/features/auth/repo/auth_repo.dart) - Auth repository interface
- [`frontend/lib/features/auth/repo/auth_repo_impl.dart`](frontend/lib/features/auth/repo/auth_repo_impl.dart) - Auth repository implementation
- [`frontend/lib/core/api/api_service.dart`](frontend/lib/core/api/api_service.dart) - API service
- [`frontend/lib/core/utils/toast_utility.dart`](frontend/lib/core/utils/toast_utility.dart) - Toast utility
- [`frontend/lib/core/routes/app_routes.dart`](frontend/lib/core/routes/app_routes.dart) - App routes
- [`frontend/lib/core/color/app_color.dart`](frontend/lib/core/color/app_color.dart) - App colors

### B. API Endpoints

**OTP Endpoints:**

- `POST /otp/forgot-password` - Send OTP to email
- `POST /otp/verify-otp` - Verify OTP
- `POST /otp/reset-password` - Reset password

### C. Color Palette

**Current Colors:**

- `textNeutral`: #4A4A4A (Dark gray)
- `backgroundNeutral`: #F5F7FA (Light gray)
- `cardBackground`: #FFFFFF (White)
- `borderNeutral`: #E0E0E0 (Soft gray)
- `positive`: #28A745 (Green)
- `negative`: #DC3545 (Red)
- `warning`: #FFC107 (Yellow)
- `info`: #007BFF (Blue)
- `special`: #6F42C1 (Purple)

---

**Report Generated:** 2026-04-01
**Investigator:** Senior Flutter & Dart Engineer
**Status:** Investigation Complete - Ready for Implementation
