from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from jose import jwt
from datetime import datetime, timezone, timedelta, time
import random
import bcrypt  

from app.database import get_db
from app.auth import models, schemas
from app.auth.models import UserModel as User
from app.auth.schemas import UserLogin

# --- CẤU HÌNH MÃ HÓA & JWT ---
SECRET_KEY = "50ebddfd0dd77357ec060c0fc028407cf42bfd69a17d3a814667795eae60c011" 
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 1440 

def hash_password(password: str) -> str:
    pwd_bytes = password.encode('utf-8')[:72]  
    salt = bcrypt.gensalt()
    hashed = bcrypt.hashpw(pwd_bytes, salt)
    return hashed.decode('utf-8')

def verify_password(plain_password: str, hashed_password: str) -> bool:
    try:
        plain_bytes = plain_password.encode('utf-8')[:72]  
        return bcrypt.checkpw(plain_bytes, hashed_password.encode('utf-8'))
    except Exception:
        return False

def create_access_token(data: dict) -> str:
    to_encode = data.copy()
    # 🌟 SỬA: Dùng chuẩn timezone-aware mới thay cho utcnow() cũ
    expire = datetime.now(timezone.utc) + timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    to_encode.update({"exp": int(expire.timestamp())}) 
    return jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)

# --- API ENDPOINTS ---
router = APIRouter(prefix="/api/auth", tags=["Authentication"])

# 1. API ĐĂNG KÝ
# 1. API ĐĂNG KÝ (ĐÃ SỬA LỖI TRẢ VỀ ID)
@router.post("/register", response_model=schemas.MessageResponse, status_code=status.HTTP_201_CREATED)
def register(user_in: schemas.UserRegister, db: Session = Depends(get_db)):
    if user_in.password != user_in.confirm_password:
        raise HTTPException(status_code=400, detail="Mật khẩu xác nhận không khớp.")

    user_exists = db.query(models.UserModel).filter(models.UserModel.email == user_in.email).first()
    if user_exists:
        raise HTTPException(status_code=400, detail="Địa chỉ email này đã được sử dụng.")

    dob_datetime = datetime.combine(user_in.dob, time.min)

    new_user = models.UserModel(
        full_name=user_in.full_name,
        email=user_in.email,
        DOB=dob_datetime, 
        hashed_password=hash_password(user_in.password)
    )
    db.add(new_user)
    db.commit()
    
    # 🌟 THÊM DÒNG NÀY: Bắt buộc phải refresh để đồng bộ lấy cái ID tự tăng từ MySQL lên biến new_user
    db.refresh(new_user) 

    # Bây giờ new_user.id đã có số thật (ví dụ: 2, 3..), FastAPI sẽ nhả dữ liệu về cho Flutter
    return {
        "message": "Đăng ký tài khoản thành công.",
        "user_id": new_user.id
    }

# 2. API ĐĂNG NHẬP
@router.post("/login", status_code=status.HTTP_200_OK)
def login(request: UserLogin, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.email == request.email).first()
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Email hoặc mật khẩu không chính xác!"
        )
    
    if not verify_password(request.password, user.hashed_password): 
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Email hoặc mật khẩu không chính xác!"
        )

    token = create_access_token(data={"sub": user.email})

    # Định dạng lại ngày sinh an toàn trước khi trả về cho Flutter
    user_dob = getattr(user, 'DOB', None) or getattr(user, 'dob', None)

    return {
        "status": "success",
        "message": "Đăng nhập thành công 🎉",
        "access_token": token,
        "token_type": "bearer",
        "data": {
            "id": user.id,              
            "full_name": user.full_name,
            "email": user.email,
            "dob": str(user_dob) if user_dob else None
        }
    }


# 3. API QUÊN MẬT KHẨU
# --- 3. API QUÊN MẬT KHẨU ---
@router.post("/forgot-password", response_model=schemas.MessageResponse)
def forgot_password(req: schemas.ForgotPasswordRequest, db: Session = Depends(get_db)):
    user = db.query(models.UserModel).filter(models.UserModel.email == req.email).first()
    if not user:
        raise HTTPException(status_code=404, detail="Email không tồn tại trên hệ thống.")

    otp_generated = f"{random.randint(100000, 999999)}"
    
    # 🌟 SỬA: Dùng datetime.utcnow() (Naive) để khớp 100% với cấu hình trong models.py
    expiration_time = datetime.utcnow() + timedelta(minutes=5)

    otp_entry = models.OTPCodeModel(
        user_id=user.id,
        otp_code=otp_generated,
        is_used=0,
        expires_at=expiration_time
    )
    db.add(otp_entry)
    db.commit()

    print(f"\n[MÃ OTP XÁC NHẬN CỦA BẠN LÀ]: {otp_generated}\n")
    return {"message": "Mã OTP xác nhận đã được tạo thành công."}


