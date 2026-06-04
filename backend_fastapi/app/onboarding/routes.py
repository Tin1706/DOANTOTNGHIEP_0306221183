from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from app.database import get_db
from .schemas import OnboardingInput, ApiResponseOnboarding
from . import services

router = APIRouter(prefix="/api/onboarding", tags=["Patient Onboarding"])

@router.post(
    "/submit", 
    response_model=ApiResponseOnboarding, 
    status_code=status.HTTP_201_CREATED
)
def submit_onboarding(payload: OnboardingInput, db: Session = Depends(get_db)):
    try:
        profile_id, patient_age, patient_bmi = services.process_patient_onboarding(db, payload)
        db.commit()
        
        return ApiResponseOnboarding(
            success=True,
            message="Khởi tạo hồ sơ bệnh nhân thành công!",
            data={
                "patient_profile_id": profile_id,
                "age": patient_age,
                "bmi": patient_bmi
            }
        )
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=f"Lỗi hệ thống onboarding: {str(e)}")

# 🌟 THÊM ENDPOINT LẤY TRIỆU CHỨNG TẠI ONBOARDING
@router.get("/symptoms")
def get_symptoms(db: Session = Depends(get_db)):
    """API lấy danh sách các triệu chứng để hiển thị lúc Onboarding"""
    try:
        return services.get_all_symptoms(db)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Lỗi lấy dữ liệu triệu chứng: {str(e)}")

# 🌟 THÊM ENDPOINT LẤY BỆNH NỀN TẠI ONBOARDING
@router.get("/conditions")
def get_conditions(db: Session = Depends(get_db)):
    """API lấy danh sách các bệnh nền để hiển thị lúc Onboarding"""
    try:
        return services.get_all_conditions(db)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Lỗi lấy dữ liệu bệnh lý: {str(e)}")