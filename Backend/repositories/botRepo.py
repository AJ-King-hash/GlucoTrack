from sqlalchemy.orm import Session
from fastapi import HTTPException,status
from fastapi.encoders import jsonable_encoder
from fastapi.responses import JSONResponse
import models
import functools
import json
from hashing import Hash
from datetime import datetime,timezone
from GlucoBot import GlucoBot
import pandas as pd
from typing import Optional
gluco_bot=GlucoBot()

def get_all(
    user_id:int, 
    db:Session,
    page: int = 1,
    limit: int = 10,
    search: Optional[str] = None
):
    """Get all conversations with pagination and search support."""
    query = db.query(models.Conversation).where(models.Conversation.user_id == user_id)
    
    # Apply search filter (search in conversation title)
    if search:
        search_term = f"%{search}%"
        query = query.filter(models.Conversation.title.ilike(search_term))
    
    # Apply sorting (newest first by created_at)
    query = query.order_by(models.Conversation.created_at.desc())
    
    # Apply pagination
    offset = (page - 1) * limit
    conversations = query.offset(offset).limit(limit).all()
    
    return conversations

def create(request,db:Session):
        
    new_conversation=models.Conversation(
        user_id=request.user_id,
        title=request.title,
    )
    db.add(new_conversation)
    db.commit()
    db.refresh(new_conversation)
    return {"message":"Conversation created successfully","conversation":new_conversation}

def show(id:int,db:Session):
    conversation=db.query(models.Conversation).filter(models.Conversation.id==id).first()   
    if not conversation:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND,detail=f"Conversation with the id {id} is not available")
    return conversation

def delete(id:int,db:Session):
    conversation=db.query(models.Conversation).filter(models.Conversation.id==id).first()
    messages=db.query(models.Message).where(models.Message.conversation_id==conversation.id).all()

    if not conversation:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND,detail=f"conversation with the id {id} is not available")
    db.delete(messages)
    db.delete(conversation)
    db.commit() 

################## Messages ##################
################## Messages ##################
################## Messages ##################


def get_messages(conv_id:int, db:Session, page: int = 1, limit: int = 50):
    """Get messages with pagination support."""
    query = db.query(models.Message).where(models.Message.conversation_id==conv_id)
    
    # Apply sorting (oldest first for chat)
    query = query.order_by(models.Message.created_at.asc())
    
    # Apply pagination
    offset = (page - 1) * limit
    messages = query.offset(offset).limit(limit).all()
    
    return messages

def _get_user_profile_context(user, risks):
    """
    Build a comprehensive user profile context string for the AI.
    Includes: name, age, weight, height, BMI, diabetes type, medicine, lifestyle factors
    """
    if not user:
        return "No user profile available"
    
    profile_parts = [f"User: {user.name}"]
    
    # Get latest risk factor if available
    if risks:
        latest_risk = risks[-1]  # Most recent risk factor
        profile_parts.append(f"Age: {latest_risk.age} years")
        profile_parts.append(f"Weight: {latest_risk.weight} kg")
        profile_parts.append(f"Height: {latest_risk.height} m")
        profile_parts.append(f"BMI: {latest_risk.BMI:.1f}")
        profile_parts.append(f"Diabetes Type: {latest_risk.diabetes_type}")
        profile_parts.append(f"Medicine: {latest_risk.medicine_type}")
        profile_parts.append(f"Physical Activity: {latest_risk.physical_activity}")
        
        # Risk factors
        risk_factors = []
        if latest_risk.smoking:
            risk_factors.append("Smoking")
        if latest_risk.genetic_disease:
            risk_factors.append("Genetic Disease")
        if latest_risk.sugar_pregnancy and latest_risk.sugar_pregnancy > 0:
            risk_factors.append(f"Pregnancy Sugar: {latest_risk.sugar_pregnancy}")
        
        if risk_factors:
            profile_parts.append(f"Risk Factors: {', '.join(risk_factors)}")
    
    return ", ".join(profile_parts)

def _get_health_recommendations(risks, gluco_percent=None):
    """
    Generate personalized health recommendations based on user profile and recent analysis.
    """
    recommendations = []
    
    if not risks:
        return "Please set up your risk profile in the app for personalized recommendations."
    
    latest_risk = risks[-1]
    
    # BMI-based recommendations
    if latest_risk.BMI < 18.5:
        recommendations.append("Consider consulting about healthy weight gain strategies.")
    elif latest_risk.BMI >= 25:
        recommendations.append("Aim for gradual weight loss through diet and exercise.")
    
    # Diabetes type specific
    if latest_risk.diabetes_type == "Type 1":
        recommendations.append("Monitor blood sugar closely and adjust insulin as needed.")
    elif latest_risk.diabetes_type == "Type 2":
        recommendations.append("Focus on dietary control and regular physical activity.")
    
    # Recent glucose analysis
    if gluco_percent is not None:
        if gluco_percent < 10:
            recommendations.append("Your recent glucose levels are well controlled!")
        elif gluco_percent < 20:
            recommendations.append("Your glucose levels are moderate. Watch portion sizes.")
        else:
            recommendations.append("Your glucose levels are elevated. Consider consulting your doctor.")
    
    return " ".join(recommendations) if recommendations else "Maintain your current healthy lifestyle."

def create_message(request,db:Session):
    if request.sender_type not in ["user","bot"]:
        raise  HTTPException(status_code=status.HTTP_400_BAD_REQUEST,detail=f"Sender Type {request.sender_type} incorrect!,it can be only: 'user' OR 'bot'")
    if request.sender_type =="user":

        new_message=models.Message(
            conversation_id=request.conversation_id,
            sender_type=request.sender_type,
            message=request.message
        )
        db.add(new_message)
        db.commit()
        db.refresh(new_message)
        return {"message":"Message created successfully","messsage":new_message}
    else:
        # Get conversation and user info
        all_messages=get_messages(request.conversation_id,db)
        single_last_message=all_messages[len(all_messages)-1]
        conv=db.query(models.Conversation).filter(models.Conversation.id==single_last_message.conversation_id).first()
        auth_user=db.query(models.User).filter(models.User.id==conv.user.id).first()
        risks=auth_user.risks
        
        # Get user's most recent glucose analysis for context
        recent_analysis = db.query(models.PrevAnalyse).filter(
            models.PrevAnalyse.user_id == auth_user.id
        ).order_by(models.PrevAnalyse.analysed_at.desc()).first()
        
        gluco_context = ""
        if recent_analysis:
            gluco_context = f"User's most recent glucose analysis: {recent_analysis.gluco_percent}% ({recent_analysis.risk_result})"
        
        # Build comprehensive context for the AI
        profile_context = _get_user_profile_context(auth_user, risks)
        health_recommendations = _get_health_recommendations(risks, recent_analysis.gluco_percent if recent_analysis else None)
        
        # Enhanced prompt for the AI
        enhanced_prompt = f"""User Question: {single_last_message.message}

User Profile: {profile_context}
{gluco_context}

Personalized Recommendations: {health_recommendations}

Please provide a helpful, personalized response about diabetes management, nutrition, or health.
Keep your response concise but informative.
If the user asks about meal recommendations, consider their profile and recent glucose levels.
Do not mention that you're an AI or repeat the user profile information in your response.
"""
        
        message=gluco_bot.chat(enhanced_prompt)
        bot_message=models.Message(
            conversation_id=request.conversation_id,
            sender_type=request.sender_type,
            message=message
        )
        db.add(bot_message)
        db.commit()
        db.refresh(bot_message)
        return {"bot_respond":bot_message}
