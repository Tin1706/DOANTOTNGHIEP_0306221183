import json  
from sqlalchemy.orm import Session

def update_user_health_record(db: Session, data):
    # 🌟 Giấu dòng import này vào ĐÂY để bẻ gãy vòng lặp import chéo giữa các file
    from . import PatientProfile  
    
    profile = db.query(PatientProfile).filter(PatientProfile.user_id == data.user_id).first()
    if not profile:
        raise ValueError(f"Không tìm thấy hồ sơ sức khỏe cho User ID: {data.user_id}")
    
    profile.weight = data.weight
    profile.allergies = data.allergies

    # Xử lý ép mảng tránh lỗi toán hạng MySQL
    if isinstance(data.pre_existing_conditions, list):
        profile.pre_existing_conditions = json.dumps(data.pre_existing_conditions, ensure_ascii=False)
    else:
        profile.pre_existing_conditions = data.pre_existing_conditions

    if isinstance(data.symptoms, list):
        profile.symptoms = json.dumps(data.symptoms, ensure_ascii=False)
    else:
        profile.symptoms = data.symptoms

    db.commit()
    db.refresh(profile)
    return profile