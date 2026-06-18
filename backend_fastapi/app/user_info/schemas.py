from pydantic import BaseModel, Field
from typing import List, Dict, Any

class HealthDataUpdate(BaseModel):
    user_id: int = Field(..., description="ID của người dùng cần cập nhật", gt=0)
    weight: float = Field(..., description="Cân nặng mới tính bằng kg", gt=0)
    pre_existing_conditions: List[str] = Field(default=[], description="Danh sách bệnh nền")
    symptoms: List[str] = Field(default=[], description="Danh sách triệu chứng")
    allergies: str = Field(default=[], description="Tình trạng dị ứng (có thể để trống)")

class UserHealthApiResponse(BaseModel):
    success: bool
    message: str
    # Dữ liệu bên trong kết quả trả về sẽ tự động map chuẩn với dictionary của tầng Service
    results: Dict[str, Any] = Field(..., description="Dữ liệu sức khỏe sau khi cập nhật thành công (chứa trường height)")