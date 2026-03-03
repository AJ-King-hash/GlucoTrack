from repositories.otpRepo import *
from fastapi import APIRouter,BackgroundTasks
from fastapi import FastAPI, Depends, status, Response, HTTPException
from datetime import datetime, timedelta,timezone
from schemas import VerifySchema,EmailSchema,ResetPasswordRequest
import models
from hashing import Hash
from sqlalchemy.orm import Session

# from typing  import List
# from pydantic import BaseModel
# from sqlalchemy.orm import Session,joinedload
# from hashing import Hash
from database import get_db
# from repositories import otpRepo
# import oauth2
# import schemas, models

router=APIRouter(
    prefix="/otp",
    tags=["Otps"]
)

# we can add: tags=["connectionChecks"]
@router.get("/check",)
def index():
    return {"message": "hello"}


# class OtpCreate(schemas.Otp):
#     user_id: int  # ← add this



# @router.post("/", response_model=schemas.ShowOtp, status_code=status.HTTP_201_CREATED)
# def create(request: OtpCreate, db: Session = Depends(get_db)):
#     return otpRepo.create(request,db)

# should authorized if you want to use this route:
# @router.get("/all",response_model=List[schemas.ShowOtp])
# def all(db:Session=Depends(get_db),current_user:schemas.User=Depends(oauth2.get_current_user)):
#    return otpRepo.get_all(db)


# @router.get("/{otp_id}", response_model=schemas.ShowOtp)
# def show(otp_id: int, db: Session = Depends(get_db)):
#     return otpRepo.show(otp_id,db)





@router.post("/forgot-password")
async def forgot_password(request:EmailSchema,db:Session=Depends(get_db),background_tasks:BackgroundTasks=None):
    """Step 1: User requests OTP to be sent to their email"""
    email = request.email
    # Check for existing user
    existing_user = db.query(models.User).filter(models.User.email == request.email).first()
    if not existing_user:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"User with email {request.email} doest not exists"
        )

    # Generate secure 6-digit OTP
    otp = secrets.randbelow(900000) + 100000  # 6 digits
    otp_str = str(otp)

    # Set expiration: 10 minutes from now
    expires = datetime.now(timezone.utc) + timedelta(minutes=10)

    # # Store in memory
    # otp_store[email] = {"otp": otp_str, "expires": expires}

    # Send email
    background_tasks.add_task(send_otp_email, email=request.email, otp=otp_str,db=db)  # ← No need for background_tasks param anymore
    return {"message": "OTP sent to your email"}


@router.post("/verify-otp")
def verify_otp(request: VerifySchema,db:Session=Depends(get_db)):
    """Step 2: User submits OTP to verify"""
    email = request.email
    otp = request.otp
    # Find the latest OTP for this email
    check_otp = (
        db.query(models.Otp)
        .filter(models.Otp.email == email)
        .first()                          # ← THIS IS MISSING! Add .first()
    )

    if not check_otp:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="No OTP found")

    # Now check_otp is an actual Otp instance → has .expires
    # Option 2: Make both naive for comparison
    if datetime.now(timezone.utc).replace(tzinfo=None) > check_otp.expires.replace(tzinfo=None):
        db.delete(check_otp)
        db.commit()
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="OTP has expired")

    # Check OTP match
    if check_otp.otp != otp:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Invalid OTP")
    # OTP is correct - we can delete it now
    db.delete(check_otp)
    db.commit()
    return {"message": "OTP verified successfully"}

# In real app, you would:
    # 1. Check that OTP was verified recently (e.g. via session/token)
    # 2. Update user password in database

    # For simplicity, we just simulate success here
    # In production: hash the new password and save to DB
@router.post("/reset-password")
def reset_password(request: ResetPasswordRequest,db:Session=Depends(get_db)):
    """Step 3: After OTP verification, allow password reset"""
    user=db.query(models.User).filter(models.User.email==request.email).first()
    if not user:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"User with email {request.email} doest not exists"
        )
    hashed_password = Hash.bcrypt(request.new_password)

    user.password=hashed_password
    db.commit()
    db.refresh(user)    
    return {
        "message": "Password reset successful",
    }
    