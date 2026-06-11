from pydantic import BaseModel, EmailStr, Field
from datetime import date

# =====================================================================
# --- 1. SCHEMAS CHO REQUESTS (DỮ LIỆU TỪ CLIENT GỬI LÊN SERVER) ---
# =====================================================================

class UserRegister(BaseModel):
    full_name: str = Field(..., max_length=100)
    email: EmailStr
    dob: date = Field(...)
    password: str = Field(..., min_length=6)
    confirm_password: str

class VerifyRegisterOTP(BaseModel):
    email: EmailStr
    full_name: str = Field(..., max_length=100)
    dob: date = Field(...)  # Pydantic tự parse chuỗi "YYYY-MM-DD" từ Flutter thành kiểu date một cách an toàn
    password: str = Field(..., min_length=6)
    otp_code: str = Field(..., min_length=6, max_length=6)

class UserLogin(BaseModel):
    email: EmailStr
    password: str

class ForgotPasswordRequest(BaseModel):
    email: EmailStr

class VerifyOTPRequest(BaseModel):
    email: EmailStr
    otp_code: str = Field(..., min_length=6, max_length=6)

class ResetPasswordRequest(BaseModel):
    email: EmailStr
    otp_code: str = Field(..., min_length=6, max_length=6)
    new_password: str = Field(..., min_length=6)
    confirm_new_password: str


# =====================================================================
# --- 2. SCHEMAS CHO RESPONSES (DỮ LIỆU SERVER TRẢ VỀ CLIENT) ---
# =====================================================================

# Schema phản hồi chung chỉ chứa một thông báo
class MessageResponse(BaseModel):
    message: str

# Schema phản hồi có chứa thông báo kèm ID người dùng (Dùng cho cả Đăng ký bước 1 & Xác thực OTP Đăng ký bước 2)
class ActionWithUserResponse(BaseModel):
    message: str
    user_id: int

# Schema phản hồi khi Đăng nhập thành công
class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
class VerifyOTPLogin(BaseModel):
    email: EmailStr
    otp_code: str = Field(..., min_length=6, max_length=6)