# --- 4. API XÁC MINH MÃ OTP ---
@router.post("/verify-otp", response_model=schemas.MessageResponse)
def verify_otp(req: schemas.VerifyOTPRequest, db: Session = Depends(get_db)):
    user = db.query(models.UserModel).filter(models.UserModel.email == req.email).first()
    if not user:
        raise HTTPException(status_code=404, detail="Email không hợp lệ.")

    otp_record = db.query(models.OTPCodeModel).filter(
        models.OTPCodeModel.user_id == user.id,
        models.OTPCodeModel.otp_code == req.otp_code,
        models.OTPCodeModel.is_used == 0
    ).order_by(models.OTPCodeModel.created_at.desc()).first()

    if not otp_record:
        raise HTTPException(status_code=400, detail="Mã OTP không chính xác hoặc đã được sử dụng.")

    # 🌟 SỬA: So sánh naive thuần túy với datetime.utcnow(), không dùng replace(tzinfo) nữa để tránh lỗi crash ngầm
    if datetime.utcnow() > otp_record.expires_at:
        raise HTTPException(status_code=400, detail="Mã OTP đã hết hiệu lực sử dụng.")

    return {"message": "Xác thực mã thành công, bạn có thể đổi mật khẩu."}


# --- 5. API ĐẶT LẠI MẬT KHẨU MỚI ---
@router.post("/reset-password", response_model=schemas.MessageResponse)
def reset_password(req: schemas.ResetPasswordRequest, db: Session = Depends(get_db)):
    if req.new_password != req.confirm_new_password:
        raise HTTPException(status_code=400, detail="Mật khẩu xác nhận mới không khớp.")

    user = db.query(models.UserModel).filter(models.UserModel.email == req.email).first()
    if not user:
        raise HTTPException(status_code=404, detail="Yêu cầu không hợp lệ (Email không tồn tại).")

    otp_record = db.query(models.OTPCodeModel).filter(
        models.OTPCodeModel.user_id == user.id,
        models.OTPCodeModel.otp_code == req.otp_code,
        models.OTPCodeModel.is_used == 0
    ).order_by(models.OTPCodeModel.created_at.desc()).first()

    if not otp_record:
        raise HTTPException(status_code=400, detail="Mã xác thực không hợp lệ hoặc đã được sử dụng.")

    # 🌟 SỬA: Đồng bộ so sánh naive cực kỳ an toàn cho database
    if datetime.utcnow() > otp_record.expires_at:
        raise HTTPException(status_code=400, detail="Mã OTP đã hết hiệu lực sử dụng.")

    try:
        new_hashed_pwd = hash_password(req.new_password)

        db.query(models.UserModel).filter(models.UserModel.id == user.id).update(
            {"hashed_password": new_hashed_pwd}, 
            synchronize_session=False
        )

        db.query(models.OTPCodeModel).filter(models.OTPCodeModel.id == otp_record.id).update(
            {"is_used": 1}, 
            synchronize_session=False
        )
        
        db.commit()
        return {"message": "Đổi mật khẩu mới thành công."}
        
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=f"Lỗi kết nối cơ sở dữ liệu: {str(e)}")

# 6. API LẤY MÃ OTP (DÀNH CHO FLUTTER APP)
@router.get("/get-otp")
def get_otp(email: str, db: Session = Depends(get_db)):
    user = db.query(models.UserModel).filter(models.UserModel.email == email).first()
    if not user:
        raise HTTPException(status_code=404, detail="Email không tồn tại trên hệ thống.")

    otp_record = db.query(models.OTPCodeModel).filter(
        models.OTPCodeModel.user_id == user.id,
        models.OTPCodeModel.is_used == 0
    ).order_by(models.OTPCodeModel.created_at.desc()).first()

    if not otp_record:
        raise HTTPException(status_code=404, detail="Không tìm thấy mã OTP khả dụng.")

    return {"otp": otp_record.otp_code}