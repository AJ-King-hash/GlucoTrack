from sqlalchemy.orm import Session
from fastapi import HTTPException,status
import models
import secrets
from datetime import datetime, timezone, timedelta
from typing import Dict

from fastapi import BackgroundTasks
from fastapi_mail import FastMail, MessageSchema, ConnectionConfig, MessageType
from jinja2 import Environment, FileSystemLoader, select_autoescape

# ======================
# CONFIG
# ======================
ACCESS_TOKEN_EXPIRE_MINUTES = 10

conf = ConnectionConfig(
    MAIL_USERNAME="HealthApp",
    MAIL_PASSWORD="123",
    MAIL_FROM="healthApp@gmail.com",
    MAIL_FROM_NAME="OTP Service",
    MAIL_PORT=1025,
    MAIL_SERVER="localhost",
    MAIL_STARTTLS=False,
    MAIL_SSL_TLS=False,
    USE_CREDENTIALS=False,
    VALIDATE_CERTS=False,
)

def get_all(db:Session):
    otps=db.query(models.Otp).all()
    return otps

def create(request,db):
    new_otp = models.Otp(
        name=request.name,
        user_id=request.user_id   # ← now comes from request
    )
    db.add(new_otp)
    db.commit()
    # Optional: load creator for response
    db.refresh(new_otp, attribute_names=["creator"])
    return new_otp


def show(otp_id:int,db:Session):
    otp = (
        db.query(models.Otp)
        .filter(models.Otp.id == otp_id).
        # .options(joinedload(models.Otp.creator))
        first()
    )
    if otp is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="OTP not found")
    return otp


# In-memory OTP storage
# otp_store: Dict[str, Dict[str, str | datetime]] = {}

# Set up Jinja2 environment
env = Environment(
    loader=FileSystemLoader("templates"),           # ← folder where your templates are
    autoescape=select_autoescape(['html', 'xml'])
)


async def send_otp_email(email: str, otp: str,db:Session):
    # Calculate expiry
    expiry_minutes = ACCESS_TOKEN_EXPIRE_MINUTES
    expiry_time = datetime.now(timezone.utc) + timedelta(minutes=expiry_minutes)

    # Store OTP
    # otp_store[email] = {"otp": otp, "expiry": expiry_time}
    new_otp=models.Otp(email=email,otp=otp,expires=expiry_time)
    db.add(new_otp)
    db.commit()
    db.refresh(new_otp)
    # Render Jinja2 template
    template = env.get_template("email_otp.html")
    html_content = template.render(
        otp=otp,
        expiry_minutes=expiry_minutes,
        app_name="HealthApp" 
    )

    # Create message
    message = MessageSchema(
        subject="Your OTP Code - HealthApp",
        recipients=[email],
        body=html_content,
        subtype=MessageType.html
    )

    fm = FastMail(conf)

    await fm.send_message(message)