from datetime import datetime ,timezone
from sqlalchemy import Column,Integer,String,ForeignKey,DateTime,Float,Enum,Boolean
from database import Base
from sqlalchemy.orm import relationship

class Otp(Base):
    __tablename__="otps"
    id=Column(Integer,primary_key=True,index=True)
    email=Column(String)
    otp=Column(String)
    expires=Column(DateTime(timezone=True))
    user_id=Column(Integer,ForeignKey("users.id"))
    creator=relationship("User",back_populates="otps")
    # Base:is to tell the sqlalchemy is that this class is for orm models

    # otp_store[email] = {"otp": otp_str, "expires": expires}

class Meal(Base):
    __tablename__="meals"
    id=Column(Integer,primary_key=True,index=True)
    user_id=Column(Integer,ForeignKey("users.id"))
    # GI=Column(Float,nullable=True)
    # GL=(GI*Carbohydrates)/100
    GL=Column(Float,nullable=True) 
    # Calories=Column(Float,nullable=True)  
    # Carbohydrates=Column(Float,nullable=True)  
    # Protein=Column(Float,nullable=True)  
    # Fat=Column(Float,nullable=True)
    # Sodium=Column(Float,nullable=True)
    # Potassium=Column(Float,nullable=True)
    # Magnesium=Column(Float,nullable=True)
    # Calcium=Column(Float,nullable=True)
    # Fiber=Column(Float,nullable=True)
    meal_type=Column(String)
    meal_time=Column(DateTime(timezone=True))
    description=Column(String,nullable=True)
    creator=relationship("User",back_populates="meals")
    analyse=relationship("PrevAnalyse",back_populates="meal")

class PrevAnalyse(Base):
    __tablename__="prev_analysis"
    id=Column(Integer,primary_key=True,index=True)
    user_id=Column(Integer,ForeignKey("users.id"))
    meal_id=Column(Integer,ForeignKey("meals.id"))
    gluco_percent=Column(Float(2))
    # Low,Medium,High
    risk_result=Column(String)
    analysed_at=Column(DateTime(timezone=True),default=datetime.now(timezone.utc))
    creator=relationship("User",back_populates="analysis")
    meal=relationship("Meal",back_populates="analyse")

class RiskFactor(Base):
    __tablename__="risk_factors"
    id=Column(Integer,primary_key=True,index=True)
    user_id=Column(Integer,ForeignKey("users.id"))
    age=Column(Integer)
    weight=Column(Float(2))
    height=Column(Float(2))
    # divide your weight in kilograms by your height in meters squared (BMI = kg/m²)
    BMI=Column(Float(2))
    sugar_pregnancy=Column(Integer,nullable=True)
    smoking=Column(Boolean)
    genetic_disease=Column(Boolean)
    physical_activity=Column(String)
    # d1,d2
    diabetes_type=Column(String)
    # ["Insuline","MouthSugarLower"]
    medicine_type=Column(String)
    created_at=Column(DateTime(timezone=True),default=datetime.now(timezone.utc))
    updated_at=Column(DateTime(timezone=True),nullable=True)        
    creator=relationship("User",back_populates="risks")



class Conversation(Base):
    __tablename__="conversations"
    id=Column(Integer,primary_key=True,index=True)
    user_id=Column(Integer,ForeignKey("users.id"))
    title=Column(String)    
    created_at=Column(DateTime(timezone=True),default=datetime.now(timezone.utc))
    updated_at=Column(DateTime(timezone=True),nullable=True)    
    messages=relationship("Message",back_populates="conversation")
    user=relationship("User",back_populates="conversations")
class Message(Base):
    __tablename__="messages"
    id=Column(Integer,primary_key=True,index=True)
    conversation_id=Column(Integer,ForeignKey("conversations.id"))
    sender_type=Column(String)
    message=Column(String)
    created_at=Column(DateTime(timezone=True),default=datetime.now(timezone.utc))
    updated_at=Column(DateTime(timezone=True),nullable=True)
    conversation=relationship("Conversation",back_populates="messages")


class User(Base):
    __tablename__="users"
    id=Column(Integer,primary_key=True,index=True)
    name=Column(String)
    email=Column(String)
    password=Column(String)
    created_at=Column(DateTime(timezone=True),default=datetime.now(timezone.utc))
    updated_at=Column(DateTime(timezone=True),nullable=True)
    gluco_reminder=Column(DateTime(timezone=True),nullable=True)
    medicine_reminder=Column(DateTime(timezone=True),nullable=True)
    fcm_token = Column(String, nullable=True)  # New: For push notifications
    timezone = Column(String, default="UTC")   # New: e.g., "Asia/Riyadh"
    otps=relationship("Otp",back_populates="creator")
    meals=relationship("Meal",back_populates="creator")
    analysis=relationship("PrevAnalyse",back_populates="creator")
    risks=relationship("RiskFactor",back_populates="creator")
    conversations=relationship("Conversation",back_populates="user")


