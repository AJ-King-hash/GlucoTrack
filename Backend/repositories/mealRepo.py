from sqlalchemy.orm import Session
from fastapi import HTTPException,status
import models
from hashing import Hash
from datetime import datetime,timezone
from GlucoBot import GlucoBot
import pandas as pd
gluco_bot=GlucoBot()

def get_all(user_id:int,db:Session):
    meals=db.query(models.Meal).where(models.Meal.user_id==user_id).all()
    return meals


def get_all(user_id:int,db:Session):
    meals=db.query(models.Meal).where(models.Meal.user_id==user_id).all()
    return meals

def create(request,db:Session):
    # gluco_bot.chat()
   
    if request.meal_type not in ["Fast","Before Meal","After Meal"]:
        raise  HTTPException(status_code=status.HTTP_400_BAD_REQUEST,detail=f"Meal type Not Found,it can be only: 'Fast','Before Meal', 'After Meal")
    if request.meal_type in ["Fast","Before Meal"]:
        prev_meal=db.query(models.Meal).all()[db.query(models.Meal).count()-1]
        res_dict=gluco_bot.chatAsJSON("notice:I am analyse this gl of meal_type of: "+request.meal_type+ "Right Now!, but my last meal was:"+prev_meal.description+"in: "+str(prev_meal.meal_time))
    if request.meal_type == "After Meal":
        res_dict=gluco_bot.chatAsJSON(request.description)
    new_meal=models.Meal(
        description=request.description,
        meal_type=request.meal_type,
        meal_time=request.meal_time,
        user_id=request.user_id,
        GL=float(res_dict["gluco_percent"]))
    
    db.add(new_meal)
    db.commit()
    db.refresh(new_meal)
    new_archive=models.PrevAnalyse(
        user_id=request.user_id,
        meal_id=new_meal.id,
        gluco_percent=float(res_dict["gluco_percent"]),
        risk_result=res_dict["risk"],
        analysed_at=pd.to_datetime(res_dict["analysed_at"]))
    
    db.add(new_archive)
    db.commit()
    db.refresh(new_archive,attribute_names=["meal"])
    # , attribute_names=["creator"]
    return {"message":"Meal created successfully","archive":new_archive}

def show(id:int,db:Session):
    meal=db.query(models.Meal).filter(models.Meal.id==id).first()
    if not meal:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND,detail=f"Meal with the id {id} is not available")
    return meal

# def update(id:int,request,db:Session):
#     meal=db.query(models.Meal).filter(models.Meal.id==id).first()
#     if not meal:
#         raise HTTPException(status_code=status.HTTP_404_NOT_FOUND,detail=f"Meal with the id {id} is not available")
#     meal.user_id=request.user_id
#     meal.meal_time=request.meal_time
#     db.commit()
#     db.refresh(meal)
#     return meal


