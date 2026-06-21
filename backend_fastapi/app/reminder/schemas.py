from datetime import date

from pydantic import BaseModel
from typing import List, Optional

# ==========================================
# 💊 1. SCHEMAS TỪ ĐIỂN THUỐC (MedicationDictionary)
# ==========================================

class MedicationResponse(BaseModel):
    id: int
    medication_name: str
    medication_category: Optional[str] = None

    class Config:
        from_attributes = True


class MedicationListApiResponse(BaseModel):
    success: bool
    message: str
    data: List[MedicationResponse]


# ==========================================
# ⏰ 2. SCHEMAS LỊCH NHẮC NHỞ (Reminder)
# ==========================================

class ReminderResponse(BaseModel):
    id: int
    user_id: int
    medication_dictionary_id: Optional[int] = None  # 🟢 Đổi thành Optional: Chấp nhận Null nếu là nhắc nhở tự do
    title: str
    dosage: Optional[str] = None                    # 🟢 Đổi thành Optional: Cho phép không nhập liều lượng
    reminder_time: str  
    is_active: int
    medication: Optional[MedicationResponse] = None  

    class Config:
        from_attributes = True


class ReminderListApiResponse(BaseModel):
    success: bool
    message: str
    data: List[ReminderResponse]


# Request nhận từ Flutter khi người dùng bấm "Xác nhận" tạo mới
class ReminderCreateRequest(BaseModel):
    user_id: int
    medication_dictionary_id: Optional[int] = None  # 🟢 Sửa thành Optional để nhận được giá trị null từ Flutter
    title: str
    dosage: Optional[str] = None                    # 🟢 Sửa thành Optional để không bắt buộc điền liều lượng
    reminder_time: str  


# Request nhận từ Flutter khi người dùng sửa hoặc bật/tắt công tắc
class ReminderUpdateRequest(BaseModel):
    title: str
    dosage: Optional[str] = None                    # 🟢 Sửa thành Optional để lúc cập nhật có thể xóa liều lượng hoặc để trống
    reminder_time: str
    is_active: int  

class CommonApiResponse(BaseModel):
    success: bool
    message: str
    data: Optional[dict] = None
    
