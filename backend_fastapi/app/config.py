from pydantic_settings import BaseSettings, SettingsConfigDict
from pydantic import Field

class Settings(BaseSettings):
    # --- CẤU HÌNH CHUNG ---
    APP_NAME: str = "Diabetes Management API"
    ENVIRONMENT: str = "development"
    DEBUG: bool = True
    
    # --- CẤU HÌNH DATABASE (MYSQL) ---
    # Thay vì để pass thật ở đây, ta để một chuỗi mặc định vô hại.
    # Khi chạy, Pydantic sẽ tự đè cấu hình thật từ file .env lên.
    DATABASE_URL: str = Field(
        default="mysql+pymysql://root:rootTin2341@localhost:3306/diabetes_project",
        description="Chuỗi kết nối cơ sở dữ liệu MySQL"
    )

    # --- CẤU HÌNH BẢO MẬT (Dành cho JWT / Onboarding) ---
    # Tương tự, không để key thật trong code mã nguồn
    SECRET_KEY: str = Field(default="temporary-secret-key-for-local-dev")
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 1440  # Tương đương 24 giờ

    # --- CẤU HÌNH ĐỌC FILE .ENV ---
    model_config = SettingsConfigDict(
        env_file=".env",            # Tìm file .env ở thư mục gốc
        env_file_encoding="utf-8",
        extra="ignore"              # Bỏ qua nếu trong file .env có thừa biến khác
    )

# Khởi tạo đối tượng dùng chung toàn bộ project (Singleton Pattern)
settings = Settings()