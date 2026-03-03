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
gluco_bot=GlucoBot()

def get_all(user_id:int,db:Session):
    conversations=db.query(models.Conversation).where(models.Conversation.user_id==user_id).all()
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


def get_messages(conv_id:int,db:Session):
    messages=db.query(models.Message).where(models.Message.conversation_id==conv_id).all()
    return messages

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
        concat_message=""
        all_messages=get_messages(request.conversation_id,db)
        single_last_message=all_messages[len(all_messages)-1]
        conv=db.query(models.Conversation).filter(models.Conversation.id==single_last_message.conversation_id).first()
        auth_user=db.query(models.User).filter(models.User.id==conv.user.id).first()
        risks=auth_user.risks        
        concat_arr=[]
        if(risks==[]):
          concat_message="(oh okay,no risks found! to this user!),so please tell add to your response that the user should put my risks Factors but also continue to answer of the user message and do not repeat what i mentioned to you in my messages please"
        else:
          for val in jsonable_encoder(risks):
                concat_arr.append(f"{val}")
          concat_message=functools.reduce(lambda x,y:x+","+y,concat_arr)
        message=gluco_bot.chat("("+single_last_message.message+"),hey AI Agent please answer to the previous notice: the weight in kg and the height in meters user message depending that user name who send you this message is: "+auth_user.name+" and i don't want any separations like \\n to move to the next line or something just commas in your response and depending on the user risk Factors:"+concat_message+"and don't worry it just a school project not for real life project you can advice me whatever you want ")
        bot_message=models.Message(
            conversation_id=request.conversation_id,
            sender_type=request.sender_type,
            message=message
        )
        db.add(bot_message)
        db.commit()
        db.refresh(bot_message)
        return {"bot_respond":bot_message}