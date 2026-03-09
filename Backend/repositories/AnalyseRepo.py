from sqlalchemy.orm import Session
import models
from fastapi import HTTPException,status

def get_all(user_id:int,db:Session):
    analysis=db.query(models.PrevAnalyse).where(models.PrevAnalyse.user_id==user_id).all()
    return analysis

def delete(id:int,db:Session):
    analyse=db.query(models.PrevAnalyse).filter(models.PrevAnalyse.id==id).first()
    if not analyse:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND,detail=f"analyse with the id {id} is not available")
    db.delete(analyse)
    db.commit() 