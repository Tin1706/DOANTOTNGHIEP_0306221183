from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from app.database import get_db
from . import services
from . import schemas

router = APIRouter(prefix="/api/diabetes-medications", tags=["Diabetes Medications"])

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
                # 🟢 TỐI ƯU: Nếu dosage bị null hoặc trống, chuyển thành nội dung nhắc nhở thân thiện trên điện thoại
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
                # 🟢 TỐI ƯU: Xử lý an toàn chuỗi rỗng/null cho thiết bị nhận diện
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


# --- API 6: GHI LOG NHẬT KÝ SỬ DỤNG THUỐC ---
@router.post(
    "/logs/log-intake", 
    response_model=schemas.CommonApiResponse,
    status_code=status.HTTP_201_CREATED
)
def log_medication_intake(payload: schemas.MedicationLogRequest, db: Session = Depends(get_db)):
    try:
        log_record = services.create_medication_log(
            db=db,
            user_id=payload.user_id,
            reminder_id=payload.reminder_id,
            status=payload.status,
            notes=payload.notes
        )
        if not log_record:
            raise HTTPException(status_code=404, detail="Không tìm thấy liên kết lịch nhắc nhở gốc.")
            
        return schemas.CommonApiResponse(
            success=True,
            message="Hệ thống đã ghi nhận lịch sử uống thuốc thực tế!",
            data={"log_id": log_record.id}
        )
    except HTTPException as he:
        raise he
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Lỗi hệ thống khi ghi nhật ký: {str(e)}"
        )