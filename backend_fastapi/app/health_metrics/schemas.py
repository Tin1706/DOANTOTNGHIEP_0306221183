from pydantic import BaseModel, model_validator
from typing import List, Optional

# --- 1. ĐẦU VÀO TỪ FLUTTER ---
class HealthMetricsInput(BaseModel):
    user_id: int  # Nên ép về int nếu DB là INT AI PK, hoặc str if dùng UUID/Mongo
    blood_sugar: Optional[float] = None  # Đường huyết thường có thể là số thập phân (ví dụ: 5.6 mmol/L)
    unit: str = "mg/dL"                   # Giá trị mặc định cực tốt cho Flutter
    systolic_bp: Optional[int] = None    # Huyết áp tâm thu (số nguyên)
    diastolic_bp: Optional[int] = None   # Huyết áp tâm trương (số nguyên)
    heart_rate: Optional[int] = None     # Nhịp tim (số nguyên)

    # Đảm bảo Flutter không gửi lên một request trống rỗng không có chỉ số nào
    @model_validator(mode='after')
    def validate_metrics(self):
        if not any([self.blood_sugar, self.systolic_bp, self.diastolic_bp, self.heart_rate]):
            raise ValueError("Phải nhập ít nhất một chỉ số sức khỏe.")
        return self


# --- 2. ĐẦU RA CHO KẾT QUẢ PHÂN TÍCH (Response) ---
class HealthMetricsResponse(BaseModel):
    blood_sugar_status: str       # Ví dụ: "Bình thường", "Tiền tiểu đường", "Cao"
    blood_sugar_warning: str      # Cảnh báo chi tiết hoặc lời khuyên
    blood_pressure_warning: str   # Cảnh báo về huyết áp
    heart_rate_warning: str       # Cảnh báo về nhịp tim
    logged_at: str                # Trả về chuỗi ISO String (Ví dụ: "2026-06-09T15:40:00Z") cho Flutter dễ format


# --- 3. ĐẦU RA CHUẨN WRAPPER API ---
class ApiResponse(BaseModel):
    success: bool
    message: str
    data: HealthMetricsResponse


# --- 4. ĐẦU RA CHO BIỂU ĐỒ (Chart) ---
class MetricChartPoint(BaseModel):
    date: str                     # Định dạng "DD/MM" (Ví dụ: "09/06") rất chuẩn cho trục X của Flutter
    blood_sugar: Optional[float] = None
    systolic_bp: Optional[int] = None
    diastolic_bp: Optional[int] = None
    heart_rate: Optional[int] = None

class ChartApiResponse(BaseModel):
    success: bool
    message: str
    chartData: List[MetricChartPoint]
class MetricAverageData(BaseModel):
    avg_blood_sugar: Optional[float] = 0.0
    avg_systolic_bp: Optional[float] = 0.0
    avg_diastolic_bp: Optional[float] = 0.0
    avg_heart_rate: Optional[float] = 0.0

class AverageMetricsResponse(BaseModel):
    success: bool
    message: str
    data: MetricAverageData