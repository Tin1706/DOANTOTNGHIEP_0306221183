from sqlalchemy import Column, Integer, String
from app.database import Base 

class ExerciseDictionary(Base):
    __tablename__ = "exercise_dictionary"

    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    exercise_name = Column(String(100), nullable=False, index=True)
    img_url = Column(String(255), nullable=True)
    calories_30_minutes = Column(Integer, nullable=False) # Khớp chuẩn cột int