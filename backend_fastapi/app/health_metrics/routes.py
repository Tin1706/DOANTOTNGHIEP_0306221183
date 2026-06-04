from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from app.database import get_db
from .schemas import HealthMetricsInput, ApiResponse
from . import services

router = APIRouter(prefix="/api/health-metrics", tags=["Health Metrics"])

@router.post(
    "/submit", 
    response_model=ApiResponse, 
    status_code=status.HTTP_201_CREATED
)
def submit_metrics(payload: HealthMetricsInput, db: Session = Depends(get_db)):
    try:
        evaluation_data = services.save_and_process_metrics(db, payload) 
        
        return ApiResponse(
            success=True,
            message="Ghi nhận chỉ số sức khỏe thành công!",
            data=evaluation_data
        )
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=f"Lỗi hệ thống: {str(e)}")