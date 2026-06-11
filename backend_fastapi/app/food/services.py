# app/food/services.py
from typing import Optional

from sqlalchemy.orm import Session
from sqlalchemy import text
from fastapi import HTTPException, status
from app.food.schemas import CalorieCalculationRequest

class FoodService:
    @staticmethod
    def get_all_foods(db: Session, meal_type: Optional[str] = None):
        # Kiểm tra xem meal_type gửi lên có nằm trong 4 nhóm này không
        if meal_type in ["Sáng", "Trưa", "Tối", "Ăn nhẹ"]:
            query = text("SELECT id, meal_name, meal_type, img_url, calories FROM food_dictionary WHERE meal_type = :meal_type")
            result = db.execute(query, {"meal_type": meal_type}).fetchall()
        else:
            # Nếu không truyền meal_type hoặc truyền sai, lấy tất cả món ăn
            query = text("SELECT id, meal_name, meal_type, img_url, calories FROM food_dictionary")
            result = db.execute(query).fetchall()
            
        return [dict(row._mapping) for row in result]

    @staticmethod
    def calculate_calories(payload: CalorieCalculationRequest, db: Session):
        total_calories = 0
        detailed_summary = {}

        meals_map = {
            "Sáng": payload.sang,
            "Trưa": payload.trua,
            "Tối": payload.toi,
            "Ăn nhẹ": payload.an_nhe
        }

        for meal_type, food_ids in meals_map.items():
            if not food_ids:
                detailed_summary[meal_type] = {"chosen_foods": [], "subtotal_calories": 0}
                continue

            query = text("SELECT id, meal_name, calories FROM food_dictionary WHERE id IN :ids")
            db_result = db.execute(query, {"ids": tuple(food_ids)}).fetchall()
            db_foods_dict = {row.id: {"meal_name": row.meal_name, "calories": row.calories} for row in db_result}

            session_calories = 0
            session_food_names = []

            for food_id in food_ids:
                food_item = db_foods_dict.get(food_id)
                if food_item:
                    session_calories += food_item["calories"]
                    session_food_names.append(food_item["meal_name"])
                else:
                    raise HTTPException(status_code=404, detail=f"Không tìm thấy món ID {food_id}")

            total_calories += session_calories
            detailed_summary[meal_type] = {
                "chosen_foods": session_food_names,
                "subtotal_calories": session_calories
            }

        return {"total_calories": total_calories, "summary": detailed_summary}