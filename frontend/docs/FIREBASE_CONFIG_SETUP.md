# Firebase Configuration Setup Guide

**Date:** 2026-03-23  
**Project:** GlucoTrack Flutter Frontend

---

## Overview

The notification feature requires Firebase configuration files for both Android and iOS platforms. These files contain sensitive credentials and must be obtained from the Firebase Console.

## Required Files

| Platform | File                       | Location                              |
| -------- | -------------------------- | ------------------------------------- |
| Android  | `google-services.json`     | `android/app/google-services.json`    |
| iOS      | `GoogleService-Info.plist` | `ios/Runner/GoogleService-Info.plist` |

---

## How to Obtain Firebase Configuration Files

### Step 1: Access Firebase Console

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your GlucoTrack project (or create a new one if not exists)

### Step 2: Add Android App

1. In Firebase Console, click **Add app** (gear icon) → **Add Android app**
2. Enter the following details:
   - **Android package name:** `com.example.glucotrack` (or your actual package)
   - **App nickname:** GlucoTrack (optional)
3. Click **Register app**
4. Download `google-services.json`
5. Place it in: `android/app/google-services.json`

### Step 3: Add iOS App

1. In Firebase Console, click **Add app** → **Add iOS app**
2. Enter the following details:
   - **iOS bundle ID:** `com.example.glucotrack` (or your actual bundle ID)
   - **App nickname:** GlucoTrack (optional)
3. Click **Register app**
4. Download `GoogleService-Info.plist`
5. Place it in: `ios/Runner/GoogleService-Info.plist`

---

## Alternative: Using Existing Firebase Project

If you already have a Firebase project for GlucoTrack:

1. Go to **Project Settings** (gear icon)
2. Navigate to **Your apps** section
3. For Android: Click Android icon → Download `google-services.json`
4. For iOS: Click iOS icon → Download `GoogleService-Info.plist`

---

## Verification

After adding the files, verify they are correctly placed:

```
frontend/
├── android/
│   └── app/
│       └── google-services.json  ← Should exist
└── ios/
    └── Runner/
        └── GoogleService-Info.plist  ← Should exist
```

---

## Next Steps

After obtaining the configuration files:

1. Run `flutter pub get` to ensure dependencies are updated
2. Rebuild the app: `flutter build apk` (Android) or `flutter build ios` (iOS)
3. Test notification functionality

---

## Troubleshooting

### Firebase initialization fails

- Verify `google-services.json` is in the correct location (`android/app/`)
- Ensure the package name in the JSON matches your app's package name
- Check that the JSON file is valid (not corrupted)

### iOS notifications not working

- Verify `GoogleService-Info.plist` is in `ios/Runner/`
- Ensure iOS simulator or device supports push notifications
- Check that APNs authentication key is configured in Firebase Console

---

## Security Note

⚠️ **Do NOT commit these files to version control!**

Add these to your `.gitignore`:

```gitignore
# Firebase config files
android/app/google-services.json
ios/Runner/GoogleService-Info.plist
```
