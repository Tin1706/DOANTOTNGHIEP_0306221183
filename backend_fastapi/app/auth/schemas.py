from pydantic import BaseModel, EmailStr, Field
from datetime import date

class UserRegister(BaseModel):
    full_name: str = Field(..., max_length=100)
    email: EmailStr
    dob: date = Field(...)
    password: str = Field(..., min_length=6)
    confirm_password: str

class UserLogin(BaseModel):
    email: EmailStr
    password: str

class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"

class ForgotPasswordRequest(BaseModel):
    email: EmailStr

class VerifyOTPRequest(BaseModel):
    email: EmailStr
    otp_code: str = Field(..., min_length=6, max_length=6)

class ResetPasswordRequest(BaseModel):
    email: EmailStr
    otp_code: str
    new_password: str = Field(..., min_length=6)
    confirm_new_password: str

class MessageResponse(BaseModel):
    message: str
    user_id: int | None = None