from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.orm import Session
from app.database import get_db
from typing import Optional
from fastapi import Query, Depends, HTTPException, status

from app.health_metrics.models import HealthMetricsLog

# 🟢 GIẢI QUYẾT TRÙNG TÊN: 
# Chỉ giữ lại ApiResponse từ globalSchemas nếu nó là schema chung cho toàn dự án
from .schemas import AverageMetricsResponse, HealthMetricsInput, ChartApiResponse 
from app.globalSchemas import ApiResponse  

from . import services

# Đảm bảo khai báo chuẩn router không bị gián đoạn cú pháp
router = APIRouter(prefix="/api/health-metrics", tags=["Health Metrics"])

# 1. API Ghi nhận chỉ số sức khỏe
@router.post(
    "/submit", 
    response_model=ApiResponse, 
    status_code=status.HTTP_201_CREATED
)
def submit_metrics(payload: HealthMetricsInput, db: Session = Depends(get_db)):
    try:
        evaluation_data = services.save_and_process_metrics(db, payload) 
        
        return ApiResponse(
            success=True,
            message="Ghi nhận chỉ số sức khỏe thành công!",
            data=evaluation_data
        )
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=f"Lỗi hệ thống: {str(e)}")


# 2. API Lấy các lần đo gần nhất cho đồ thị Flutter
@router.get(
    "/latest", 
    response_model=ChartApiResponse,
    status_code=status.HTTP_200_OK
)
@router.get(
    "/latest", 
    response_model=ChartApiResponse,
    status_code=status.HTTP_200_OK
)
def get_latest_metrics(
    user_id: int = Query(..., description="ID của người dùng cần lấy dữ liệu"),
    days: int = Query(7, ge=1, le=365, description="Số ngày gần nhất muốn lấy dữ liệu"), 
    db: Session = Depends(get_db)
):
    try:
        # CHÚ Ý CHỖ NÀY: Phải truyền là limit=days
        latest_data = services.get_latest_metrics(db=db, user_id=user_id, limit=days) 
        
        return ChartApiResponse(
            success=True,
            message=f"Lấy dữ liệu trong {days} ngày gần nhất thành công!",
            chartData=latest_data
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, 
            detail=f"Lỗi hệ thống khi lấy dữ liệu: {str(e)}"
        )
# ... các import khác của bạn ...

@router.get(
    "/average", 
    response_model=AverageMetricsResponse,
    status_code=status.HTTP_200_OK
)
def get_average_metrics(
    user_id: int = Query(..., description="ID của người dùng cần tính trung bình"),
    # 🟢 Đặt mặc định là None ở tham số đầu tiên của Query
    days: Optional[int] = Query(default=None, ge=1, le=365, description="Số ngày gần nhất muốn tính. Để trống sẽ tính mặc định TẤT CẢ từ trước đến nay"),
    db: Session = Depends(get_db)
):
    try:
        # Truyền tham số days (đang là None nếu để trống) xuống tầng service
        avg_data = services.calculate_average_metrics(db=db, user_id=user_id, limit=days)
        
        # Tự động thay đổi thông báo tùy thuộc vào việc có truyền số ngày hay không
        message = (
            "Tính trung bình tất cả các chỉ số từ trước đến nay thành công!" 
            if days is None 
            else f"Tính trung bình các chỉ số trong {days} ngày gần nhất thành công!"
        )
        
        return AverageMetricsResponse(
            success=True,
            message=message,
            data=avg_data
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, 
            detail=f"Lỗi hệ thống khi tính toán chỉ số trung bình: {str(e)}"
        )
        
@router.get("/history/{user_id}")
def get_health_metrics_history(user_id: int, db: Session = Depends(get_db)):
    try:
        # 1. Truy vấn danh sách từ bảng health_metrics_logs theo user_id
        # Xếp lùi logged_at.desc() để bản ghi mới nhất luôn trồi lên đầu danh sách
        logs = db.query(HealthMetricsLog).filter(
            HealthMetricsLog.user_id == user_id
        ).order_by(HealthMetricsLog.logged_at.desc()).all()
        
        data_list = []
        for log in logs:
            # 2. Tạo một Object tạm giả lập cấu trúc HealthMetricsInput để truyền vào hàm _analyze_metrics của bạn
            # Giúp bạn tái sử dụng 100% logic phân tích cũ mà không cần viết lại
            class TemporaryInput:
                blood_sugar = log.blood_sugar
                systolic_bp = log.systolic_bp
                diastolic_bp = log.diastolic_bp
                heart_rate = log.heart_rate

            # 3. Gọi hàm phân tích của bạn dựa trên dữ liệu thô từ Database
            blood_sugar_status, blood_sugar_warning, bp_warning, hr_warning = services._analyze_metrics(TemporaryInput())
            
            # 4. Đóng gói dữ liệu JSON trả về cho Flutter
            data_list.append({
                "id": log.id,
                "blood_sugar": log.blood_sugar,
                "unit": log.unit if log.unit else "mg/dL",
                "systolic_bp": log.systolic_bp,
                "diastolic_bp": log.diastolic_bp,
                "heart_rate": log.heart_rate,
                # Map chính xác các biến trả về từ hàm _analyze_metrics của bạn vào đây
                "blood_sugar_status": blood_sugar_status,
                "blood_sugar_warning": blood_sugar_warning,
                "blood_pressure_warning": bp_warning,
                "heart_rate_warning": hr_warning,
                # Định dạng ngày giờ hiển thị dạng: DD/MM HH:MM (Ví dụ: 23/06 09:54)
                "logged_at": log.logged_at.strftime("%d/%m %H:%M") if log.logged_at else ""
            })
            
        return {
            "success": True,
            "data": data_list
        }
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Lỗi Server khi tải lịch sử: {str(e)}")