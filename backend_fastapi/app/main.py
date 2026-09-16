from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.database import Base, engine
import firebase_admin
from firebase_admin import credentials, messaging
from apscheduler.schedulers.background import BackgroundScheduler
from datetime import datetime
import os

# 1. Import các router con
from app.auth.routes import router as auth_router
from app.onboarding.routes import router as onboarding_router 
from app.health_metrics.routes import router as health_metrics_router
from app.food.routes import food_router_unique
from app.exercise.routes import exercise_router_unique
from app.reminder.routes import router as reminder_router
from app.user_info.routes import router as user_info_router
from app.pdf.routes import router as pdf_router

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

# =========================================================
# 2. KHỞI TẠO FIREBASE ADMIN SDK
# =========================================================
# Đảm bảo bạn đã lưu file firebase-key.json ở thư mục gốc backend
FIREBASE_KEY_PATH = "firebase-key.json"

if os.path.exists(FIREBASE_KEY_PATH):
    cred = credentials.Certificate(FIREBASE_KEY_PATH)
    firebase_admin.initialize_app(cred)
    print("🔥 [Firebase] Đã khởi tạo Firebase Admin SDK thành công.")
else:
    print(f"⚠️ [Firebase Warning] Không tìm thấy file {FIREBASE_KEY_PATH}. Push Notification sẽ chưa hoạt động.")

# =========================================================
# 3. CHỨC NĂNG GỬI PUSH NOTIFICATION & SCHEDULER
# =========================================================
def send_fcm_notification(fcm_token: str, title: str, body: str):
    """Gửi thông báo Push đến 1 thiết bị cụ thể"""
    try:
        message = messaging.Message(
            notification=messaging.Notification(
                title=title,
                body=body,
            ),
            token=fcm_token,
            android=messaging.AndroidConfig(
                priority='high',
                notification=messaging.AndroidNotification(
                    sound='default',
                    channel_id='high_importance_channel'
                )
            )
        )
        response = messaging.send(message)
        print(f"✅ [FCM Success] Gửi thông báo thành công: {response}")
    except Exception as e:
        print(f"🚨 [FCM Error] Không thể gửi thông báo: {e}")


def check_and_send_reminders():
    """Hàm chạy tự động mỗi phút để quét các nhắc nhở trùng thời gian hiện tại"""
    now_str = datetime.now().strftime("%H:%M:00")
    print(f"⏰ [Scheduler] Đang quét nhắc nhở cho khung giờ: {now_str}")
    
    # TODO: Khi nối DB thực tế trong reminder/routes.py hoặc query tại đây:
    # Query các nhắc nhở đến giờ từ DB -> Lấy fcm_token của User -> Gọi send_fcm_notification()


# Khởi tạo Scheduler quét định kỳ mỗi 1 phút
scheduler = BackgroundScheduler()
scheduler.add_job(check_and_send_reminders, 'cron', minute='*')

@app.on_event("startup")
def startup_event():
    scheduler.start()
    print("🚀 [APScheduler] Đã kích hoạt bộ quét nhắc nhở ngầm.")

@app.on_event("shutdown")
def shutdown_event():
    scheduler.shutdown()
    print("🛑 [APScheduler] Đã dừng bộ quét ngầm.")

# =========================================================
# 4. ĐĂNG KÝ ROUTER
# =========================================================
app.include_router(auth_router)
app.include_router(onboarding_router)  
app.include_router(health_metrics_router)
app.include_router(food_router_unique)
app.include_router(exercise_router_unique)
app.include_router(reminder_router)
app.include_router(user_info_router)
app.include_router(pdf_router)

@app.get("/")
def read_root():
    return {"message": "Hello World"}