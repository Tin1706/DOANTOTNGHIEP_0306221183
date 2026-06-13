from sqlalchemy.orm import Session
from sqlalchemy import func
from datetime import datetime, timedelta, timezone
from typing import List
from . import models
from .schemas import HealthMetricsInput, HealthMetricsResponse, MetricChartPoint

# Khai báo múi giờ Việt Nam toàn cục
vnam_tz = timezone(timedelta(hours=7))

def _analyze_metrics(input_data: HealthMetricsInput):
    # Ép kiểu an toàn về int để đồng bộ với Database của bạn
    try:
        blood_sugar = int(input_data.blood_sugar) if input_data.blood_sugar is not None else 0
        systolic_bp = int(input_data.systolic_bp) if input_data.systolic_bp is not None else 0
        diastolic_bp = int(input_data.diastolic_bp) if input_data.diastolic_bp is not None else 0
        heart_rate = int(input_data.heart_rate) if input_data.heart_rate is not None else 0
    except (ValueError, TypeError):
        blood_sugar, systolic_bp, diastolic_bp, heart_rate = 0, 0, 0, 0

    # 1. Đánh giá đường huyết (mg/dL)
    blood_sugar_status = "Bình thường"
    blood_sugar_warning = "Ổn định"
    if blood_sugar >= 181:
        blood_sugar_status = "Cao"
        blood_sugar_warning = "Khẩn cấp, cần tiêm Insulin ngay lập tức"
    elif blood_sugar >= 126:
        blood_sugar_status = "Cao"
        blood_sugar_warning = "Cảnh báo nguy cơ Tiểu đường!"
    elif 0 < blood_sugar <= 69: 
        blood_sugar_status = "Thấp"
        blood_sugar_warning = "Nguy cơ hạ đường huyết, cần uống nước đường!"

    # 2. Đánh giá huyết áp
    if systolic_bp >= 140 or diastolic_bp >= 90:
        bp_warning = "Huyết áp cao"
    elif (systolic_bp < 90 or diastolic_bp < 60) and (systolic_bp > 0 and diastolic_bp > 0):
        bp_warning = "Huyết áp thấp"
    else:
        bp_warning = "Huyết áp bình thường"

    # 3. Đánh giá nhịp tim
    if heart_rate > 80:
        hr_warning = "Nhịp tim nhanh"
    elif 0 < heart_rate < 60:
        hr_warning = "Nhịp tim chậm"
    else:
        hr_warning = "Nhịp tim bình thường"

    return blood_sugar_status, blood_sugar_warning, bp_warning, hr_warning


def save_and_process_metrics(db: Session, payload: HealthMetricsInput) -> HealthMetricsResponse:
    """Hàm xử lý lưu chỉ số sức khỏe mới dạng INT xuống MySQL theo múi giờ Việt Nam"""
    bs_status, bs_warn, bp_warn, hr_warn = _analyze_metrics(payload)
    
    # Lấy giờ Việt Nam hiện tại (Bỏ tzinfo để tương thích với DateTime của MySQL)
    current_time = datetime.now(vnam_tz).replace(tzinfo=None)

    new_log = models.HealthMetricsLog(
        user_id=int(payload.user_id),
        blood_sugar=int(payload.blood_sugar) if payload.blood_sugar is not None else None,
        unit=payload.unit,
        systolic_bp=int(payload.systolic_bp) if payload.systolic_bp is not None else None,
        diastolic_bp=int(payload.diastolic_bp) if payload.diastolic_bp is not None else None,
        heart_rate=int(payload.heart_rate) if payload.heart_rate is not None else None,
        logged_at=current_time
    )
    
    db.add(new_log)
    db.commit()
    db.refresh(new_log)

    return HealthMetricsResponse(
        blood_sugar_status=bs_status,
        blood_sugar_warning=bs_warn,
        blood_pressure_warning=bp_warn,
        heart_rate_warning=hr_warn,
        logged_at=new_log.logged_at.strftime("%d/%m %H:%M") if new_log.logged_at else ""
    )

    
def get_latest_metrics(db: Session, user_id: int, limit: int = 7): # Đặt mặc định là 7 nếu không truyền
    """Hàm lấy toàn bộ các lần đo trong vòng N ngày gần nhất (Theo giờ VN)"""
    
    # 🟢 SỬA TẠI ĐÂY: Thay timedelta(days=7) thành timedelta(days=limit) để lấy số ngày linh hoạt từ API
    seven_days_ago = datetime.now(vnam_tz).replace(tzinfo=None) - timedelta(days=limit)
    
    # 2. Truy vấn lọc theo user_id và mốc thời gian N ngày qua
    metrics_query = (
        db.query(models.HealthMetricsLog)
        .filter(
            models.HealthMetricsLog.user_id == user_id,
            models.HealthMetricsLog.logged_at >= seven_days_ago  # Chỉ lấy dữ liệu từ N ngày trước đến nay
        )
        .order_by(models.HealthMetricsLog.logged_at.desc())     # Sắp xếp từ mới nhất đến cũ nhất
        .all()
    )
    
    chart_data = []
    for row in metrics_query:
        # Định dạng thời gian hiển thị trên trục biểu đồ Flutter (Ví dụ: "10/06 15:30")
        formatted_date = row.logged_at.strftime("%d/%m %H:%M") if row.logged_at else ""
        
        chart_data.append(
            MetricChartPoint(
                date=formatted_date,
                blood_sugar=row.blood_sugar,
                systolic_bp=row.systolic_bp,
                diastolic_bp=row.diastolic_bp,
                heart_rate=row.heart_rate
            )
        )
    
    # 3. Đảo ngược chuỗi để dữ liệu chạy từ Cũ đến Mới khi vẽ lên biểu đồ Flutter
    chart_data.reverse()
    return chart_data
from datetime import datetime, timedelta
from sqlalchemy import func
from sqlalchemy.orm import Session

def calculate_average_metrics(db: Session, user_id: int, limit: int = None):
    """Hàm tính trung bình các chỉ số. Nếu limit=None thì mặc định lấy tất cả dữ liệu"""
    
    # 1. Tạo query gốc lọc theo user_id
    query = db.query(
        func.avg(models.HealthMetricsLog.blood_sugar).label("avg_blood_sugar"),
        func.avg(models.HealthMetricsLog.systolic_bp).label("avg_systolic_bp"),
        func.avg(models.HealthMetricsLog.diastolic_bp).label("avg_diastolic_bp"),
        func.avg(models.HealthMetricsLog.heart_rate).label("avg_heart_rate")
    ).filter(models.HealthMetricsLog.user_id == user_id)
    
    # 2. Nếu người dùng nhập số ngày (limit khác None), tiến hành lọc theo mốc thời gian
    if limit is not None:
        start_date = datetime.now(vnam_tz).replace(tzinfo=None) - timedelta(days=limit)
        query = query.filter(models.HealthMetricsLog.logged_at >= start_date)
        
    result = query.first()
    
    # 3. Trả về kết quả làm tròn đến 1 hoặc 2 chữ số thập phân
    return {
        "avg_blood_sugar": round(result.avg_blood_sugar, 2) if result.avg_blood_sugar else 0.0,
        "avg_systolic_bp": round(result.avg_systolic_bp, 1) if result.avg_systolic_bp else 0.0,
        "avg_diastolic_bp": round(result.avg_diastolic_bp, 1) if result.avg_diastolic_bp else 0.0,
        "avg_heart_rate": round(result.avg_heart_rate, 1) if result.avg_heart_rate else 0.0
    }