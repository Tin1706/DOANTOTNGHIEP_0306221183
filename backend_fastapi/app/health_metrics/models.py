from sqlalchemy import Column, Float, Integer, String, DateTime
from app.database import Base
from datetime import datetime

class HealthMetricsLog(Base):
    __tablename__ = "health_metrics_logs"
    __table_args__ = {'extend_existing': True}

    id = Column(Integer, primary_key=True, autoincrement=True)
    user_id = Column(Integer, nullable=False, index=True)
    
    # Cho phép Null để Flutter có thể log riêng lẻ từng chỉ số
    # Chuyển blood_sugar thành Float vì chỉ số đường huyết thường có số thập phân (Ví dụ: 6.5 mmol/L)
    blood_sugar = Column(Integer, nullable=True) 
    unit = Column(String(10), nullable=False, default="mg/dL")
    
    systolic_bp = Column(Integer, nullable=True)
    diastolic_bp = Column(Integer, nullable=True)
    heart_rate = Column(Integer, nullable=True)
    
    # Sử dụng datetime.utcnow (không có dấu ngoặc tròn) để nó tự sinh thời gian lúc chạy lệnh INSERT
    logged_at = Column(DateTime, default=datetime.utcnow)