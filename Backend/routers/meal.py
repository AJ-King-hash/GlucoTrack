from fastapi import APIRouter,Depends
import schemas
from sqlalchemy.orm import Session
from database import get_db
from repositories import mealRepo
from typing import List
import oauth2
router=APIRouter(
    prefix="/meal",
    tags=["Meals"]
)

@router.post("/")
def create_meal(request:schemas.MealBase,db:Session=Depends(get_db),current_user:schemas.User=Depends(oauth2.get_current_user)):
    return mealRepo.create(request,db)
@router.get("/{id}",response_model=schemas.MealBase)
def show_meal(id:int,db:Session=Depends(get_db),current_user:schemas.User=Depends(oauth2.get_current_user)):
    return mealRepo.show(id,db)

@router.get("/all/",response_model=List[schemas.MealAll])
def all_meals(db:Session=Depends(get_db),current_user:schemas.User=Depends(oauth2.get_current_user)):
    return mealRepo.get_all(current_user.id,db)

# @router.delete("/{id}")
# def delete_meal(id:int):
#     return mealRepo.delete(id)

