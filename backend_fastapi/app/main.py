from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.database import Base, engine

# 1. Import các router con
from app.auth.routes import router as auth_router
from app.onboarding.routes import router as onboarding_router 
from app.health_metrics.routes import router as health_metrics_router
from app.food.routes import food_router_unique
from app.exercise.routes import exercise_router_unique
from app.reminder.routes import router as reminder_router

app = FastAPI()

# Cấu hình CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  
    allow_credentials=True,
    allow_methods=["*"],  
    allow_headers=["*"],  
)

# Tự động tạo bảng xuống MySQL
Base.metadata.create_all(bind=engine)

# Đăng ký các router với FastAPI
app.include_router(auth_router)
app.include_router(onboarding_router)  
app.include_router(health_metrics_router)
app.include_router(food_router_unique)
app.include_router(exercise_router_unique)
app.include_router(reminder_router)

@app.get("/")
def read_root():
    return {"message": "Hello World"}