from sqlalchemy import Column, Integer, Text, DateTime, ForeignKey, String
from sqlalchemy.orm import relationship
from app.database import Base
from datetime import datetime

# =========================================================================
# 1. CÁC BẢNG TỪ ĐIỂN (DICTIONARIES)
# =========================================================================

class SymptomDictionary(Base):
    __tablename__ = "symptoms_dictionary"

    id = Column(Integer, primary_key=True, autoincrement=True)
    symptom_name = Column(String(255), nullable=False)
    # 🌟 Thêm trường type để phân loại (Ví dụ: "ha_duong_huyet", "tang_duong_huyet", "on_dinh")
    type = Column(String(100), nullable=True) 

class ConditionsDictionary(Base):
    __tablename__ = "conditions_dictionary"

    id = Column(Integer, primary_key=True, autoincrement=True)
    condition_name = Column(String(255), nullable=False)
class PatientCondition(Base):
    __tablename__ = "patient_conditions"

    id = Column(Integer, primary_key=True, index=True)
    # 🔥 ĐÃ SỬA: Đổi từ patient_id thành patient_profile_id cho khớp với API Onboarding của bác
    patient_profile_id = Column(Integer, ForeignKey("patient_profiles.id", ondelete="CASCADE"))
    condition_id = Column(Integer, ForeignKey("conditions_dictionary.id", ondelete="CASCADE"))

class PatientSymptom(Base):
    __tablename__ = "patient_symptoms"

    id = Column(Integer, primary_key=True, index=True)
    # 🔥 ĐÃ SỬA: Đổi tương tự để tí nữa luồng triệu chứng không bị dính lỗi này
    patient_profile_id = Column(Integer, ForeignKey("patient_profiles.id", ondelete="CASCADE"))
    symptom_id = Column(Integer, ForeignKey("symptoms_dictionary.id", ondelete="CASCADE"))
class PatientProfile(Base): 
    __tablename__ = "patient_profiles" # <-- Thêm chữ 's' cho đúng tên bảng trong ảnh
    __table_args__ = {'extend_existing': True}
    id = Column(Integer, primary_key=True, index=True) # Khóa chính AI PK trong ảnh
    user_id = Column(Integer, index=True)
    Age = Column(Integer)
    target_low = Column(Integer)
    target_high = Column(Integer)
    
    # Các trường cần cập nhật
    weight = Column(Integer, nullable=False) # Trong ảnh của bạn đang để kiểu int
    height = Column(Integer, nullable=False, default=170) # Đổi height_cm thành height kiểu int
    allergies = Column(Text) # Trong ảnh của bạn là kiểu text

    # 2 cột vừa chạy lệnh ALTER TABLE để thêm ở Bước 1
    pre_existing_conditions = Column('pre_existing_conditions', Text, nullable=True)
    symptoms = Column('symptoms', Text, nullable=True)