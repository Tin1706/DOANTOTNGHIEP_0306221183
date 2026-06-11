# app/exercise/services.py
from sqlalchemy.orm import Session
from sqlalchemy import text
from fastapi import HTTPException
from app.exercise.schemas import ExerciseSelectionRequest

class ExerciseService:
    @staticmethod
    def get_all_exercises(db: Session):
        query = text("SELECT id, exercise_name, img_url, calories_30_minutes FROM exercise_dictionary")
        result = db.execute(query).fetchall()
        return [dict(row._mapping) for row in result]

    @staticmethod
    def process_single_exercise(payload: ExerciseSelectionRequest, db: Session):
        query = text("SELECT id, exercise_name, img_url, calories_30_minutes FROM exercise_dictionary WHERE id = :id")
        exercise = db.execute(query, {"id": payload.exercise_id}).fetchone()
        
        if not exercise:
            raise HTTPException(status_code=404, detail="Bài tập không tồn tại!")
            
        return {
            "exercise_name": exercise.exercise_name,
            "img_url": exercise.img_url,
            "calories_burned": exercise.calories_30_minutes
        }