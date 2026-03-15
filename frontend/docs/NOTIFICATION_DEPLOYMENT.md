# Reminder Notification Feature - Deployment Guide

## Overview

This document outlines the deployment steps for the reminder notification feature in GlucoTrack.

## Architecture

### Backend (Python/FastAPI)

- **Polling Mechanism**: APScheduler runs every 60 seconds to check for due reminders
- **Database**: User table stores `medicine_reminder` and `gluco_reminder` as DateTime columns
- **Firebase**: FCM (Firebase Cloud Messaging) for push notifications
- **Timezone**: Users can set their timezone; times are converted to UTC for storage

### Frontend (Flutter)

- **Firebase**: Firebase Core, Firebase Messaging, Local Notifications
- **UI**: Time pickers for setting medicine and glucose reminder times
- **State Management**: Cubit pattern with BLoC

## Prerequisites

1. **Firebase Project**:
   - Create a Firebase project at https://console.firebase.google.com
   - Enable Cloud Messaging
   - Download `google-services.json` (Android) and place in `android/app/`
   - Download `GoogleService-Info.plist` (iOS) and place in `ios/Runner/`

2. **Backend Dependencies**:

   ```bash
   pip install fastapi uvicorn sqlalchemy pytz apscheduler firebase-admin
   ```

3. **Frontend Dependencies**:
   ```bash
   cd frontend
   flutter pub get
   ```

## Backend Deployment

### Option 1: Local Development

```bash
cd Backend
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

### Option 2: Production with Supervisor

1. Install supervisor:

   ```bash
   sudo apt-get install supervisor
   ```

2. Create supervisor config `/etc/supervisor/conf.d/glucotrack.conf`:

   ```ini
   [program:glucotrack]
   command=/usr/bin/python3 -m uvicorn main:app --host 0.0.0.0 --port 8000
   directory=/path/to/Backend
   user=www-data
   autostart=true
   autorestart=true
   redirect_stderr=true
   stdout_logfile=/var/log/glucotrack.log
   environment=PYTHONPATH="/path/to/Backend"
   ```

3. Start the service:
   ```bash
   sudo supervisorctl reread
   sudo supervisorctl start glucotrack
   ```

### Option 3: Cloud Deployment (Render/Railway/Vercel)

For cloud deployment, ensure:

- Set environment variables for database URL
- Use persistent disk for SQLite if applicable
- Enable WebSocket support if using async scheduler

## Frontend Deployment

### Android

1. Configure Firebase:
   - Add `google-services.json` to `android/app/`
   - Update `android/build.gradle` with Google services plugin

2. Build:
   ```bash
   cd frontend
   flutter build apk --release
   ```

### iOS

1. Configure Firebase:
   - Add `GoogleService-Info.plist` to `ios/Runner/`
   - Update `ios/Podfile` if needed

2. Build:
   ```bash
   cd frontend
   flutter build ios --release
   ```

## API Endpoints

| Method | Endpoint                          | Description              |
| ------ | --------------------------------- | ------------------------ |
| PUT    | `/notification/reminders`         | Update reminder times    |
| POST   | `/notification/fcm-token`         | Update FCM token         |
| GET    | `/notification/trigger-reminders` | Manual trigger (testing) |
| GET    | `/notification/health`            | Health check             |

## Testing

### Backend Testing

```bash
# Test health endpoint
curl http://localhost:8000/notification/health

# Test trigger reminders
curl http://localhost:8000/notification/trigger-reminders
```

### Frontend Testing

1. Run the app
2. Navigate to Reminder Settings
3. Set a medicine time and glucose time
4. Use "Test Notifications" button

## Troubleshooting

### Backend Issues

1. **Scheduler not running**: Check logs at `/var/log/glucotrack.log`
2. **Firebase errors**: Verify service account JSON is valid
3. **Database errors**: Check database file permissions

### Frontend Issues

1. **Notifications not showing**:
   - Check AndroidManifest permissions
   - Verify google-services.json is configured correctly
2. **Token registration fails**:
   - Check network connectivity
   - Verify API endpoint is correct

## Security Considerations

1. **FCM Token**: Store securely, rotate periodically
2. **API Authentication**: All endpoints require JWT authentication
3. **Rate Limiting**: Implement rate limiting for reminder updates

## Monitoring

- Use APM tools (New Relic, DataDog) for performance monitoring
- Set up alerts for failed notification deliveries
- Monitor Firebase console for delivery statistics
