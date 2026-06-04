from sqlalchemy.orm import Session
from datetime import datetime
from . import models
from .schemas import HealthMetricsInput, HealthMetricsResponse

def _analyze_metrics(input_data: HealthMetricsInput):
    # Ép kiểu an toàn đề phòng Flutter gửi chuỗi
    try:
        blood_sugar = float(input_data.blood_sugar)
        systolic_bp = int(input_data.systolic_bp)
        diastolic_bp = int(input_data.diastolic_bp)
        heart_rate = int(input_data.heart_rate)
    except (ValueError, TypeError):
        # Nếu có lỗi ép kiểu, gán giá trị mặc định để không sập server
        blood_sugar, systolic_bp, diastolic_bp, heart_rate = 0, 0, 0, 0

    # 1. Đánh giá đường huyết
    blood_sugar_status = "Bình thường"
    blood_sugar_warning = "Ổn định"
    if blood_sugar >= 181:
        blood_sugar_status = "Cao"
        blood_sugar_warning = "Khẩn cấp, cần tiêm Insulin ngay lập tức"
    elif blood_sugar >= 126:
        blood_sugar_status = "Cao"
        blood_sugar_warning = "Cảnh báo nguy cơ Tiểu đường!"
    if blood_sugar <= 69:
        blood_sugar_status = "Thấp"
        blood_sugar_warning = "Nguy cơ hạ đường huyết, cần uống nước đường!"

    # 2. Đánh giá huyết áp
    if systolic_bp >= 140 or diastolic_bp >= 90:
        bp_warning = "Huyết áp cao"
    elif systolic_bp < 90 or diastolic_bp < 60:
        bp_warning = "Huyết áp thấp"
    else:
        bp_warning = "Huyết áp bình thường"

    # 3. Đánh giá nhịp tim
    if heart_rate > 100:
        hr_warning = "Nhịp tim nhanh"
    elif heart_rate < 60:
        hr_warning = "Nhịp tim chậm"
    else:
        hr_warning = "Nhịp tim bình thường"

    return blood_sugar_status, blood_sugar_warning, bp_warning, hr_warning

def save_and_process_metrics(db: Session, payload: HealthMetricsInput) -> HealthMetricsResponse:
    # Phân tích chỉ số sinh tồn dựa trên payload đầu vào
    bs_status, bs_warn, bp_warn, hr_warn = _analyze_metrics(payload)
    current_time = datetime.utcnow()

    # Tạo mới bản ghi nhật ký đo lường
    new_log = models.HealthMetricsLog(
        user_id=payload.user_id,
        blood_sugar=int(payload.blood_sugar),
        unit=payload.unit,
        systolic_bp=payload.systolic_bp,
        diastolic_bp=payload.diastolic_bp,
        heart_rate=payload.heart_rate,
        logged_at=current_time
    )
    
    # 🌟 SỬA LẠI ĐOẠN NÀY ĐỂ KẾT NỐI VÀ LƯU THẲNG XUỐNG DB
    db.add(new_log)
    db.commit()          # Khóa dữ liệu vào MySQL luôn tại đây cho an toàn
    db.refresh(new_log)  # Làm mới bản ghi để kéo ID và các thông tin đồng bộ về

    return HealthMetricsResponse(
        blood_sugar_status=bs_status,
        blood_sugar_warning=bs_warn,
        blood_pressure_warning=bp_warn,
        heart_rate_warning=hr_warn,
        logged_at=new_log.logged_at # Lấy thời gian chuẩn đã ghi nhận từ DB
    )