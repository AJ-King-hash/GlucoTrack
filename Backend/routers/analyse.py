from fastapi import APIRouter,Depends,HTTPException,status
import schemas
from sqlalchemy.orm import Session
from database import get_db
import models
import oauth2
from typing import List
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
def get_all_analysis(db:Session=Depends(get_db),current_user:schemas.User=Depends(oauth2.get_current_user)):
    return AnalyseRepo.get_all(current_user.id,db)


@router.delete("/{id}")
def delete_analyse(id:int,db:Session=Depends(get_db)):
    AnalyseRepo.delete(id,db)
    return {"message": f"Analyse {id} deleted successfully!"}


