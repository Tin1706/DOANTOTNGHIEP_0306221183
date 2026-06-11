# app/food/schemas.py
from pydantic import BaseModel
from typing import List, Optional
from pydantic import Field, field_validator
class FoodResponse(BaseModel):
    id: int
    meal_name: str
    meal_type: Optional[str] = None
    img_url: Optional[str] = None
    calories: int

    class Config:
        from_attributes = True

class CalorieCalculationRequest(BaseModel):
    # Dùng Field(max_length=4) để giới hạn tối đa 4 phần tử cho mảng
    sang: List[int] = Field(default=[], max_length=4, description="Danh sách ID món ăn buổi sáng (Tối đa 4)")
    trua: List[int] = Field(default=[], max_length=4, description="Danh sách ID món ăn buổi trưa (Tối đa 4)")
    toi: List[int] = Field(default=[], max_length=4, description="Danh sách ID món ăn buổi tối (Tối đa 4)")
    an_nhe: List[int] = Field(default=[], max_length=4, description="Danh sách ID món ăn buổi ăn nhẹ (Tối đa 4)")

    # Nếu bạn muốn tự viết câu báo lỗi bằng tiếng Việt cho chất lượng:
    @field_validator('sang', 'trua', 'toi', 'an_nhe')
    def check_max_four_items(cls, value):
        if len(value) > 4:
            raise ValueError("Mỗi buổi ăn không được chọn vượt quá 4 món đâu nhé!")
        return value