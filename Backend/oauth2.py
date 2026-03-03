from fastapi import Depends,HTTPException,status
from fastapi.security import OAuth2PasswordBearer
from JwtToken import *
oauth2_scheme=OAuth2PasswordBearer(tokenUrl="/auth/login")


def get_current_user(token:str=Depends(oauth2_scheme)):
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Not Authorized",
        headers={"WWW-Authenticate": "Bearer"},
    )
   
    return verifyToken(token,credentials_exception)
    
def get_current_token(token:str=Depends(oauth2_scheme)):
    
    return token
    