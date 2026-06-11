from sqlalchemy import Column, Integer, String, DateTime, SmallInteger, ForeignKey
from app.database import Base
import datetime

class UserModel(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, autoincrement=True)
    email = Column(String(255), unique=True, index=True, nullable=False)
    DOB = Column(DateTime, nullable=False)
    hashed_password = Column(String(255), nullable=False)
    full_name = Column(String(100), nullable=False)
    created_at = Column(DateTime, default=datetime.datetime.utcnow)

class OTPCodeModel(Base):  # Hoặc OtpCode tùy bạn đặt tên
    __tablename__ = "otp_codes"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"))
    otp_code = Column(String(6), nullable=False)
    is_used = Column(Integer, default=0)
    created_at = Column(DateTime, nullable=False)
    expires_at = Column(DateTime, nullable=False)
    
    # 🌟 BẮT BUỘC PHẢI THÊM DÒNG NÀY ĐỂ SQLALCHEMY BIẾT CỘT 'type' LÀ GÌ
    type = Column(String(50), nullable=False)