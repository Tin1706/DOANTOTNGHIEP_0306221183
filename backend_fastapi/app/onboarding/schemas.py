from pydantic import BaseModel, Field
from typing import List, Optional
from datetime import date

class OnboardingInput(BaseModel):
    user_id: int
    height: float
    weight: float
    allergies: str | None = None
    date_of_birth: str | None = None
    pre_existing_conditions: List[str] = [] 
    symptoms: List[str] = []
    target_low: Optional[int] = 70
    target_high: Optional[int] = 180
class OnboardingResponse(BaseModel):
    patient_profile_id: int
    Age: int
    bmi: float  # Xuất chỉ số BMI tính toán từ weight và height

class ApiResponseOnboarding(BaseModel):
    success: bool
    message: str
    data: OnboardingResponse
    
    