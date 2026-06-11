from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from app.database import get_db

from app.globalSchemas import ApiResponse 
from app.exercise.schemas import ExerciseSelectionRequest
from app.exercise.services import ExerciseService

# 🟢 Giữ nguyên tên biến độc quyền đã kích hoạt thành công
exercise_router_unique = APIRouter(prefix="/api/exercise", tags=["Exercises"])

@exercise_router_unique.get("", response_model=ApiResponse)
def get_exercises(db: Session = Depends(get_db)):
    try:
        exercises = ExerciseService.get_all_exercises(db)
        return ApiResponse(success=True, message="Lấy danh sách bài tập thành công!", data={"total": len(exercises), "exercises": exercises})
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Lỗi: {str(e)}")

@exercise_router_unique.post("/select", response_model=ApiResponse)
def select_exercise(payload: ExerciseSelectionRequest, db: Session = Depends(get_db)):
    try:
        result = ExerciseService.process_single_exercise(payload, db)
        return ApiResponse(success=True, message="Xử lý bài tập thành công!", data=result)
    except HTTPException as http_ex:
        raise http_ex
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Lỗi: {str(e)}")