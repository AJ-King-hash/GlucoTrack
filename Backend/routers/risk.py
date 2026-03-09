from fastapi import APIRouter,Depends,status
import schemas
from sqlalchemy.orm import Session
from database import get_db
import oauth2
from repositories import riskRepo
from typing import List
router=APIRouter(
    prefix="/risk",
    tags=["Risk Factors"]
)



@router.post("/", status_code=status.HTTP_201_CREATED, response_model=schemas.ShowRiskFactorWithMessage)
def create_risk(request: schemas.RiskBase, db: Session = Depends(get_db),current_user:schemas.User=Depends(oauth2.get_current_user)):
    # Create a new request object with the authenticated user's ID from JWT
    updated_request = request.model_copy(update={'user_id': current_user.id})
    return riskRepo.create(updated_request,db)

@router.get("/",response_model=schemas.RiskShow)
def get_risk(db:Session=Depends(get_db),current_user:schemas.User=Depends(oauth2.get_current_user)):
    return riskRepo.show(current_user.id,db)

@router.put("/",response_model=schemas.RiskShow)
def update_risk(request:schemas.RiskBase,db:Session=Depends(get_db),current_user:schemas.User=Depends(oauth2.get_current_user)):
    # Create a new request object with the authenticated user's ID from JWT
    updated_request = request.model_copy(update={'user_id': current_user.id})
    return {"message": "Risk updated successfully", "user": riskRepo.update(current_user.id,updated_request,db)}

@router.delete("/")
def delete_risk(db:Session=Depends(get_db),current_user:schemas.User=Depends(oauth2.get_current_user)):
    riskRepo.delete(current_user.id,db)
    return {"message": f"Risks of {current_user.id} User deleted successfully!"}

