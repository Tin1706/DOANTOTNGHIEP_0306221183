from sqlalchemy import Column, Integer, String
from app.database import Base 

class FoodDictionary(Base):
    __tablename__ = "food_dictionary"

    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    meal_name = Column(String(150), nullable=False, index=True)
    meal_type = Column(String(10), nullable=True)
    img_url = Column(String(255), nullable=True)
    calories = Column(Integer, nullable=False)