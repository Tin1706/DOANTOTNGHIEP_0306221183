import json
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from app.database import get_db
from .schemas import OnboardingInput, ApiResponseOnboarding
from . import services

router = APIRouter(prefix="/api/onboarding", tags=["Patient Onboarding"])

# =========================================================================
# 🟢 1. API SUBMIT ONBOARDING (Lưu trực tiếp mảng chữ dạng JSON String)
# =========================================================================
@router.post(
    "/submit", 
    response_model=ApiResponseOnboarding, 
    status_code=status.HTTP_201_CREATED
)
def submit_onboarding(payload: OnboardingInput, db: Session = Depends(get_db)):
    try:
        # Gọi services xử lý (Trong dịch vụ, bác nhớ gán trực tiếp chuỗi json vào model)
        profile_id, patient_age, patient_bmi = services.process_patient_onboarding(db, payload)
        db.commit()
        
        return ApiResponseOnboarding(
            success=True,
            message="Khởi tạo hồ sơ bệnh nhân thành công!",
            data={
                "patient_profile_id": profile_id,
                "Age": patient_age,
                "bmi": patient_bmi
            }
        )
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=f"Lỗi hệ thống onboarding: {str(e)}")


# =========================================================================
# 🌟 2. API LẤY DANH SÁCH TỪ ĐIỂN TRIỆU CHỨNG
# =========================================================================
@router.get("/symptoms")
def get_symptoms(db: Session = Depends(get_db)):
    """API lấy danh sách các triệu chứng để hiển thị lúc Onboarding"""
    try:
        return services.get_all_symptoms(db)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Lỗi lấy dữ liệu triệu chứng: {str(e)}")


# =========================================================================
# 🌟 3. API LẤY DANH SÁCH TỪ ĐIỂN BỆNH NỀN
# =========================================================================
@router.get("/conditions")
def get_conditions(db: Session = Depends(get_db)):
    """API lấy danh sách các bệnh nền để hiển thị lúc Onboarding"""
    try:
        return services.get_all_conditions(db)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Lỗi lấy dữ liệu bệnh lý: {str(e)}")


# =========================================================================
# 🚀 4. API LẤY CHI TIẾT THÔNG TIN ONBOARDING CỦA MỘT BỆNH NHÂN THEO USER_ID
# =========================================================================
@router.get("/{user_id}")
def get_patient_onboarding_detail(user_id: int, db: Session = Depends(get_db)):
    """API bốc dữ liệu cá nhân, bệnh nền, triệu chứng từ dạng JSON trong MySQL ra chuỗi cho Flutter"""
    try:
        # Import duy nhất class bảng chính
        from .models import PatientProfile

        # Truy vấn thẳng thông tin từ bảng gốc
        profile = db.query(
            PatientProfile.id,
            PatientProfile.user_id,
            PatientProfile.Age,
            PatientProfile.weight,
            PatientProfile.height,
            PatientProfile.allergies,
            PatientProfile.pre_existing_conditions, # 🌟 ĐÃ FIX: Gọi chuẩn tên cột pre_existing_conditions
            PatientProfile.symptoms                 # Đọc ô Text JSON triệu chứng
        ).filter(PatientProfile.user_id == user_id).first()
        
        if not profile:
            raise HTTPException(status_code=404, detail="Không tìm thấy hồ sơ của bệnh nhân này.")

        # 🧩 Giải mã chuỗi JSON Bệnh nền thành mảng chữ, sau đó gộp lại bằng dấu phẩy
        try:
            conditions_list = json.loads(profile.pre_existing_conditions) if profile.pre_existing_conditions else []
            if isinstance(conditions_list, list) and conditions_list:
                conditions_str = ", ".join(conditions_list)
            else:
                conditions_str = "Không có"
        except Exception:
            conditions_str = profile.pre_existing_conditions if profile.pre_existing_conditions else "Không có"

        # 🧩 Giải mã chuỗi JSON Triệu chứng thành mảng chữ, sau đó gộp lại bằng dấu phẩy
        try:
            symptoms_list = json.loads(profile.symptoms) if profile.symptoms else []
            if isinstance(symptoms_list, list) and symptoms_list:
                symptoms_str = ", ".join(symptoms_list)
            else:
                symptoms_str = "Không có"
        except Exception:
            symptoms_str = profile.symptoms if profile.symptoms else "Không có"

        # Trả toàn bộ cục dữ liệu sạch về cho Flutter bốc tách hiển thị giao diện
        return {
            "id": profile.id,
            "user_id": profile.user_id,
            "Age": profile.Age if profile.Age else "Chưa cập nhật",            
            "weight": profile.weight,
            "height": profile.height,
            "allergies": profile.allergies if profile.allergies else "Không có",
            "conditions": conditions_str,  # Trả về chuỗi tên bệnh nền: "Bệnh lý bàn chân, Béo phì"
            "symptoms": symptoms_str       # Trả về chuỗi tên triệu chứng: "Mất thính lực, Đau đầu"
        }
    except HTTPException as he:
        raise he
    except Exception as e:
        print("❌ LỖI HỆ THỐNG TRUY VẤN JSON:", str(e))
        raise HTTPException(status_code=500, detail=f"Lỗi hệ thống: {str(e)}")