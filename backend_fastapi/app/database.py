from sqlalchemy import create_engine
from sqlalchemy.orm import declarative_base, sessionmaker
from app.config import settings  # <--- Import cấu hình tập trung ở đây

# Lấy URL kết nối trực tiếp từ file cấu hình hệ thống
DATABASE_URL = settings.DATABASE_URL

engine = create_engine(
    DATABASE_URL,
    pool_pre_ping=True,  
    echo=False           
)

SessionLocal = sessionmaker(
    autocommit=False, 
    autoflush=False, 
    bind=engine
)

Base = declarative_base()

def get_db():
    db = SessionLocal()
    try:
        yield db  
    finally:
        db.close()