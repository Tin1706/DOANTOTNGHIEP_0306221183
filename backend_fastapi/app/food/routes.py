from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from app.database import get_db

from app.globalSchemas import ApiResponse 
from app.food.schemas import CalorieCalculationRequest
from app.food.services import FoodService

# 🟢 Giữ nguyên tên biến độc quyền đã kích hoạt thành công
food_router_unique = APIRouter(prefix="/api/foods", tags=["Foods & Calories"])

@food_router_unique.get("", response_model=ApiResponse)
def get_foods(db: Session = Depends(get_db)):
    try:
        foods = FoodService.get_all_foods(db)
        return ApiResponse(success=True, message="Lấy danh sách thức ăn thành công!", data={"total": len(foods), "foods": foods})
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Lỗi: {str(e)}")

@food_router_unique.post("/calculate", response_model=ApiResponse)
def calculate_calories(payload: CalorieCalculationRequest, db: Session = Depends(get_db)):
    try:
        result = FoodService.calculate_calories(payload, db)
        return ApiResponse(success=True, message="Tính toán calo thành công!", data=result)
    except HTTPException as http_ex:
        raise http_ex
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Lỗi: {str(e)}")