from sqlalchemy.orm import Session
from fastapi import HTTPException,status
import models
from hashing import Hash
from datetime import datetime,timezone
def create(request,db:Session):
    # Check password length (in bytes)
    if len(request.password.encode('utf-8')) > 72:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Password too long. Maximum length is 72 characters (or fewer for non-ASCII characters)."
        )

    # Check for existing user
    existing_user = db.query(models.User).filter(models.User.email == request.email).first()
    if existing_user:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"User with email {request.email} already exists"
        )

    hashed_password = Hash.bcrypt(request.password)

    new_user = models.User(
        name=request.name,
        email=request.email,
        password=hashed_password
    )
    db.add(new_user)
    db.commit()
    db.refresh(new_user)
    return new_user

def show(id:int,db:Session):
    user=db.query(models.User).filter(models.User.id==id).first()
    if not user:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND,detail=f"User with the id {id} is not available")
    return user

def update(id,request,db:Session):
    user=db.query(models.User).filter(models.User.id==id).first() 
    if not user:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND,detail=f"User with the id {id} is not available")
    
    # If old_password is provided, verify it before allowing password change
    if request.old_password:
        if not Hash.verify(request.old_password, user.password):
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Incorrect old password"
            )
        
    print(request)
    
    if request.gender:
        user.gender=request.gender
    if request.name:
        user.name=request.name
    if request.email:
        user.email=request.email
    user.updated_at=datetime.now(timezone.utc)
    
    # Update password only if provided
    if request.password:
        user.password=Hash.bcrypt(request.password)
    
    # Update reminder times if provided
    if request.gluco_time is False and hasattr(request, 'gluco_time'):
        user.gluco_reminder = None
        # print(parse_time_to_datetime(request.gluco_time))
    elif request.gluco_time:
        # Allow clearing the reminder
        user.gluco_reminder = parse_time_to_datetime(request.gluco_time)
    
    if request.medicine_time is False and hasattr(request, 'medicine_time'):
        user.medicine_reminder = None
    elif request.medicine_time:
        user.medicine_reminder = parse_time_to_datetime(request.medicine_time)
    
    # Update FCM token if provided
    if request.fcm_token:
        user.fcm_token = request.fcm_token
    
    db.commit()
    db.refresh(user)
    return user

def parse_time_to_datetime(time_str: str) -> datetime:
    """Convert HH:MM time string to datetime for today (or next occurrence)"""
    from datetime import datetime, timedelta
    now = datetime.now()
    hour, minute = map(int, time_str.split(':'))
    scheduled_time = now.replace(hour=hour, minute=minute, second=0, microsecond=0)
    # If the time has passed today, schedule for tomorrow
    if scheduled_time < now:
        scheduled_time += timedelta(days=1)
    return scheduled_time

def delete(id:int,db:Session):
    user=db.query(models.User).filter(models.User.id==id).first()
    if not user:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND,detail=f"User with the id {id} is not available")
    db.delete(user)
    db.commit() 

