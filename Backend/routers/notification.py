from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from database import SessionLocal, get_db
from repositories import NotificationRepo
from datetime import datetime, timedelta, timezone
from apscheduler.schedulers.asyncio import AsyncIOScheduler
from apscheduler.triggers.interval import IntervalTrigger
import firebase_admin
import models
import os
import logging
from firebase_admin import credentials, messaging
from schemas import FCMTokenUpdate, UserReminderUpdate
import schemas
import oauth2

# ====================== LOGGING CONFIG ======================
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s | %(levelname)s | %(name)s | %(message)s"
)
logger = logging.getLogger(__name__)

# ====================== ROUTER ======================
router = APIRouter(
    prefix="/notification",
    tags=["Notifications"]
)

# ====================== FIREBASE INITIALIZATION ======================
_firebase_initialized = False

try:
    cred = credentials.Certificate("firebase-service-account.json")
    firebase_admin.initialize_app(cred)
    _firebase_initialized = True
    logger.info("Firebase Admin SDK initialized successfully")
except FileNotFoundError:
    logger.error("firebase-service-account.json file NOT FOUND. Notifications will NOT work!")
except Exception as e:
    logger.error(f"Firebase initialization failed: {e}")

# ====================== SCHEDULER ======================
scheduler = AsyncIOScheduler()
SCHEDULER_INTERVAL_MINUTES = int(os.getenv("NOTIFICATION_INTERVAL_MINUTES", "1"))  # Default 5 minutes (safer)


async def send_reminders():
    """Send medicine and glucose reminders to users whose time has come."""
    if not _firebase_initialized:
        logger.warning("Skipping reminders: Firebase is not initialized")
        return

    # now = datetime.now(timezone.utc)
    now = datetime.now()
    db = SessionLocal()
    # print("compare offf:",now)
    # 2026-03-26 14:00:00.000000
    try:
        logger.info(f"Starting reminder check at {now}")

        # ==================== MEDICINE REMINDERS ====================
        medicine_users = db.query(models.User).filter(
            models.User.medicine_reminder <= now,
            models.User.medicine_reminder.isnot(None),
            models.User.fcm_token.isnot(None)
        ).all()

        logger.info(f"Found {len(medicine_users)} users eligible for medicine reminder")

        for user in medicine_users:
            try:
                message = messaging.Message(
                    notification=messaging.Notification(
                        title="Medicine Reminder",
                        body="It's time to take your medicine!"
                    ),
                    token=user.fcm_token
                )
                response = messaging.send(message)
                logger.info(f"✓ Medicine reminder sent to user {user.id} | FCM Response: {response}")

                # Schedule for next day
                if user.medicine_reminder:
                    user.medicine_reminder += timedelta(days=1)
                    if user.medicine_reminder.tzinfo is None:
                        user.medicine_reminder = user.medicine_reminder.replace(tzinfo=timezone.utc)

            except Exception as e:
                logger.error(f"Failed to send medicine reminder to user {user.id}: {e}", exc_info=True)

        # ==================== GLUCOSE REMINDERS ====================
        gluco_users = db.query(models.User).filter(
            models.User.gluco_reminder <= now,
            models.User.gluco_reminder.isnot(None),
            models.User.fcm_token.isnot(None)
        ).all()

        logger.info(f"Found {len(gluco_users)} users eligible for glucose reminder")

        for user in gluco_users:
            try:
                message = messaging.Message(
                    notification=messaging.Notification(
                        title="Blood Glucose Reminder",
                        body="Time to check your blood sugar!"
                    ),
                    token=user.fcm_token
                )
                response = messaging.send(message)
                logger.info(f"✓ Glucose reminder sent to user {user.id} | FCM Response: {response}")

                # Schedule for next day
                if user.gluco_reminder:
                    user.gluco_reminder += timedelta(days=1)
                    if user.gluco_reminder.tzinfo is None:
                        user.gluco_reminder = user.gluco_reminder.replace(tzinfo=timezone.utc)

            except Exception as e:
                logger.error(f"Failed to send glucose reminder to user {user.id}: {e}", exc_info=True)

        db.commit()
        logger.info("Reminder check completed successfully")

    except Exception as e:
        logger.error(f"Critical error in send_reminders: {e}", exc_info=True)
        db.rollback()
    finally:
        db.close()


# ====================== ENDPOINTS ======================

@router.get("/trigger-reminders")
async def trigger_reminders(
    current_user: schemas.User = Depends(oauth2.get_current_user)
):
    """Manually trigger reminder check (useful for testing)"""
    await send_reminders()
    return {"status": "success", "message": "Reminders triggered manually"}


@router.put("/reminders")
def set_reminders(
    reminder: UserReminderUpdate,
    db: Session = Depends(get_db),
    current_user: schemas.User = Depends(oauth2.get_current_user)
):
    """Update user's reminder times"""
    updated_user = NotificationRepo.update_reminders(
        db,
        current_user.id,
        reminder.gluco_time,
        reminder.medicine_time,
        reminder.timezone
    )

    if not updated_user:
        raise HTTPException(status_code=404, detail="User not found")

    return {
        "status": "success",
        "message": "Reminders updated successfully",
        "gluco_time": reminder.gluco_time,
        "medicine_time": reminder.medicine_time,
        "timezone": reminder.timezone
    }


@router.post("/fcm-token")
def set_fcm_token(
    token: FCMTokenUpdate,
    db: Session = Depends(get_db),
    current_user: schemas.User = Depends(oauth2.get_current_user)
):
    """Update user's FCM token"""
    updated_user = NotificationRepo.update_fcm_token(
        current_user.id,
        token.fcm_token,
        db
    )

    if not updated_user:
        raise HTTPException(status_code=404, detail="User not found")

    return {"status": "success", "message": "FCM token updated successfully"}


@router.get("/health")
async def health_check():
    return {
        "status": "healthy",
        "service": "notification",
        "firebase_initialized": _firebase_initialized,
        "scheduler_interval_minutes": SCHEDULER_INTERVAL_MINUTES
    }


# ====================== STARTUP / SHUTDOWN (Add this in your main.py) ======================