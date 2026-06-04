from pydantic import BaseModel
from typing import Optional, Any

class HealthMetricsInput(BaseModel):
    user_id: Any        # Chấp nhận cả chuỗi lẫn số để tránh lỗi validation
    blood_sugar: Any
    unit: str = "mg/dL" # Đặt giá trị mặc định phòng hờ Flutter không gửi lên
    systolic_bp: Any
    diastolic_bp: Any
    heart_rate: Any

class HealthMetricsResponse(BaseModel):
    blood_sugar_status: str
    blood_sugar_warning: str
    blood_pressure_warning: str
    heart_rate_warning: str
    logged_at: Any

class ApiResponse(BaseModel):
    success: bool
    message: str
    data: HealthMetricsResponse