import math
from sqlalchemy import null
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
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Meal type error")

    # 1. البحث عن الوجبات التي ليس لها تحليل مسبقاً (قبل إضافة الوجبة الحالية)
    # نستخدم .all() لضمان الحصول على البيانات قبل التعديل
    unanalysed_meals = db.query(models.Meal).filter(
        models.Meal.user_id == current_user.id,
        ~models.Meal.analyse.any()
    ).all()

    current_time = datetime.now().strftime("%Y-%m-%dT%H:%M:%S")
    fallback_response = {
        'risk': 'Medium', 'gluco_percent': 10.0, 'analysed_at': current_time,
        'recommendations': 'Analysis pending', 'meal_tips': 'Consider fiber'
    }

    try:
        res_dict = gluco_bot.chatAsJSON(request.description)
    except Exception as e:
        res_dict = fallback_response

    # 2. منطق دمج الـ Descriptions إذا كانت هذه هي الوجبة الثالثة (أي يوجد 2 سابقات)
    final_description = request.description
    if len(unanalysed_meals) == 2:  # الوجبتين السابقتين + الحالية = 3
        previous_descs = [m.description for m in unanalysed_meals]
        final_description = " | ".join(previous_descs + [request.description])

    # 3. إنشاء سجل الوجبة الجديدة
    new_meal = models.Meal(
        description=final_description,
        meal_type=request.meal_type,
        meal_time=request.meal_time,
        user_id=current_user.id,
        GL=round(float(res_dict["gluco_percent"]), 2)
    )
    db.add(new_meal)
    db.commit()
    db.refresh(new_meal)

    # 4. التحقق من العدد الإجمالي للوجبات بدون تحليل (بعد إضافة الحالية)
    checking_query = db.query(models.Meal).filter(
        models.Meal.user_id == current_user.id,
        ~models.Meal.analyse.any()
    )
    
    total_unanalysed = checking_query.count()

    if total_unanalysed >= 3:
        # جلب الـ GL لجميع الوجبات التي ليس لها تحليل
        unanalysed_records = checking_query.all()
        mean_gl = sum([m.GL for m in unanalysed_records]) / len(unanalysed_records)
        
        # بيانات المريض للنظام الخبير والفازي
        user_risk = db.query(models.RiskFactor).filter(models.RiskFactor.user_id == current_user.id).first()
        bmi = user_risk.BMI if user_risk and user_risk.BMI else 22.0
        genetic = user_risk.genetic_disease if user_risk else False
        
        activity_val = 5 
        if user_risk and user_risk.physical_activity:
            activity_map = {"high": 9, "medium": 5, "low": 1}
            activity_val = activity_map.get(user_risk.physical_activity.lower(), 5)

        # Fuzzy Logic
        try:
            Fuzzy.fuzzy_sim.input["glycemic_load"] = round(float(mean_gl), 2)
            Fuzzy.fuzzy_sim.input["physical_activity"] = activity_val
            Fuzzy.fuzzy_sim.compute()
            predicted_hba1c = round(float(Fuzzy.fuzzy_sim.output["hba1c"]), 2)
        except:
            predicted_hba1c = None

        # Expert System
        cf_score = expert_system.expert_system.evaluate_patient_risk(mean_gl, bmi, genetic)
        expert_risk_label = expert_system.expert_system.get_risk_label(cf_score)

        # حفظ التحليل المجمع (مرتبط بآخر وجبة تم إنشاؤها)
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
        db.commit()

        # 5. تنظيف الوجبات: حذف كل الوجبات ماعدا الوجبة التي تم ربط التحليل بها حالياً
        db.query(models.Meal).filter(
            models.Meal.user_id == current_user.id,
            models.Meal.id != new_meal.id , # استثناء الوجبة الحالية
            ~models.Meal.analyse.any()
        ).delete(synchronize_session=False)
        
        db.commit()
        db.refresh(new_archive,attribute_names=["meal"])


        return {"message": "Hybrid Analysis (Expert + Fuzzy) Completed", "archive": new_archive}
        
    else:
        dummy_archive={
        "id": 50,
        "risk_result": "Need More Meals To Check",
        "user_id": current_user.id,
        "meal_tips": "Need More Meals To Check",
        "gluco_percent": float(0.00),
        "meal_id": 1,
        "recommendations": "Need More Meals To Check",
        "hba1c": None,
        "analysed_at": current_time,
        "meal": new_meal
        # "meal": {
        # "user_id": current_user.id,
        # "meal_time": request.meal_time,
        # "GL":  float(0.00),
        # "created_at": "2026-05-07T11:31:49.941467",
        # "id": new_meal.id,
        # "meal_type": request.meal_type,
        # "updated_at": None,
        # "description": request.description
        # }
        }
    
        new_archive=dummy_archive
        # new_archive = models.PrevAnalyse(
        #     user_id=current_user.id,
        #     meal_id=new_meal.id,
        #     gluco_percent=round(float(res_dict["gluco_percent"]), 2),
        #     hba1c=None,
        #     risk_result=res_dict["risk"],
        #     analysed_at=pd.to_datetime(res_dict["analysed_at"]),
        #     recommendations=res_dict["recommendations"],
        #     meal_tips=res_dict["meal_tips"]
        # )
        # db.add(new_archive)
        # db.commit()
        # db.refresh(new_archive, attribute_names=["meal"])

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



