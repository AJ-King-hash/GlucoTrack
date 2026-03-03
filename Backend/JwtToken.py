from datetime import datetime, timedelta, timezone
from jose import jwt,JWTError
from repositories import userRepo
from fastapi import HTTPException
import schemas
SECRET_KEY = "09d25e094faa6ca2556c818166b7a9563b93f7099f6f0f4caa6cf63b88e8d3e7"
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 30
token_blacklist = set()

def create_access_token(data: dict, expires_delta: timedelta | None = None):
    to_encode = data.copy()
    if expires_delta:
        expire = datetime.now(timezone.utc) + expires_delta
    else:
        expire = datetime.now(timezone.utc) + timedelta(minutes=15)
    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
    return encoded_jwt
def verifyToken(token:str,credentials_exception):
    if token in token_blacklist:
        raise HTTPException(status_code=401, detail="Token Invalidated")
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        email = payload.get("sub")
        id = payload.get("id")
        if email is None:
            raise credentials_exception
        token_data = schemas.TokenData(email=email,id=id)
        return token_data
    except JWTError:
        raise credentials_exception
    
def DeleteToken(token:str,credentials_exception):
    try:
        if token in token_blacklist:
            raise credentials_exception
        token_blacklist.add(token)
    except JWTError:
        raise credentials_exception