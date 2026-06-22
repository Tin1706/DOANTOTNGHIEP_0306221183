from sqlalchemy import create_engine
from sqlalchemy.orm import declarative_base, sessionmaker
from app.config import settings  # Cấu hình tập trung của bạn

# Lấy URL kết nối trực tiếp từ file cấu hình hệ thống
DATABASE_URL = settings.DATABASE_URL

# 🟢 1. TỰ ĐỘNG BẮT SSL KHI CHẠY TRÊN AIVEN CLOUD
# Pymysql yêu cầu truyền dict cấu hình SSL nếu URL chứa "?ssl-mode=REQUIRED"
connect_args = {}
if "aivencloud.com" in DATABASE_URL:
    connect_args = {"ssl": {"ssl_mode": "REQUIRED"}}

# 🟢 2. KHỞI TẠO ENGINE VỚI CẤU HÌNH TỐI ƯU CHO RENDER
engine = create_engine(
    DATABASE_URL,
    connect_args=connect_args,  # Ép pymysql bật SSL khi lên Cloud
    pool_pre_ping=True,         # Tự động kiểm tra kết nối còn sống không trước khi gửi lệnh
    pool_recycle=1800,          # Tự động làm mới kết nối sau 30 phút để tránh bị Aiven ngắt (Timeout)
    pool_size=5,                # Số lượng kết nối tối đa được giữ lại (Phù hợp với gói Free)
    max_overflow=10,            # Số kết nối vượt mức cho phép khi cao điểm
    echo=False                  # Để False khi chạy thật trên Render để tránh log quá nặng
)

# Khởi tạo bộ quản lý Session
SessionLocal = sessionmaker(
    autocommit=False, 
    autoflush=False, 
    bind=engine
)

# Lớp cơ sở cho các Model (User, Patient, Medications...)
Base = declarative_base()

# 🟢 3. ENDPOINT DEPENDENCY CHO FASTAPI
def get_db():
    """
    Hàm cung cấp Session kết nối Database cho từng Request của FastAPI.
    Đảm bảo tự đóng kết nối sau khi xử lý xong để tránh tràn bộ nhớ.
    """
    db = SessionLocal()
    try:
        yield db  
    finally:
        db.close()