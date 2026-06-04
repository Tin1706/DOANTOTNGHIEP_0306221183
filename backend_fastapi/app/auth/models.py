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

class OTPCodeModel(Base):
    __tablename__ = "otp_codes"

    id = Column(Integer, primary_key=True, autoincrement=True)
    # Khóa ngoại liên kết trực tiếp với id của bảng users đúng như ký hiệu MUL trong ảnh
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    otp_code = Column(String(6), nullable=False)
    # Khớp chuẩn kiểu tinyint trong MySQL Workbench (0: Chưa dùng, 1: Đã dùng)
    is_used = Column(SmallInteger, default=0)
    created_at = Column(DateTime, default=datetime.datetime.utcnow, nullable=False)
    expires_at = Column(DateTime, nullable=False)