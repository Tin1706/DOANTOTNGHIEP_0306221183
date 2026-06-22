from pydantic_settings import BaseSettings, SettingsConfigDict
from pydantic import Field

class Settings(BaseSettings):
    # --- CẤU HÌNH CHUNG ---
    APP_NAME: str = "Diabetes Management API"
    ENVIRONMENT: str = "development"
    DEBUG: bool = True
    
    # --- CẤU HÌNH DATABASE (MYSQL) ---
    # 🟢 SỬA LẠI: Để mặc định là máy local của bạn cho an toàn!
    DATABASE_URL: str = Field(
        default="mysql+pymysql://root:rootTin2341@localhost:3306/diabetes_project",
        description="Chuỗi kết nối cơ sở dữ liệu MySQL"
    )

    # --- CẤU HÌNH BẢO MẬT (Dành cho JWT / Onboarding) ---
    SECRET_KEY: str = Field(default="temporary-secret-key-for-local-dev")
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 1440  # Tương đương 24 giờ

    # --- 🌟 CẤU HÌNH GỬI MAIL OTP ---
    EMAIL_HOST_USER: str = Field(default="")
    EMAIL_HOST_PASSWORD: str = Field(default="")

    # --- CẤU HÌNH ĐỌC FILE .ENV ---
    model_config = SettingsConfigDict(
        env_file=".env",            
        env_file_encoding="utf-8",
        extra="ignore"              
    )

# Khởi tạo đối tượng dùng chung toàn bộ project (Singleton Pattern)
settings = Settings()