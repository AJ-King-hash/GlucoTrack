from StartingPackages import *
from fastapi import APIRouter
from JwtToken import timedelta,ACCESS_TOKEN_EXPIRE_MINUTES,create_access_token,DeleteToken
from fastapi.security import OAuth2PasswordRequestForm
from fastapi import HTTPException, status,exceptions
from repositories.authRepo import *

import oauth2

router=APIRouter(
    prefix="/auth",
    tags=["Authentication"]
)

@router.post("/login",response_model=schemas.ShowUserWithMessageToken)
def login(request:OAuth2PasswordRequestForm=Depends(),db:Session=Depends(get_db)):
    # 1-check the user
    user=db.query(models.User).filter(models.User.email==request.username).first()
    if not user:
          raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Invalid Credentials")
    if not Hash.verify(request.password,user.password):
          raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Invalid Credentials")

    #2- Generate JWT token and return it     
    access_token_expires = timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = create_access_token(
        data={"sub": user.email,"id":user.id}, expires_delta=access_token_expires
    )
    # return user
    return {"message":"User Login Successfully!","user":user,"token":schemas.Token(access_token=access_token, token_type="bearer")}

@router.delete("/logout",response_model=schemas.ShowMessage)
def logout(current_token:schemas.User=Depends(oauth2.get_current_token)):
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Not Authorized",
        headers={"WWW-Authenticate": "Bearer"},
    )
    DeleteToken(current_token,credentials_exception) 
    return {"message":"User Logout Successfully!"}
      


