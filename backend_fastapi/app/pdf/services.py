from sqlalchemy.orm import Session
from sqlalchemy import func  # 🟢 Thêm func để tính AVG dữ liệu từ SQL

# Giữ nguyên cấu trúc import chuẩn của bạn
from app.auth.models import UserModel
from app.onboarding.models import PatientProfile
from app.reminder.models import Reminder, MedicationDictionary  
from app.health_metrics.models import HealthMetricsLog

def get_patient_report_data(db: Session, user_id: int):
    # 1. Truy vấn thông tin tài khoản (Họ tên)
    user = db.query(UserModel).filter(UserModel.id == user_id).first()
    
    # 2. Truy vấn hồ sơ chi tiết bệnh nhân
    profile = db.query(PatientProfile).filter(PatientProfile.user_id == user_id).first()
    if not profile:
        return None  

    # 3. 🟢 TÍNH TRUNG BÌNH CÁC CHỈ SỐ SỨC KHỎE
    # Sử dụng func.avg để cơ sở dữ liệu tính toán trực tiếp, tự động bỏ qua các giá trị NULL
    metrics_avg = db.query(
        func.avg(HealthMetricsLog.blood_sugar).label('avg_blood_sugar'),
        func.avg(HealthMetricsLog.systolic_bp).label('avg_systolic'),
        func.avg(HealthMetricsLog.diastolic_bp).label('avg_diastolic'),
        func.avg(HealthMetricsLog.heart_rate).label('avg_heart_rate')
    ).filter(HealthMetricsLog.user_id == user_id).first()

    # Lấy đơn vị đo mới nhất của bệnh nhân để hiển thị ở giao diện
    latest_metric = db.query(HealthMetricsLog)\
                      .filter(HealthMetricsLog.user_id == user_id)\
                      .order_by(HealthMetricsLog.logged_at.desc())\
                      .first()
    unit = latest_metric.unit if latest_metric and latest_metric.unit else "mg/dL"

    # 4. Kỹ thuật JOIN danh sách thuốc (Giữ nguyên)
    reminders_with_meds = db.query(Reminder, MedicationDictionary)\
                            .join(MedicationDictionary, Reminder.medication_dictionary_id == MedicationDictionary.id)\
                            .filter(Reminder.user_id == user_id, Reminder.is_deleted == 0)\
                            .all()

    medications_list = []
    for r, m in reminders_with_meds:
        medications_list.append({
            "name": m.medication_name, 
            "dosage": r.dosage if r.dosage else "Theo chỉ định" 
        })

    # 5. Đổ dữ liệu trung bình (Đã làm tròn 2 chữ số thập phân bằng round())
    return {
        "name": user.name if user and hasattr(user, 'name') else "Huỳnh Trọng Tín",
        "age": profile.Age if profile.Age is not None else 0, 
        "height": profile.height if profile.height is not None else 0,
        "weight": profile.weight if profile.weight is not None else 0,
        
        # Hiển thị giá trị trung bình kèm hậu tố "(Trung bình)"
        "blood_sugar": f"{round(metrics_avg.avg_blood_sugar, 2)} {unit} (Trung bình)" if metrics_avg.avg_blood_sugar is not None else "Chưa đo",
        "systolic": f"{round(metrics_avg.avg_systolic, 1)} mmHg (Trung bình)" if metrics_avg.avg_systolic is not None else "Chưa đo",
        "diastolic": f"{round(metrics_avg.avg_diastolic, 1)} mmHg (Trung bình)" if metrics_avg.avg_diastolic is not None else "Chưa đo",
        "heart_rate": f"{round(metrics_avg.avg_heart_rate, 1)} bpm (Trung bình)" if metrics_avg.avg_heart_rate is not None else "Chưa đo",
        
        "underlying_disease": profile.pre_existing_conditions if profile.pre_existing_conditions else "Không có",
        "symptoms": profile.symptoms if profile.symptoms else "Không có",
        "allergy": profile.allergies if profile.allergies else "Không có",
        
        "medications": medications_list
    }