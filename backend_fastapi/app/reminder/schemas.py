from pydantic import BaseModel
from typing import List, Optional

# Cấu trúc của 1 loại thuốc dựa theo database của bạn
class MedicationResponse(BaseModel):
    id: int
    medication_name: str
    medication_category: Optional[str] = None

    class Config:
        from_attributes = True # Cho phép ép kiểu trực tiếp từ SQLAlchemy model

# Cấu trúc API Response trả về một DANH SÁCH (Mảng dữ liệu)
class MedicationListApiResponse(BaseModel):
    success: bool
    message: str
    data: List[MedicationResponse] # Trả về mảng danh sách thuốc