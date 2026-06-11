from sqlalchemy.orm import Session
from . import models

def get_all_diabetes_medications(db: Session):
    """Hàm quét sạch danh sách thuốc từ bảng medication_dictionary"""
    return db.query(models.MedicationDictionary).order_by(models.MedicationDictionary.medication_name.asc()).all()