from typing import List, Optional
from sqlalchemy import DateTime
from pydantic import BaseModel, Field
from datetime import datetime
class User(BaseModel):
    name:str
    email:str
    password:str
    # created_at:datetime
    # updated_at:datetime|None

class AnalyseBase(BaseModel):
    gluco_percent:float
    analysed_at:datetime
class RiskBase(BaseModel):
    age:int
    user_id:int
    weight:float
    height:float
    sugar_pregnancy:int
    smoking:bool
    genetic_disease:bool
    physical_activity:str
    diabetes_type:str
    medicine_type:str
class RiskShow(RiskBase):
    id:int
    age:int
    user_id:int
    weight:float
    height:float
    BMI:float
    sugar_pregnancy:int
    smoking:bool
    genetic_disease:bool
    diabetes_type:str
    medicine_type:str
    created_at:datetime
    updated_at:datetime|None    
    class Config():
        from_attributes=True
class ShowRiskFactorWithMessage(BaseModel):
    message:str
    risk_factors:RiskShow
    class Config():
        from_attributes=True
        
class MealBase(BaseModel):
    description:str
    meal_type:str
    meal_time:datetime
    user_id:int
    
class MealAll(MealBase):
    id:int
    user_id:int
    title:str
    created_at:datetime
    updated_at:datetime | None
    class Config():
        from_attributes=True

class AnalyseShow(AnalyseBase):
    id:int
    gluco_percent:float
    risk_result:str
    analysed_at:datetime
    meal:MealBase    
    class Config():
        from_attributes=True
# the ShowUser should be up the otp because the python run the codes line-by-line
class OtpBase(BaseModel):
    email:str
    otp:str
    expires:datetime
class Otp(OtpBase):
    class Config():
        from_attributes=True
            
class ShowUser(BaseModel):
    id:int
    name:str
    email:str
    # otps:List[Otp]=[]
    class Config():
        from_attributes=True
        
class ShowUserWithMessage(BaseModel):
    message:str
    user:ShowUser
    # otps:List[Otp]=[]
    class Config():
        from_attributes=True
        
class ShowUser2(BaseModel):
    name:str
    email:str
    class Config():
        from_attributes=True


class ShowOtp(BaseModel):
    name:str
    creator:ShowUser2
    class Config():
        from_attributes=True



class Login(BaseModel):
    email:str
    password:str

    

class Token(BaseModel):
    access_token: str
    token_type: str


class TokenData(BaseModel):
    id:int | None=None
    email: str | None = None



class EmailSchema(BaseModel):
    email: str

class VerifySchema(BaseModel):
    email: str
    otp: str

class ResetPasswordRequest(BaseModel):
    email: str
    new_password: str


class MessageBase(BaseModel):
    conversation_id:int
    sender_type:str
    message:str | None
class MessageShow(MessageBase):
    id:int
    conversation_id:int
    sender_type:str
    message:str
    created_at:datetime
    updated_at:datetime | None
    class Config():
        from_attributes=True
class ConversationBase(BaseModel):
    user_id:int
    title:str

class ConversationAll(ConversationBase):
    id:int
    user_id:int
    title:str
    created_at:datetime
    updated_at:datetime | None
    class Config():
        from_attributes=True
class ConversationShow(ConversationBase):
    id:int
    user_id:int
    title:str
    created_at:datetime
    updated_at:datetime | None
    messages:List[MessageBase]=[]
    class Config():
        from_attributes=True


class UserReminderUpdate(BaseModel):
    gluco_time: Optional[str] = None  # e.g., "03:00" (24-hour format)
    medicine_time: Optional[str] = None  # e.g., "03:00"
    timezone: Optional[str] = "UTC"  # User's timezone

class FCMTokenUpdate(BaseModel):
    fcm_token: str


class ShowUserToken(BaseModel):
    id:int
    name:str
    email:str
   
    # otps:List[Otp]=[]
    class Config():
        from_attributes=True
        

class ShowUserWithMessageToken(BaseModel):
    message:str
    user:ShowUserToken
    token:Token
    class Config():
        from_attributes=True

class ShowMessage(BaseModel):
    message:str
