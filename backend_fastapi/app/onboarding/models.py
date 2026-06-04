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


# =========================================================================
# 2. CÁC BẢNG PHỤ LIÊN KẾT (RELATIONAL TABLES)
# =========================================================================

# Bảng phụ 1: Liên kết nhiều - nhiều giữa Hồ sơ và Bệnh nền (Cố định lúc Onboarding)
class PatientCondition(Base):
    __tablename__ = "patient_conditions"

    patient_profile_id = Column(Integer, ForeignKey("patient_profiles.id", ondelete="CASCADE"), primary_key=True)
    condition_id = Column(Integer, ForeignKey("conditions_dictionary.id", ondelete="CASCADE"), primary_key=True)


# Bảng phụ 2: Nhật ký lưu triệu chứng phát sinh (Thay đổi theo từng lần đo hằng ngày)
class PatientSymptom(Base):
    __tablename__ = "patient_symptoms"

    # 🌟 Dùng id riêng làm khóa chính tự tăng để một người có thể lưu lại 
    # cùng 1 triệu chứng (ví dụ: Chóng mặt) vào nhiều ngày khác nhau mà không bị lỗi DB
    id = Column(Integer, primary_key=True, autoincrement=True)
    
    patient_profile_id = Column(Integer, ForeignKey("patient_profiles.id", ondelete="CASCADE"), nullable=False)
    symptom_id = Column(Integer, ForeignKey("symptoms_dictionary.id", ondelete="CASCADE"), nullable=False)
    recorded_at = Column(DateTime, default=datetime.utcnow, nullable=False)


# =========================================================================
# 3. BẢNG CHÍNH (MAIN TABLE)
# =========================================================================

# Hồ sơ bệnh nhân (Thông tin cố định lưu từ Onboarding)
class PatientProfile(Base):
    __tablename__ = "patient_profiles"

    id = Column(Integer, primary_key=True, autoincrement=True)
    user_id = Column(Integer, nullable=False, index=True, unique=True)
    Age = Column(Integer, nullable=False)
    weight = Column(Integer, nullable=False)
    height = Column(Integer, nullable=False)
    target_low = Column(Integer, nullable=True, default=70)
    target_high = Column(Integer, nullable=True, default=180)
    allergies = Column(Text, nullable=True)

    # Thiết lập mối quan hệ phối hợp dữ liệu công nghệ ORM
    conditions = relationship("PatientCondition", backref="profile", cascade="all, delete-orphan")
    symptoms = relationship("PatientSymptom", backref="profile", cascade="all, delete-orphan")