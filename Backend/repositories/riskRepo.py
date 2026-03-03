from sqlalchemy.orm import Session
import models
from fastapi import HTTPException,status
from datetime import datetime,timezone
import numpy as np
def create(request,db:Session):

    # if request.medicine not in ["Fast","Before Meal","After Meal"]:
        # raise  HTTPException(status_code=status.HTTP_400_BAD_REQUEST,detail=f"Meal type Not Found,it can be only: 'Fast','Before Meal', 'After Meal")
    new_risks=models.RiskFactor(
        user_id=request.user_id,
        age=request.age,
        weight=float(request.weight),
        height=float(request.height),
        BMI=request.weight/pow(request.height,2),
        sugar_pregnancy=request.sugar_pregnancy,
        smoking=request.smoking,
        genetic_disease=request.genetic_disease,
        physical_activity=request.physical_activity,
        diabetes_type=request.diabetes_type,
        medicine_type=request.medicine_type,
        )
    
    db.add(new_risks)
    db.commit()
    db.refresh(new_risks)

    return {"message":"Risk Factors added successfully!","risk_factors":new_risks}

def update(user_id:int,request,db:Session):
    risks=db.query(models.RiskFactor).filter(models.RiskFactor.user_id==user_id).first()
    if not risks:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND,detail=f"risk Factors with the user id {user_id} is not available")
    risks.age=request.age
    risks.weight=float(request.weight)
    risks.height=float(request.height)
    risks.BMI=request.weight/pow(request.height,2)
    risks.sugar_pregnancy=request.sugar_pregnancy
    risks.smoking=request.smoking
    risks.genetic_disease=request.genetic_disease
    risks.physical_activity=request.physical_activity
    risks.diabetes_type=request.diabetes_type
    risks.medicine_type=request.medicine_type
    risks.updated_at=datetime.now(timezone.utc)
    db.commit()
    db.refresh(risks)
    return risks

def show(user_id:int,db:Session):
    risks=db.query(models.RiskFactor).filter(models.RiskFactor.user_id==user_id).first()
    if not risks:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND,detail=f"Risk Factors with the id {user_id} is not available")
    return risks

def delete(user_id:int,db:Session):
    risks=db.query(models.RiskFactor).filter(models.RiskFactor.user_id==user_id).first()
    if not risks:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND,detail=f"Risk Factors with the user id {user_id} is not available")
    db.delete(risks)
    db.commit() 
