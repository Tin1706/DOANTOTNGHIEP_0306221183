from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import func
from sqlalchemy.orm import Session
from app.database import get_db
from . import services
from . import schemas
from pydantic import BaseModel
import firebase_admin
from firebase_admin import messaging

router = APIRouter(prefix="/api/diabetes-medications", tags=["Diabetes Medications"])

# --- SCHEMA PHỤ DÙNG CHO FCM TOKEN ---
class FcmTokenUpdateRequest(BaseModel):
    user_id: int
    fcm_token: str

class TestPushRequest(BaseModel):
    fcm_token: str
    title: str = "Thử nghiệm Thông Báo"
    body: str = "Đây là thông báo Push thử nghiệm từ FastAPI!"


# --- API MỚI 1: CẬP NHẬT FCM TOKEN TỪ APP FLUTTER ---
@router.post(
    "/update-fcm-token",
    response_model=schemas.CommonApiResponse,
    status_code=status.HTTP_200_OK,
    summary="Cập nhật FCM Device Token của người dùng"
)
def update_fcm_token(payload: FcmTokenUpdateRequest, db: Session = Depends(get_db)):
    try:
        # TODO: Nếu bạn muốn lưu fcm_token vào CSDL, gọi hàm service ở đây:
        # services.update_user_fcm_token(db, user_id=payload.user_id, token=payload.fcm_token)
        
        print(f"🔑 [FCM Token] Đã nhận Token từ User ID {payload.user_id}: {payload.fcm_token[:20]}...")
        
        return schemas.CommonApiResponse(
            success=True,
            message="Cập nhật FCM Token thành công!",
            data={"user_id": payload.user_id}
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Lỗi khi cập nhật FCM Token: {str(e)}"
        )


# --- API MỚI 2: THỬ NGHIỆM GỬI PUSH NOTIFICATION NGAY LẬP TỨC ---
@router.post(
    "/test-push",
    response_model=schemas.CommonApiResponse,
    status_code=status.HTTP_200_OK,
    summary="Gửi thử một thông báo Push đến thiết bị"
)
def test_push_notification(payload: TestPushRequest):
    try:
        message = messaging.Message(
            notification=messaging.Notification(
                title=payload.title,
                body=payload.body,
            ),
            token=payload.fcm_token,
            android=messaging.AndroidConfig(
                priority='high',
                notification=messaging.AndroidNotification(
                    sound='default',
                    channel_id='high_importance_channel'
                )
            )
        )
        response = messaging.send(message)
        print(f"✅ [FCM Test Success] Message ID: {response}")
        
        return schemas.CommonApiResponse(
            success=True,
            message="Đã gửi Push Notification thành công!",
            data={"message_id": response}
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Lỗi gửi Push Notification: {str(e)}"
        )


# --- API 1: LẤY TOÀN BỘ DANH MỤC THUỐC ---
@router.get(
    "/all", 
    response_model=schemas.MedicationListApiResponse, 
    status_code=status.HTTP_200_OK,
    summary="Liệt kê danh mục thuốc từ điển"
)
def get_medications(db: Session = Depends(get_db)):
    try:
        medications = services.get_all_diabetes_medications(db)
        return schemas.MedicationListApiResponse(
            success=True,
            message="Lấy danh sách thuốc từ danh mục thành công!",
            data=medications
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, 
            detail=f"Lỗi hệ thống khi tải danh mục thuốc: {str(e)}"
        )


# --- API 2: LẤY DANH SÁCH NHẮC NHỞ KÈM TÊN THUỐC CHI TIẾT ---
@router.get(
    "/reminders/user/{user_id}", 
    response_model=schemas.ReminderListApiResponse,
    status_code=status.HTTP_200_OK,
    summary="Lấy danh sách nhắc nhở hiển thị lên Card màn hình chính"
)
def get_user_reminders(user_id: int, db: Session = Depends(get_db)):
    try:
        reminders = services.get_active_reminders_by_user(db, user_id=user_id)
        
        # Đồng bộ chuyển kiểu dữ liệu Time sang String tránh lỗi JSON parser
        for r in reminders:
            if hasattr(r, 'reminder_time') and r.reminder_time is not None:
                r.reminder_time = r.reminder_time.strftime("%H:%M:%S")
                
        return schemas.ReminderListApiResponse(
            success=True,
            message="Lấy danh sách lịch nhắc nhở thành công!",
            data=reminders
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Lỗi hệ thống khi tải danh sách nhắc nhở: {str(e)}"
        )


