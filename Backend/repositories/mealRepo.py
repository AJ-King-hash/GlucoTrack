import math
from sqlalchemy.orm import Session
from fastapi import HTTPException,status
import models
from hashing import Hash
from datetime import datetime,timezone
from GlucoBot import GlucoBot
import FuzzyTraining.Fuzzy as Fuzzy
import FuzzyTraining.ExpertSystem as expert_system
import pandas as pd
gluco_bot=GlucoBot()

def get_all(user_id:int,db:Session):
    meals=db.query(models.Meal).where(models.Meal.user_id==user_id).all()
    return meals


def create(request, db: Session, current_user):
    if request.meal_type not in ["Fast", "Before Meal", "After Meal"]:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Meal type Not Found, it can be only: 'Fast','Before Meal', 'After Meal'")
    
    current_time = datetime.now().strftime("%Y-%m-%dT%H:%M:%S")
    fallback_response = {
        'risk': 'Medium',
        'gluco_percent': 10.0,
        'analysed_at': current_time,
        'recommendations': 'Analysis pending',
        'meal_tips': 'Consider pairing with protein or fiber'
    }
    
    try:
        # تحليل الوجبة عبر البوت لاستخراج الـ Glycemic Load
        res_dict = gluco_bot.chatAsJSON(request.description)
    except Exception as e:
        print(f"GlucoBot API error: {str(e)}")
        res_dict = fallback_response

    # إنشاء سجل الوجبة
    descs = db.query(models.Meal).filter(models.Meal.user_id == current_user.id)
    new_meal = models.Meal(
        description=" ".join([d[0] for d in descs.with_entities(models.Meal.description).all()]) if descs.count() == 3 else request.description,
        meal_type=request.meal_type,
        meal_time=request.meal_time,
        user_id=current_user.id,
        GL=round(float(res_dict["gluco_percent"]), 2)
    )
    
    db.add(new_meal)
    db.commit()
    db.refresh(new_meal)
    
    checking = db.query(models.Meal).filter(models.Meal.user_id == current_user.id)
    
    # التحليل عند توفر 4 وجبات فأكثر
    if checking.count() > 3:
        Qq = checking.with_entities(models.Meal.GL).all()
        mean_gl = sum([q[0] for q in Qq]) / len(Qq)
        
        # جلب بيانات المريض
        user_risk = db.query(models.RiskFactor).filter(models.RiskFactor.user_id == current_user.id).first()
        bmi = user_risk.BMI if user_risk and user_risk.BMI else 22.0
        genetic = user_risk.genetic_disease if user_risk else False
        
        # تحويل النشاط البدني لقيمة رقمية للفازي (0-10)
        activity_val = 5 
        if user_risk and user_risk.physical_activity:
            activity_map = {"high": 9, "medium": 5, "low": 1}
            activity_val = activity_map.get(user_risk.physical_activity.lower(), 5)

        # 1. تطبيق المنطق الضبابي (Fuzzy Logic) للتنبؤ بـ HbA1c
        try:
            Fuzzy.fuzzy_sim.input["glycemic_load"] = round(float(mean_gl), 2)
            Fuzzy.fuzzy_sim.input["physical_activity"] = activity_val
            Fuzzy.fuzzy_sim.compute()
            predicted_hba1c = round(float(Fuzzy.fuzzy_sim.output["hba1c"]), 2)
        except:
            predicted_hba1c = None

        # 2. تطبيق نظام الخبرة (Expert System - CF) لتحديد الخطر
        cf_score = expert_system.expert_system.evaluate_patient_risk(mean_gl, bmi, genetic)
        expert_risk_label = expert_system.expert_system.get_risk_label(cf_score)

        # 3. حفظ التحليل الهجين
        new_archive = models.PrevAnalyse(
            user_id=current_user.id,
            meal_id=new_meal.id,
            gluco_percent=round(float(mean_gl), 2),
            hba1c=predicted_hba1c,
            risk_result=expert_risk_label,
            analysed_at=pd.to_datetime(res_dict["analysed_at"]),
            recommendations=f"Expert CF Score: {cf_score}. {res_dict['recommendations']}",
            meal_tips=res_dict["meal_tips"]
        )
        
        db.add(new_archive)
        # تنظيف الوجبات القديمة
        db.query(models.Meal).filter(models.Meal.user_id == new_archive.user_id, models.Meal.id != new_archive.meal_id).delete()
        db.commit()
        db.refresh(new_archive, attribute_names=["meal"])

        return {"message": "Hybrid Analysis (Expert + Fuzzy) Completed", "archive": new_archive}
        
    else:
        new_archive = models.PrevAnalyse(
            user_id=current_user.id,
            meal_id=new_meal.id,
            gluco_percent=round(float(res_dict["gluco_percent"]), 2),
            hba1c=None,
            risk_result=res_dict["risk"],
            analysed_at=pd.to_datetime(res_dict["analysed_at"]),
            recommendations=res_dict["recommendations"],
            meal_tips=res_dict["meal_tips"]
        )
        db.add(new_archive)
        db.commit()
        db.refresh(new_archive, attribute_names=["meal"])

    return {"message": "Meal created successfully", "archive": new_archive}

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



