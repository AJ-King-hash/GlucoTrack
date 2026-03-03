from fastapi import APIRouter
from StartingPackages import *
from repositories import userRepo
from JwtToken import timedelta,ACCESS_TOKEN_EXPIRE_MINUTES,create_access_token
import oauth2
router=APIRouter(
prefix="/user",
tags=["Users"],

)


@router.post("/", status_code=status.HTTP_201_CREATED, response_model=schemas.ShowUserWithMessageToken)
def create_user(request: schemas.User, db: Session = Depends(get_db)):
    user=userRepo.create(request,db)
    access_token_expires = timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = create_access_token(
        data={"sub": user.email}, expires_delta=access_token_expires
    )
    return {"message": "User Created successfully ", "user": user,"token":schemas.Token(access_token=access_token,token_type="bearer")}   

@router.get("/{id}",response_model=schemas.ShowUserWithMessage)
def get_user(id:int,db:Session=Depends(get_db)):
    return {"message": "User has successfully Found!", "user": userRepo.show(id,db)}

@router.put("/",response_model=schemas.ShowUserWithMessage)
def update_user(request:schemas.User,db:Session=Depends(get_db),current_user:schemas.User=Depends(oauth2.get_current_user)):
    return {"message": "User updated successfully", "user": userRepo.update(current_user.id,request,db)}


@router.delete("/")
def delete_user(db:Session=Depends(get_db),current_user:schemas.User=Depends(oauth2.get_current_user)):
    userRepo.delete(current_user.id,db)
    return {"message": f"User {id} deleted successfully!"}

