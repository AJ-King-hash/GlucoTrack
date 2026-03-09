from sqlalchemy.orm import Session
import models
from fastapi import HTTPException,status
from typing import Optional

def get_all(
    user_id:int,
    db:Session,
    page: int = 1,
    limit: int = 10,
    search: Optional[str] = None,
    sort_by: str = "analysed_at",
    sort_order: str = "desc",
    risk_filter: Optional[str] = None
):
    """Get all analysis with pagination, search, and filtering support."""
    query = db.query(models.PrevAnalyse).where(models.PrevAnalyse.user_id == user_id)
    
    # Join with Meal to search by meal name/description
    query = query.join(models.Meal, models.PrevAnalyse.meal_id == models.Meal.id)
    
    # Apply search filter (search in meal name or description)
    if search:
        search_term = f"%{search}%"
        query = query.filter(
            (models.Meal.name.ilike(search_term)) | 
            (models.Meal.description.ilike(search_term))
        )
    
    # Apply risk filter
    if risk_filter:
        query = query.filter(models.PrevAnalyse.risk_result.ilike(f"%{risk_filter}%"))
    
    # Apply sorting
    sort_column = getattr(models.PrevAnalyse, sort_by, models.PrevAnalyse.analysed_at)
    if sort_order == "desc":
        query = query.order_by(sort_column.desc())
    else:
        query = query.order_by(sort_column.asc())
    
    # Apply pagination
    offset = (page - 1) * limit
    analysis = query.offset(offset).limit(limit).all()
    
    return analysis

def delete(id:int,db:Session):
    analyse=db.query(models.PrevAnalyse).filter(models.PrevAnalyse.id==id).first()
    if not analyse:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND,detail=f"analyse with the id {id} is not available")
    db.delete(analyse)
    db.commit()
