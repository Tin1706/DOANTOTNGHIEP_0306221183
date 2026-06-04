from sqlalchemy import Column, Integer, String, DateTime
from app.database import Base
from datetime import datetime

class HealthMetricsLog(Base):
    __tablename__ = "health_metrics_logs"
    __table_args__ = {'extend_existing': True}

    id = Column(Integer, primary_key=True, autoincrement=True)
    user_id = Column(Integer, nullable=False, index=True)
    blood_sugar = Column(Integer, nullable=False)
    unit = Column(String(10), nullable=False, default="mg/dL")
    systolic_bp = Column(Integer, nullable=False)
    diastolic_bp = Column(Integer, nullable=False)
    heart_rate = Column(Integer, nullable=False)
    logged_at = Column(DateTime, default=datetime.utcnow)