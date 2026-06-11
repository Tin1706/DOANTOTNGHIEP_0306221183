from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from app.database import get_db
from .schemas import MedicationListApiResponse
from . import services

router = APIRouter(prefix="/api/diabetes-medications", tags=["Diabetes Medications"])

@router.get(
    "/all", 
    response_model=MedicationListApiResponse, 
    status_code=status.HTTP_200_OK,
    summary="Liệt kê toàn bộ danh sách thuốc tiểu đường trong từ điển"
)
def get_medications(db: Session = Depends(get_db)):
    try:
        # Lấy mảng danh sách thuốc từ tầng service
        medications = services.get_all_diabetes_medications(db)
        
        return MedicationListApiResponse(
            success=True,
            message="Lấy danh sách thuốc thành công!",
            data=medications # Gửi danh sách thuốc này về cho Flutter đổ lên giao diện
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, 
            detail=f"Lỗi hệ thống khi lấy danh sách thuốc: {str(e)}"
        )