# --- API 3: TẠO MỚI LỊCH NHẮC NHỞ ---
@router.post(
    "/reminders/create", 
    response_model=schemas.CommonApiResponse,
    status_code=status.HTTP_201_CREATED,
    summary="Lưu lịch nhắc nhở mới được thiết lập"
)
def create_new_reminder(payload: schemas.ReminderCreateRequest, db: Session = Depends(get_db)):
    try:
        reminder = services.create_reminder(
            db=db,
            user_id=payload.user_id,
            medication_dictionary_id=payload.medication_dictionary_id,
            title=payload.title,
            dosage=payload.dosage,
            reminder_time_str=payload.reminder_time
        )
        
        # TỰ ĐỘNG TÁCH CHUỖI THỜI GIAN THÀNH SỐ NGUYÊN HOUR VÀ MINUTE
        time_parts = payload.reminder_time.split(":")
        hour = int(time_parts[0])
        minute = int(time_parts[1])

        return schemas.CommonApiResponse(
            success=True,
            message="Thiết lập lịch nhắc nhở thành công!",
            data={
                "reminder_id": reminder.id,
                "title": payload.title,
                "body": payload.dosage if (payload.dosage and payload.dosage.strip() != "") else "Đến giờ thực hiện hành động!",
                "hour": hour,
                "minute": minute
            }
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Dữ liệu gửi lên không hợp lệ: {str(e)}"
        )


# --- API 4: CẬP NHẬT LỊCH NHẮC NHỞ ---
@router.put(
    "/reminders/update/{reminder_id}", 
    response_model=schemas.CommonApiResponse,
    status_code=status.HTTP_200_OK
)
def update_existing_reminder(reminder_id: int, payload: schemas.ReminderUpdateRequest, db: Session = Depends(get_db)):
    try:
        updated_reminder = services.update_reminder(
            db=db,
            reminder_id=reminder_id,
            title=payload.title,
            dosage=payload.dosage,
            reminder_time_str=payload.reminder_time,
            is_active=payload.is_active
        )
        if not updated_reminder:
            raise HTTPException(status_code=404, detail="Không tìm thấy lịch nhắc nhở chỉ định.")
            
        # TỰ ĐỘNG TÁCH CHUỖI THỜI GIAN MỚI ĐỂ GỬI VỀ CHO APP CẬP NHẬT CHUÔNG
        time_parts = payload.reminder_time.split(":")
        hour = int(time_parts[0])
        minute = int(time_parts[1])
            
        return schemas.CommonApiResponse(
            success=True,
            message="Cập nhật thông tin thay đổi thành công!",
            data={
                "reminder_id": updated_reminder.id,
                "title": payload.title,
                "body": payload.dosage if (payload.dosage and payload.dosage.strip() != "") else "Đến giờ thực hiện hành động!",
                "hour": hour,
                "minute": minute,
                "is_active": payload.is_active 
            }
        )
    except HTTPException as he:
        raise he
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Lỗi hệ thống khi cập nhật cấu hình: {str(e)}"
        )


# --- API 5: XÓA MỀM LỊCH NHẮC NHỞ ---
@router.delete(
    "/reminders/delete/{reminder_id}", 
    response_model=schemas.CommonApiResponse,
    status_code=status.HTTP_200_OK
)
def delete_existing_reminder(reminder_id: int, db: Session = Depends(get_db)):
    try:
        success = services.delete_reminder(db=db, reminder_id=reminder_id)
        if not success:
            raise HTTPException(status_code=404, detail="Mục nhắc nhở không tồn tại hoặc đã bị xóa trước đó.")
            
        return schemas.CommonApiResponse(
            success=True,
            message="Hủy bỏ lịch nhắc nhở thành công!",
            data=None
        )
    except HTTPException as he:
        raise he
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Lỗi hệ thống khi thực thi lệnh xóa: {str(e)}"
        )