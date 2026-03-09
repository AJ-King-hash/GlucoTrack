from fastapi import APIRouter,Depends,HTTPException,status,Query
import schemas
from sqlalchemy.orm import Session
from database import get_db
import models
import oauth2
from typing import List, Optional
from repositories import AnalyseRepo
# has diabete:
#1- random sugar after 2h if more than 200mg/dl has diabete (max:600)
#2-if fast if more than 126 mg/dl  has diabetes  (max:600)
#mean:126 in percen: 21% -> has diabetes
#3-HBA1c:Himoglobin blood sugar more than 6.5% has diabetes
# if we want it normal (blood pressure [130/170] to [140/80])


# GI: Glacymic Index:
# GL=(GI*Carbohydrates)/100
# [0] no change 
# [1-55] low (calen braw-homs-apple-milk) can eat sugar if just low
# [56-69] Medium (maccaroni-rice-sweet potatoe)
# [70-100] Hard (White Bread-sweet drinks- corn flex)

# GL:Glacymic Load for the gluco detect (IMPORTANT)
# [0] no Change 
# [1-10] Low  can eat sugar if just low
# [11-19] Medium
# [20-100] High

router=APIRouter(
    prefix="/analyse",
    tags=["Gluco Analysis"]
)


@router.get("/all/",response_model=List[schemas.AnalyseShow])
def get_all_analysis(
    db:Session=Depends(get_db),
    current_user:schemas.User=Depends(oauth2.get_current_user),
    page: int = Query(1, ge=1, description="Page number"),
    limit: int = Query(10, ge=1, le=100, description="Items per page"),
    search: Optional[str] = Query(None, description="Search by meal name or description"),
    sort_by: Optional[str] = Query("analysed_at", description="Sort field: analysed_at, gluco_percent, risk_result"),
    sort_order: str = Query("desc", regex="^(asc|desc)$", description="Sort order: asc or desc"),
    risk_filter: Optional[str] = Query(None, description="Filter by risk result: Low, Medium, High")
):
    """Get all analysis with pagination, search, and filtering support."""
    return AnalyseRepo.get_all(
        current_user.id, 
        db, 
        page=page, 
        limit=limit,
        search=search,
        sort_by=sort_by,
        sort_order=sort_order,
        risk_filter=risk_filter
    )


@router.delete("/{id}")
def delete_analyse(id:int,db:Session=Depends(get_db)):
    AnalyseRepo.delete(id,db)
    return {"message": f"Analyse {id} deleted successfully!"}


@router.get("/count/")
def get_analysis_count(
    db:Session=Depends(get_db),
    current_user:schemas.User=Depends(oauth2.get_current_user)
):
    """Get total count of analysis for pagination info."""
    count = db.query(models.PrevAnalyse).filter(models.PrevAnalyse.user_id == current_user.id).count()
    return {"total": count}
