from fastapi import APIRouter,Depends,Query
import schemas
from sqlalchemy.orm import Session
from database import get_db
from repositories import botRepo
import oauth2
from typing import List, Optional
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
def all_conversations(
    db:Session=Depends(get_db),
    current_user:schemas.User=Depends(oauth2.get_current_user),
    page: int = Query(1, ge=1, description="Page number"),
    limit: int = Query(10, ge=1, le=100, description="Items per page"),
    search: Optional[str] = Query(None, description="Search by conversation title")
):
    """Get all conversations with pagination and search support."""
    return botRepo.get_all(
        current_user.id, 
        db, 
        page=page, 
        limit=limit,
        search=search
    )

@router.get("/conversation/count/")
def get_conversation_count(
    db:Session=Depends(get_db),
    current_user:schemas.User=Depends(oauth2.get_current_user)
):
    """Get total count of conversations for pagination info."""
    from database import get_db
    import models
    db_session = next(db)
    count = db_session.query(models.Conversation).filter(models.Conversation.user_id == current_user.id).count()
    return {"total": count}

@router.delete("/conversation/{id}")
def delete_conversation(id:int,db:Session=Depends(get_db),current_user:schemas.User=Depends(oauth2.get_current_user)):
    botRepo.delete(id,db)
    return {"message": f"Conversation {id} deleted successfully!"}



################## Messages ##################

@router.post("/message")
def create_message(request:schemas.MessageBase,db:Session=Depends(get_db),current_user:schemas.User=Depends(oauth2.get_current_user)):
    return botRepo.create_message(request,db)

# @router.get("/message/{id}",response_model=schemas.MessageShow)
# def show_message(id:int,db:Session=Depends(get_db)):
#     return botRepo.show(id,db)

@router.get("/message/all/{conv_id}",response_model=List[schemas.MessageShow])
def all_messages(
    conv_id:int,
    db:Session=Depends(get_db),
    current_user:schemas.User=Depends(oauth2.get_current_user),
    page: int = Query(1, ge=1, description="Page number"),
    limit: int = Query(50, ge=1, le=200, description="Items per page")
):
    """Get all messages with pagination support."""
    return botRepo.get_messages(conv_id, db, page=page, limit=limit)

@router.get("/message/count/{conv_id}")
def get_message_count(
    conv_id:int,
    db:Session=Depends(get_db),
    current_user:schemas.User=Depends(oauth2.get_current_user)
):
    """Get total count of messages for pagination info."""
    from database import get_db
    import models
    db_session = next(db)
    count = db_session.query(models.Message).filter(models.Message.conversation_id == conv_id).count()
    return {"total": count}
