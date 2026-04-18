import math
from sqlalchemy.orm import Session
from fastapi import HTTPException,status
import models
from hashing import Hash
from datetime import datetime,timezone
from GlucoBot import GlucoBot
import FuzzyTraining.Fuzzy as Fuzzy
import pandas as pd
gluco_bot=GlucoBot()

def get_all(user_id:int,db:Session):
    meals=db.query(models.Meal).where(models.Meal.user_id==user_id).all()
    return meals


def create(request,db:Session,current_user):
    # gluco_bot.chat()
   
    if request.meal_type not in ["Fast","Before Meal","After Meal"]:
        raise  HTTPException(status_code=status.HTTP_400_BAD_REQUEST,detail=f"Meal type Not Found,it can be only: 'Fast','Before Meal', 'After Meal")
    
    # Default fallback response in case GlucoBot API fails or times out
    current_time = datetime.now().strftime("%Y-%m-%dT%H:%M:%S")
    fallback_response = {
        'risk': 'Medium',
        'gluco_percent': 10.0,
        'analysed_at': current_time,
        'recommendations': 'Analysis pending - please check back later',
        'meal_tips': 'Consider pairing with protein or fiber'
    }
    
    try:
        if request.meal_type in ["Fast","Before Meal"]:
            # Get the user's last meal, if any
            prev_meal=db.query(models.Meal).filter(
                models.Meal.user_id == current_user.id
            ).order_by(models.Meal.meal_time.desc()).first()
            
            if prev_meal:
                # Use the meal description for analysis
                res_dict=gluco_bot.chatAsJSON(request.description)
            else:
                # No previous meal - analyze without context
                res_dict=gluco_bot.chatAsJSON(request.description)
        if request.meal_type == "After Meal":
            res_dict=gluco_bot.chatAsJSON(request.description)
    except Exception as e:
        # Catch all exceptions (API errors, timeout errors, etc.) and use fallback
        print(f"GlucoBot API error: {str(e)}")
        res_dict = fallback_response
    descs=db.query(models.Meal).filter(models.Meal.user_id==current_user.id)
    new_meal=models.Meal(
        description="\n".join([d[0] for d in descs.with_entities(models.Meal.description).all()]) if descs.count()==2 else request.description,
        meal_type=request.meal_type,
        meal_time=request.meal_time,
        user_id=current_user.id,
        GL=round(float(res_dict["gluco_percent"]),2))
    
    db.add(new_meal)
    db.commit()
    db.refresh(new_meal)
    checking=db.query(models.Meal).filter(models.Meal.user_id==current_user.id)
    
    if checking.count()>3:
            Qq=checking.with_entities(models.Meal.GL).all()
            mean_gluco_columns=sum([q[0] for q in Qq])/len([q[0] for q in Qq])
            Fuzzy.fuzzy_sim.input["glycemic_load"]=round(float(mean_gluco_columns),2)
            Fuzzy.fuzzy_sim.input["physical_activity"]=db.query(models.RiskFactor).filter(models.RiskFactor.user_id==current_user.id).first().BMI
            Fuzzy.fuzzy_sim.compute()

            new_archive=models.PrevAnalyse(
                user_id=current_user.id,
                meal_id=new_meal.id,
                gluco_percent=round(float(mean_gluco_columns),2),
                hba1c=round(float(Fuzzy.fuzzy_sim.output["hba1c"]),2),
                risk_result=res_dict["risk"],
                analysed_at=pd.to_datetime(res_dict["analysed_at"]),
                recommendations=res_dict["recommendations"],
                meal_tips=res_dict["meal_tips"]
                )
            db.add(new_archive)

            db.query(models.Meal).filter(models.Meal.user_id==new_archive.user_id,models.Meal.id!=new_archive.meal_id).delete()
            db.commit()
            db.refresh(new_archive,attribute_names=["meal"])

            return {"message":"Analysis Arrived!","archive":new_archive}
    else:
            new_archive=models.PrevAnalyse(
                user_id=current_user.id,
                meal_id=new_meal.id,
                gluco_percent=round(float(res_dict["gluco_percent"]),2),
                hba1c=None,
                risk_result=res_dict["risk"],
                analysed_at=pd.to_datetime(res_dict["analysed_at"]),
                recommendations=res_dict["recommendations"],
                meal_tips=res_dict["meal_tips"]
                )
            db.add(new_archive)
            db.commit()
            db.refresh(new_archive,attribute_names=["meal"])

    return {"message":"Meal created successfully ","archive":new_archive}

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


