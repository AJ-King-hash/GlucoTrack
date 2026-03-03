from fastapi import APIRouter,Depends
import schemas
from sqlalchemy.orm import Session
from database import get_db
from repositories import userRepo
from typing import List
from datetime import datetime,timedelta
import pytz

def update_fcm_token( user_id: int, fcm_token: str,db: Session = Depends(get_db)):
    user = userRepo.show(db, user_id)
    if user:
        user.fcm_token = fcm_token
        db.commit()
        db.refresh(user)
    return user
def update_reminders( user_id: int, gluco_time: str = None, medicine_time: str = None, timezone: str = "UTC",db:Session=Depends(get_db)):
    user = userRepo.show(db, user_id)
    if not user:
        return None
    
    user.timezone = timezone
    
    if gluco_time:
        user.gluco_reminder = calculate_next_utc_time(gluco_time, timezone)
    
    if medicine_time:
        user.medicine_reminder = calculate_next_utc_time(medicine_time, timezone)
    
    db.commit()
    db.refresh(user)
    return user

def calculate_next_utc_time(local_time_str: str, timezone_str: str) -> datetime:
    local_tz = pytz.timezone(timezone_str)
    local_time = datetime.strptime(local_time_str, "%H:%M").time()
    now_local = datetime.now(local_tz)
    local_dt = now_local.replace(hour=local_time.hour, minute=local_time.minute, second=0, microsecond=0)
    if local_dt < now_local:
        local_dt += timedelta(days=1)
    return local_dt.astimezone(pytz.UTC)