from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from database import SessionLocal, get_db
from repositories import NotificationRepo
from datetime import datetime, timedelta, timezone
from apscheduler.schedulers.asyncio import AsyncIOScheduler
from apscheduler.triggers.interval import IntervalTrigger
import firebase_admin
import models
import json
import os
import logging
from firebase_admin import credentials, messaging
from schemas import FCMTokenUpdate, UserReminderUpdate
import schemas
import oauth2
from contextlib import asynccontextmanager

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

router = APIRouter(
    prefix="/notification",
    tags=["Notifications"]
)

# Firebase initialization flag
_firebase_initialized = False

# Initialize Firebase
try:
    cred = credentials.Certificate("firebase-service-account.json")
    firebase_admin.initialize_app(cred)
    _firebase_initialized = True
    logger.info("Firebase initialized successfully")
except FileNotFoundError:
    logger.warning("Firebase service account file not found. Notifications will not work.")
except Exception as e:
    logger.error(f"Firebase initialization failed: {e}")

scheduler = AsyncIOScheduler()

# Get scheduler interval from environment (default: 5 minutes)
SCHEDULER_INTERVAL_MINUTES = int(os.getenv("NOTIFICATION_INTERVAL_MINUTES", "5"))


async def send_reminders():
    """Send reminders to all users whose reminder time has passed."""
    # Skip if Firebase is not initialized
    if not _firebase_initialized:
        logger.warning("Skipping reminders: Firebase not initialized")
        return
    
    now = datetime.now(timezone.utc)
    db = SessionLocal()
    
    try:
        # Medicine reminders
        medicine_users = db.query(models.User).filter(
            models.User.medicine_reminder <= now,
            models.User.medicine_reminder.isnot(None),
            models.User.fcm_token.isnot(None)
        ).all()
        
        for user in medicine_users:
            try:
                message = messaging.Message(
                    notification=messaging.Notification(
                        title="Medicine Reminder",
                        body="It's time to take your medicine!"
                    ),
                    token=user.fcm_token
                )
                messaging.send(message)
                
                # Update reminder time for next day
                if user.medicine_reminder:
                    user.medicine_reminder = user.medicine_reminder + timedelta(days=1)
                    # Ensure timezone awareness
                    if user.medicine_reminder.tzinfo is None:
                        user.medicine_reminder = user.medicine_reminder.replace(tzinfo=timezone.utc)
            except Exception as e:
                print(f"Error sending medicine reminder to user {user.id}: {e}")
        
        # Glucose reminders
        gluco_users = db.query(models.User).filter(
            models.User.gluco_reminder <= now,
            models.User.gluco_reminder.isnot(None),
            models.User.fcm_token.isnot(None)
        ).all()
        
        for user in gluco_users:
            try:
                message = messaging.Message(
                    notification=messaging.Notification(
                        title="Blood Glucose Reminder",
                        body="Time to check your blood sugar!"
                    ),
                    token=user.fcm_token
                )
                messaging.send(message)
                
                # Update reminder time for next day
                if user.gluco_reminder:
                    user.gluco_reminder = user.gluco_reminder + timedelta(days=1)
                    # Ensure timezone awareness
                    if user.gluco_reminder.tzinfo is None:
                        user.gluco_reminder = user.gluco_reminder.replace(tzinfo=timezone.utc)
            except Exception as e:
                print(f"Error sending glucose reminder to user {user.id}: {e}")
        
        db.commit()
    except Exception as e:
        print(f"Error in send_reminders: {e}")
        db.rollback()
    finally:
        db.close()


@router.get("/trigger-reminders") 
async def trigger_reminders(
    current_user: schemas.User = Depends(oauth2.get_current_user)
): 
    """Manually trigger reminder check (for testing). Requires authentication."""
    await send_reminders()
    return {"status": "success", "message": "Reminders triggered"}


@router.put("/reminders")
def set_reminders(
    reminder: UserReminderUpdate, 
    db: Session = Depends(get_db),
    current_user: schemas.User = Depends(oauth2.get_current_user)
):
    """Update user's reminder times."""
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
        "message": "Reminders updated",
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
    """Update user's FCM token for push notifications."""
    updated_user = NotificationRepo.update_fcm_token(
        db, 
        current_user.id, 
        token.fcm_token
    )
    
    if not updated_user:
        raise HTTPException(status_code=404, detail="User not found")
    
    return {"status": "success", "message": "FCM token updated"}


@router.get("/health")
async def health_check():
    """Health check endpoint. Returns basic status without exposing sensitive info."""
    return {
        "status": "healthy",
        "service": "notification",
        "firebase_initialized": _firebase_initialized
    }


# Lifespan context manager for startup/shutdown events
@asynccontextmanager
async def lifespan(app):
    # Startup
    scheduler.add_job(
        send_reminders, 
        IntervalTrigger(minutes=SCHEDULER_INTERVAL_MINUTES),
        id="send_reminders",
        replace_existing=True
    )
    scheduler.start()
    logger.info(f"Notification scheduler started (interval: {SCHEDULER_INTERVAL_MINUTES} minutes)")
    
    yield
    
    # Shutdown
    scheduler.shutdown()
    logger.info("Notification scheduler stopped")
