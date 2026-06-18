from sqlalchemy.orm import Session, joinedload
from datetime import datetime
from typing import Optional
from . import models

# ==========================================
# 1. TỪ ĐIỂN THUỐC (MedicationDictionary)
# ==========================================

def get_all_diabetes_medications(db: Session):
    """Quét toàn bộ danh mục thuốc sắp xếp theo tên từ A-Z"""
    return db.query(models.MedicationDictionary).order_by(models.MedicationDictionary.medication_name.asc()).all()


# ==========================================
# 2. LỊCH NHẮC NHỞ (Reminders)
# ==========================================

def get_active_reminders_by_user(db: Session, user_id: int):
    """
    Lấy danh sách nhắc nhở kèm theo thông tin tên thuốc từ bảng từ điển
    Sử dụng joinedload để tối ưu hiệu năng truy vấn liên kết bảng
    """
    return db.query(models.Reminder)\
             .options(joinedload(models.Reminder.medication))\
             .filter(
                 models.Reminder.user_id == user_id,
                 models.Reminder.is_active == 1,
                 models.Reminder.is_deleted == 0
             ).all()


# 🟢 ĐÃ SỬA: medication_dictionary_id và dosage được đổi thành Optional để chấp nhận None từ Flutter gửi lên
def create_reminder(db: Session, user_id: int, medication_dictionary_id: Optional[int], title: str, dosage: Optional[str], reminder_time_str: str):
    """Tạo mới lịch nhắc nhở (uống thuốc hoặc nhắc đo đường huyết tự do)"""
    if len(reminder_time_str) == 5:
        t = datetime.strptime(reminder_time_str, "%H:%M").time()
    else:
        t = datetime.strptime(reminder_time_str, "%H:%M:%S").time()
        
    new_reminder = models.Reminder(
        user_id=user_id,
        medication_dictionary_id=medication_dictionary_id, # Nhận None mượt mà nếu là nhắc đo đường huyết
        title=title,
        dosage=dosage,                                     # Nhận None hoặc chuỗi mặc định mượt mà
        reminder_time=t,
        is_active=1,
        is_deleted=0
    )
    db.add(new_reminder)
    db.commit()
    db.refresh(new_reminder)
    return new_reminder


# 🟢 ĐÃ SỬA: bổ sung Optional[str] cho dosage khi cập nhật nhắc nhở
def update_reminder(db: Session, reminder_id: int, title: str, dosage: Optional[str], reminder_time_str: str, is_active: int):
    """Cập nhật thông tin cấu hình lịch nhắc nhở"""
    reminder = db.query(models.Reminder).filter(models.Reminder.id == reminder_id, models.Reminder.is_deleted == 0).first()
    if not reminder:
        return None
        
    if len(reminder_time_str) == 5:
        t = datetime.strptime(reminder_time_str, "%H:%M").time()
    else:
        t = datetime.strptime(reminder_time_str, "%H:%M:%S").time()
        
    reminder.title = title
    reminder.dosage = dosage
    reminder.reminder_time = t
    reminder.is_active = is_active
    
    db.commit()
    db.refresh(reminder)
    return reminder


def delete_reminder(db: Session, reminder_id: int):
    """Xóa mềm lịch nhắc nhở"""
    reminder = db.query(models.Reminder).filter(models.Reminder.id == reminder_id).first()
    if not reminder:
        return False
    reminder.is_deleted = 1
    db.commit()
    return True


# ==========================================
# 3. NHẬT KÝ SỬ DỤNG THUỐC (MedicationLogs)
# ==========================================

def create_medication_log(db: Session, user_id: int, reminder_id: int, status: str, notes: str = None):
    """Ghi nhận log thực tế khi người dùng bấm tương tác trên màn hình thông báo"""
    reminder = db.query(models.Reminder).filter(models.Reminder.id == reminder_id).first()
    if not reminder:
        return None
        
    new_log = models.MedicationLog(
        user_id=user_id,
        medication_def_id=reminder.medication_dictionary_id, # Sẽ tự động lưu None nếu lịch này không gắn với thuốc
        reminder_id=reminder_id,
        dosage=reminder.dosage,                              # Sẽ lưu None hoặc "Thực hiện đúng giờ"
        status=status,
        notes=notes,
        logged_at=datetime.utcnow()
    )
    db.add(new_log)
    db.commit()
    db.refresh(new_log)
    return new_log