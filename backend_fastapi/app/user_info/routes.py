import json  # Sửa lỗi: "json" is not defined
from datetime import datetime, timedelta  # Sửa lỗi: "datetime" / "timedelta" is not defined
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import func  # Sửa lỗi: "func" is not defined
from sqlalchemy.orm import Session

# 🚀 IMPORT CÁC MODEL DATABASE THỰC TẾ CỦA BÁC:
# Bác lưu ý: Hãy sửa lại "app.models" thành đúng đường dẫn chứa file Model trong dự án của bác nhé!
from app.database import get_db
from app.onboarding.models import PatientProfile, ConditionsDictionary, SymptomDictionary
from app.auth.models import UserModel
from app.health_metrics.models import HealthMetricsLog
from app.user_info.schemas import HealthDataUpdate, UserHealthApiResponse

# Khởi tạo router giống hệt module mẫu của bạn
router = APIRouter(prefix="/api/user-health", tags=["User Health Information"])

@router.get("/detail/{user_id}")
def get_patient_comprehensive_info(user_id: int, db: Session = Depends(get_db)):
    # 1. Lấy Họ tên, Email từ bảng User
    user_account = db.query(UserModel).filter(UserModel.id == user_id).first()
    if not user_account:
        raise HTTPException(status_code=404, detail="Không tìm thấy tài khoản người dùng")

    # 2. Lấy Tuổi, Chiều cao, Cân nặng, Bệnh nền, Triệu chứng, Dị ứng từ bảng patient_profiles
    profile = db.query(PatientProfile).filter(PatientProfile.user_id == user_id).first()
    if not profile:
        raise HTTPException(status_code=404, detail="Không tìm thấy hồ sơ sức khỏe bệnh nhân")

    # 3. Tính toán các chỉ số đo trung bình trong 7 ngày gần nhất từ bảng health_metrics
    seven_days_ago = datetime.utcnow() - timedelta(days=7)
    avg_metrics = db.query(
        func.avg(HealthMetricsLog.blood_sugar).label("avg_sugar"),
        func.avg(HealthMetricsLog.systolic_bp).label("avg_systolic"),
        func.avg(HealthMetricsLog.diastolic_bp).label("avg_diastolic"),
        func.avg(HealthMetricsLog.heart_rate).label("avg_heart")
    ).filter(
        HealthMetricsLog.user_id == user_id,
        HealthMetricsLog.logged_at >= seven_days_ago
    ).first()

    # 4. Gộp toàn bộ dữ liệu trả về cho Flutter hiển thị lên UI
    return {
        "success": True,
        "data": {
            # Thông tin tài khoản định danh
            "full_name": user_account.full_name, 
            "email": user_account.email,         
            "age": profile.Age,                  
            
            # Thông tin sinh học & Hồ sơ bệnh nền từ bảng chính
            "height": profile.height,
            "weight": profile.weight,
            "allergies": profile.allergies if profile.allergies else "Không có",
            "pre_existing_conditions": profile.pre_existing_conditions if profile.pre_existing_conditions else "[]",
            "symptoms": profile.symptoms if profile.symptoms else "[]",
            
            # Khối chỉ số đo trung bình tính toán thực tế trong 7 ngày
            "avg_blood_sugar": round(avg_metrics.avg_sugar, 2) if avg_metrics.avg_sugar else None,
            "avg_systolic_bp": round(avg_metrics.avg_systolic, 2) if avg_metrics.avg_systolic else None,
            "avg_diastolic_bp": round(avg_metrics.avg_diastolic, 2) if avg_metrics.avg_diastolic else None,
            "avg_heart_rate": round(avg_metrics.avg_heart, 2) if avg_metrics.avg_heart else None
        }
    }


# =========================================================================
# 🔵 HÀM 2: CẬP NHẬT CHỈ SỐ & BẮT BUỘC KHỚP TỪ ĐIỂN (POST)
# =========================================================================
@router.post("/update", response_model=UserHealthApiResponse)
def update_user_health_strict(request: HealthDataUpdate, db: Session = Depends(get_db)):
    profile = db.query(PatientProfile).filter(PatientProfile.user_id == request.user_id).first()
    if not profile:
        raise HTTPException(status_code=404, detail="Hồ sơ bệnh nhân không tồn tại")

    # 🌟 KIỂM TRA TỪ ĐIỂN: Bắt buộc chữ bệnh nền gửi lên phải khớp với bảng từ điển
    # 🌟 KIỂM TRA TỪ ĐIỂN BỆNH NỀN (Đặt tại routes.py)
    for cond_name in request.pre_existing_conditions:
        # Sửa .name THÀNH .condition_name cho khớp với model của bác
        exists = db.query(ConditionsDictionary).filter(ConditionsDictionary.condition_name == cond_name.strip()).first()
        if not exists:
            raise HTTPException(
                status_code=400, 
                detail=f"Bệnh nền '{cond_name}' không hợp lệ hoặc không có trong từ điển!"
            )

    # 🌟 KIỂM TRA TỪ ĐIỂN TRIỆU CHỨNG (Đặt tại routes.py)
    for sym_name in request.symptoms:
        # Sửa .name THÀNH .symptom_name cho khớp với model của bác
        exists = db.query(SymptomDictionary).filter(SymptomDictionary.symptom_name == sym_name.strip()).first()
        if not exists:
            raise HTTPException(
                status_code=400, 
                detail=f"Triệu chứng '{sym_name}' không hợp lệ hoặc không có trong từ điển!"
            )

    try:
        # Khi mọi thứ hợp lệ -> Lưu đè thẳng vào bảng duy nhất patient_profiles
        profile.weight = request.weight
        profile.allergies = request.allergies
        
        # Ép mảng chữ chuẩn từ điển thành chuỗi JSON Text để lưu khít vào MySQL
        profile.pre_existing_conditions = json.dumps(request.pre_existing_conditions, ensure_ascii=False)
        profile.symptoms = json.dumps(request.symptoms, ensure_ascii=False)
        
        db.commit()
        db.refresh(profile)
        
        # Trả về kết quả đúng cấu trúc mẫu Dict[str, Any] mà bác yêu cầu
        return {
            "success": True,
            "message": "Cập nhật thông tin sức khỏe chuẩn từ điển thành công!",
            "results": {
                "user_id": profile.user_id,
                "height": profile.height, 
                "weight": profile.weight,
                "allergies": profile.allergies,
                "pre_existing_conditions": request.pre_existing_conditions,
                "symptoms": request.symptoms
            }
        }
        
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=f"Lỗi DB: {str(e)}")