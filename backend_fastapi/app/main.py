from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware  # 🌟 Import thêm thư viện CORS
from app.database import Base, engine

# 🌟 1. IMPORT các file routes từ các thư mục vào
from app.auth.routes import router as auth_router
from app.onboarding.routes import router as onboarding_router 
from app.health_metrics.routes import router as health_metrics_router

app = FastAPI()

# 🌟 CẤU HÌNH CORS: Cho phép Flutter Web có thể kết nối được vào API
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  
    allow_credentials=True,
    allow_methods=["*"],  
    allow_headers=["*"],  
)

Base.metadata.create_all(bind=engine)

# 🌟 2. ĐĂNG KÝ các router đó với FastAPI
app.include_router(auth_router)
app.include_router(onboarding_router)  
app.include_router(health_metrics_router)

@app.get("/")
def read_root():
    return {"message": "Hello World"}