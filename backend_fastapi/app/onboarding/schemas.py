from pydantic import BaseModel, Field
from typing import List, Optional
from datetime import date

class OnboardingInput(BaseModel):
    user_id: int = Field(..., gt=0, description="ID của tài khoản người dùng")
    date_of_birth: date = Field(..., description="Ngày sinh của bệnh nhân (YYYY-MM-DD)")
    weight: int = Field(..., gt=0, description="Cân nặng (kg)")
    height: int = Field(..., gt=0, description="Chiều cao (cm)")
    allergies: Optional[str] = Field(default=None, description="Thông tin dị ứng")
    
    target_low: int = Field(default=70, gt=0)
    target_high: int = Field(default=180, gt=0)

    condition_ids: List[int] = Field(..., min_length=1, description="Danh sách ID bệnh nền không được trống")
    # 🌟 Đã đem symptom_ids quay trở lại đúng vị trí Onboarding theo ý bạn!
    symptom_ids: List[int] = Field(default=[], description="Danh sách ID triệu chứng ban đầu của bệnh nhân")

class OnboardingResponse(BaseModel):
    patient_profile_id: int
    age: int
    bmi: float  # Xuất chỉ số BMI tính toán từ weight và height

class ApiResponseOnboarding(BaseModel):
    success: bool
    message: str
    data: OnboardingResponse
    
    