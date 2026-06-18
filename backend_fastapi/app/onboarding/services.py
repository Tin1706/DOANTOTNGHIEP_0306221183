from fastapi import HTTPException, status
from .models import PatientProfile
from sqlalchemy.orm import Session
from datetime import date
from . import models
from .schemas import OnboardingInput
import json
def _calculate_age(born: date) -> int:
    today = date.today()
    age = today.year - born.year
    if (today.month, today.day) < (born.month, born.day):
        age -= 1
    return age

def _calculate_bmi(height_cm: int, weight_kg: int) -> float:
    height_m = height_cm / 100.0
    return round(weight_kg / (height_m ** 2), 2)


def process_patient_onboarding(db: Session, payload: OnboardingInput):
    # 1. Tìm hoặc tạo mới hồ sơ dựa trên user_id
    profile = db.query(PatientProfile).filter(PatientProfile.user_id == payload.user_id).first()
    if not profile:
        profile = PatientProfile(user_id=payload.user_id)
        db.add(profile)
    
    # 2. Tính tuổi
    patient_age = None
    if payload.date_of_birth:
        dob = date.fromisoformat(str(payload.date_of_birth)) if isinstance(payload.date_of_birth, str) else payload.date_of_birth
        today = date.today()
        patient_age = today.year - dob.year - ((today.month, today.day) < (dob.month, dob.day))
        profile.Age = patient_age

    # 3. Gán các chỉ số cơ bản
    profile.height = payload.height
    profile.weight = payload.weight
    profile.allergies = payload.allergies if payload.allergies else "Không có"
    
    # =========================================================================
    # 🚀 FIX LỖI TARGET_LOW CANNOT BE NULL: Gán giá trị mặc định chuẩn DB của bác
    # =========================================================================
    profile.target_low = 70   # Gán mặc định là 70 giống các bản ghi cũ của bác
    profile.target_high = 180 # Gán mặc định là 180 giống các bản ghi cũ của bác
    # =========================================================================

    # 4. Ép mảng text thành chuỗi JSON để đẩy xuống DB (Đoạn này bác viết ngon rồi)
    if hasattr(payload, 'pre_existing_conditions') and payload.pre_existing_conditions:
        profile.pre_existing_conditions = json.dumps(payload.pre_existing_conditions, ensure_ascii=False)
    else:
        profile.pre_existing_conditions = json.dumps([], ensure_ascii=False)
        
    if hasattr(payload, 'symptoms') and payload.symptoms:
        profile.symptoms = json.dumps(payload.symptoms, ensure_ascii=False)
    else:
        profile.symptoms = json.dumps([], ensure_ascii=False)

    # 5. Tính toán BMI trả về
    patient_bmi = round(payload.weight / ((payload.height / 100) ** 2), 2) if payload.height else 0
    
    db.flush()
    return profile.id, patient_age, patient_bmi
# =========================================================================

def get_all_conditions(db: Session):
    """
    Hàm lấy toàn bộ danh sách bệnh lý từ bảng từ điển
    """
    try:
        # Đã sửa từ models.Condition thành models.ConditionsDictionary khớp với file models.py
        return db.query(models.ConditionsDictionary).all()
    except Exception as e:
        print(f"🚨 [LỖI DATABASE get_all_conditions]: {e}")
        raise e


def get_all_symptoms(db: Session):
    """
    Hàm lấy toàn bộ danh sách triệu chứng từ bảng từ điển
    """
    try:
        # Đã sửa từ models.Symptom thành models.SymptomDictionary khớp với file models.py
        return db.query(models.SymptomDictionary).all()
    except Exception as e:
        print(f"🚨 [LỖI DATABASE get_all_symptoms]: {e}")
        raise e