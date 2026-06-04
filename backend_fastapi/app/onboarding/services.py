from fastapi import HTTPException, status

from sqlalchemy.orm import Session
from datetime import date
from . import models
from .schemas import OnboardingInput

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
    if not payload.condition_ids or len(payload.condition_ids) == 0:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Bạn bắt buộc phải chọn ít nhất một bệnh nền."
        )
    calculated_age = _calculate_age(payload.date_of_birth)
    calculated_bmi = _calculate_bmi(payload.height, payload.weight)
    
    # 1. Tìm xem User này đã từng tạo Profile chưa
    profile = db.query(models.PatientProfile).filter(models.PatientProfile.user_id == payload.user_id).first()

    if profile:
        # 👉 Cập nhật (UPDATE) nếu đã có profile
        profile.Age = calculated_age
        profile.weight = payload.weight
        profile.height = payload.height
        profile.target_low = payload.target_low
        profile.target_high = payload.target_high
        profile.allergies = payload.allergies
        
        # 🗑️ Xóa dữ liệu cũ trực tiếp trong bảng liên kết để tránh lỗi quan hệ bộ nhớ
        db.query(models.PatientCondition).filter(models.PatientCondition.patient_profile_id == profile.id).delete(synchronize_session=False)
        db.query(models.PatientSymptom).filter(models.PatientSymptom.patient_profile_id == profile.id).delete(synchronize_session=False)
    else:
        # 👉 Thêm mới (INSERT) nếu chưa có profile
        profile = models.PatientProfile(
            user_id=payload.user_id,
            Age=calculated_age,
            weight=payload.weight,
            height=payload.height,
            target_low=payload.target_low,
            target_high=payload.target_high,
            allergies=payload.allergies
        )
        db.add(profile)
        db.flush()  # Lấy profile.id mới sinh ra

    # 2. Thêm danh sách Bệnh nền mới (Ghi trực tiếp vào bảng liên kết)
    if payload.condition_ids:
        for cond_id in payload.condition_ids:
            patient_condition = models.PatientCondition(
                patient_profile_id=profile.id,
                condition_id=cond_id
            )
            db.add(patient_condition)

    # 3. Thêm danh sách Triệu chứng mới (Ghi trực tiếp vào bảng liên kết)
    if payload.symptom_ids:
        for symp_id in payload.symptom_ids:
            patient_symptom = models.PatientSymptom(
                patient_profile_id=profile.id,
                symptom_id=symp_id
            )
            db.add(patient_symptom)

    db.commit()
    return profile.id, calculated_age, calculated_bmi


# =========================================================================
# 🌟 ĐÃ SỬA: 2 HÀM LẤY DỮ LIỆU ĐÚNG TÊN MODEL TRONG DICTIONARY
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