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

def update(id:int,request,db:Session):
    user=db.query(models.User).filter(models.User.id==id).first()
    if not user:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND,detail=f"User with the id {id} is not available")
    user.name=request.name
    user.email=request.email
    user.updated_at=datetime.now(timezone.utc)
    user.password=Hash.bcrypt(request.password)
    db.commit()
    db.refresh(user)
    return user
def delete(id:int,db:Session):
    user=db.query(models.User).filter(models.User.id==id).first()
    if not user:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND,detail=f"User with the id {id} is not available")
    db.delete(user)
    db.commit() 

