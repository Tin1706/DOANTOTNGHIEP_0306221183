import datetime
from sqlalchemy import Column, Integer, String, Text, Time, DateTime, ForeignKey, func
from sqlalchemy.dialects.mysql import TINYINT  
from sqlalchemy.orm import relationship
from app.database import Base  

# 1. Danh mục từ điển thuốc (Giữ nguyên không đổi)
class MedicationDictionary(Base):
    __tablename__ = "medication_dictionary"
    __table_args__ = {'extend_existing': True}

    id = Column(Integer, primary_key=True, autoincrement=True)
    medication_name = Column(String(255), nullable=False)    
    medication_category = Column(String(100), nullable=True)  

    reminders = relationship("Reminder", back_populates="medication")


# 2. Bảng cấu hình nhắc nhở (ĐÃ SỬA ĐỂ CHO PHÉP TRỐNG THUỐC)
class Reminder(Base):
    __tablename__ = "reminders"
    __table_args__ = {'extend_existing': True}

    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    user_id = Column(Integer, index=True) 
    
    # 🟢 1. SỬA TẠI ĐÂY: Đổi nullable=False thành True để chấp nhận nhắc nhở không có thuốc
    medication_dictionary_id = Column(Integer, ForeignKey("medication_dictionary.id"), nullable=True) 
    
    title = Column(String(255), nullable=False)       # 💡 Khuyên bác nên nâng lên String(255) thay vì 30 để gõ tiêu đề "Nhắc nhở đo đường huyết" không bị tràn cột
    
    # 🟢 2. SỬA TẠI ĐÂY: Đổi nullable=False thành True phòng khi người dùng không nhập liều lượng
    dosage = Column(String(100), nullable=True)     
    
    reminder_time = Column(Time, nullable=False)     
    
    is_active = Column(TINYINT, default=1)           
    is_deleted = Column(TINYINT, default=0)          

    medication = relationship("MedicationDictionary", back_populates="reminders")
