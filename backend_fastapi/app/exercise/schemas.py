from pydantic import BaseModel
class ExerciseSelectionRequest(BaseModel):
    user_id: int
    exercise_id: int