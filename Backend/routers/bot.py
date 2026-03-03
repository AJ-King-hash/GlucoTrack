from fastapi import APIRouter,Depends
import schemas
from sqlalchemy.orm import Session
from database import get_db
from repositories import botRepo
import oauth2
from typing import List
router=APIRouter(
    prefix="/bot",
    tags=["Gluco Bot"]
)

################## Conversations ##################

@router.post("/conversation")
def create_conversation(request:schemas.ConversationBase,db:Session=Depends(get_db),current_user:schemas.User=Depends(oauth2.get_current_user)):
    return botRepo.create(request,db)

@router.get("/conversation/{id}",response_model=schemas.ConversationShow)
def show_conversation(id:int,db:Session=Depends(get_db),current_user:schemas.User=Depends(oauth2.get_current_user)):
    return botRepo.show(id,db)

@router.get("/conversation/all/",response_model=List[schemas.ConversationAll])
def all_conversations(db:Session=Depends(get_db),current_user:schemas.User=Depends(oauth2.get_current_user)):
    return botRepo.get_all(current_user.id,db)

@router.delete("/conversation/{id}")
def delete_conversation(id:int,db:Session=Depends(get_db),current_user:schemas.User=Depends(oauth2.get_current_user)):
    botRepo.delete(id,db)
    return {"message": f"Analyse {id} deleted successfully!"}



################## Messages ##################

@router.post("/message")
def create_message(request:schemas.MessageBase,db:Session=Depends(get_db),current_user:schemas.User=Depends(oauth2.get_current_user)):
    return botRepo.create_message(request,db)

# @router.get("/message/{id}",response_model=schemas.MessageShow)
# def show_message(id:int,db:Session=Depends(get_db)):
#     return botRepo.show(id,db)

@router.get("/message/all/{conv_id}",response_model=List[schemas.MessageShow])
def all_messages(conv_id:int,db:Session=Depends(get_db),current_user:schemas.User=Depends(oauth2.get_current_user)):
    return botRepo.get_messages(conv_id,db)


