from sqlalchemy import Column, Integer, String
from app.database import Base

class MedicationDictionary(Base):
    __tablename__ = "medication_dictionary"
    __table_args__ = {'extend_existing': True}

    id = Column(Integer, primary_key=True, autoincrement=True)
    medication_name = Column(String(150), nullable=False)     # Tên thuốc
    medication_category = Column(String(100), nullable=True)  # Danh mục/Loại thuốc