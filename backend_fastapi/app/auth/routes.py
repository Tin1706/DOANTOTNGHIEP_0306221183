from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from jose import jwt
from datetime import datetime, timezone, timedelta, time, date
import random
import bcrypt  

from app.database import get_db
from app.auth import models, schemas
from app.auth.models import UserModel as User
from app.auth.schemas import UserLogin
from app.auth.utils import send_otp_to_gmail, verify_gmail_real_existence
from app.config import settings 

router = APIRouter(prefix="/api/auth", tags=["Authentication"])


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


# TÌM ĐẾN HÀM NÀY Ở ĐẦU FILE routes.py
def create_access_token(data: dict) -> str:
    to_encode = data.copy()
    expire = datetime.now(timezone.utc) + timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
    to_encode.update({"exp": int(expire.timestamp())}) 
    
    # 🌟 SỬA DÒNG NÀY: Thay settings.ALGORITHM bằng hẳn chuỗi "HS256"
    return jwt.encode(to_encode, settings.SECRET_KEY, algorithm="HS256")


# =======================================================================
# --- 1. API ĐĂNG KÝ (BƯỚC 1: TẠO OTP "register") ---
# =======================================================================
@router.post("/register", response_model=schemas.ActionWithUserResponse, status_code=status.HTTP_200_OK)
def register(user_in: schemas.UserRegister, db: Session = Depends(get_db)):
    if user_in.password != user_in.confirm_password:
        raise HTTPException(status_code=400, detail="Mật khẩu xác nhận không khớp.")

    cleaned_email = user_in.email.strip().lower()
    user_record = db.query(models.UserModel).filter(models.UserModel.email == cleaned_email).first()
    
    if not user_record:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN, 
            detail="Địa chỉ email này không được phép đăng ký trên hệ thống!"
        )

    if user_record.full_name != "Chưa kích hoạt": 
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST, 
            detail="Tài khoản gắn liền với Email này đã được đăng ký trước đó."
        )

    try:
        otp_code = f"{random.randint(100000, 999999)}"
        actual_id = getattr(user_record, 'id', None) or getattr(user_record, 'ID', None)
        
        now_time = datetime.now(timezone.utc).replace(tzinfo=None)
        expire_time = now_time + timedelta(minutes=5)

        new_otp = models.OTPCodeModel(
            user_id=actual_id,
            otp_code=otp_code,
            is_used=0,
            created_at=now_time,
            expires_at=expire_time,
            type="register"  
        )

        db.add(new_otp)
        db.commit()  
        db.refresh(user_record) 

        send_otp_to_gmail(cleaned_email, otp_code)
        
        return {
            "message": "Mã OTP xác nhận đã được gửi thành công vào Gmail của bạn. 🎉",
            "user_id": actual_id
        }        
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=f"Lỗi hệ thống khi tạo OTP đăng ký: {str(e)}")


# =======================================================================
# --- 2. API XÁC THỰC MÃ OTP ĐĂNG KÝ (BƯỚC 2: TRANG RIÊNG KÍCH HOẠT) ---
# =======================================================================
@router.post("/verify-register-otp", response_model=schemas.ActionWithUserResponse, status_code=status.HTTP_200_OK)
def verify_register_otp(data_in: schemas.VerifyRegisterOTP, db: Session = Depends(get_db)):
    cleaned_email = data_in.email.strip().lower()

    user_record = db.query(models.UserModel).filter(models.UserModel.email == cleaned_email).first()
    if not user_record:
        raise HTTPException(status_code=404, detail="Không tìm thấy thông tin tài khoản hợp lệ!")

    actual_user_id = getattr(user_record, 'id', None) or getattr(user_record, 'ID', None)

    # 🌟 ĐÃ SỬA: Thêm bộ lọc type="register" bắt buộc để không ăn nhầm OTP quên mật khẩu
    otp_record = db.query(models.OTPCodeModel).filter(
        (models.OTPCodeModel.user_id == actual_user_id) | (getattr(models.OTPCodeModel, 'USER_ID', None) == actual_user_id),
        models.OTPCodeModel.otp_code == data_in.otp_code.strip(),
        models.OTPCodeModel.is_used == 0,
        models.OTPCodeModel.type == "register"  
    ).order_by(models.OTPCodeModel.created_at.desc()).first()

    if not otp_record:
        raise HTTPException(status_code=400, detail="Mã OTP xác thực không chính xác hoặc đã hết hạn!")

    now_utc_naive = datetime.now(timezone.utc).replace(tzinfo=None)
    if now_utc_naive > otp_record.expires_at:
        raise HTTPException(status_code=400, detail="Mã OTP này đã hết hiệu lực sử dụng!")

    try:
        dob_datetime = datetime.combine(data_in.dob, time.min)
        user_record.full_name = data_in.full_name.strip()
        
        if hasattr(user_record, 'DOB'):
            user_record.DOB = dob_datetime
        else:
            setattr(user_record, 'dob', dob_datetime)
            
        user_record.hashed_password = hash_password(data_in.password)
        otp_record.is_used = 1
        
        db.commit()
        db.refresh(user_record)

        return {
            "message": "Xác thực OTP thành công! Tài khoản của bạn đã được kích hoạt thành công. 🎉",
            "user_id": actual_user_id
        }
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=f"Lỗi hệ thống kích hoạt tài khoản: {str(e)}")


# =======================================================================
# --- 3. API ĐĂNG NHẬP TRUYỀN THỐNG (BƯỚC 3: KHÔNG ĐÒI OTP) ---
# =======================================================================
@router.post("/login", status_code=status.HTTP_200_OK)
def login(request: UserLogin, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.email == request.email.strip().lower()).first()
    
    if not user or user.full_name == "Chưa kích hoạt":
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Tài khoản của bạn chưa được kích hoạt qua OTP hoặc Email/Mật khẩu không đúng!"
        )
    
    if not verify_password(request.password, user.hashed_password): 
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Email hoặc mật khẩu không chính xác!"
        )

    token = create_access_token(data={"sub": user.email})
    user_dob = getattr(user, 'DOB', None) or getattr(user, 'dob', None)
    actual_id = getattr(user, 'id', None) or getattr(user, 'ID', None)

    return {
        "status": "success",
        "message": "Đăng nhập thành công 🎉",
        "access_token": token,
        "token_type": "bearer",
        "data": {
            "id": actual_id,              
            "full_name": user.full_name,
            "email": user.email,
            "dob": str(user_dob) if user_dob else None
        }
    }


# =======================================================================
# --- 4. API YÊU CẦU QUÊN MẬT KHẨU ---
# =======================================================================
@router.post("/forgot-password", response_model=schemas.MessageResponse)
def forgot_password(req: schemas.ForgotPasswordRequest, db: Session = Depends(get_db)):
    user = db.query(models.UserModel).filter(models.UserModel.email == req.email.strip().lower()).first()
    
    if not user or user.full_name == "Chưa kích hoạt":
        raise HTTPException(status_code=404, detail="Email không tồn tại hoặc chưa được kích hoạt trên hệ thống.")

    actual_user_id = getattr(user, 'id', None) or getattr(user, 'ID', None)
    if actual_user_id is None:
        raise HTTPException(status_code=500, detail="Không thể xác định ID của tài khoản này.")

    otp_generated = f"{random.randint(100000, 999999)}"
    now_utc_naive = datetime.now(timezone.utc).replace(tzinfo=None)
    expiration_time = now_utc_naive + timedelta(minutes=5)

    try:
        otp_data = {
            "otp_code": otp_generated,
            "is_used": 0,
            "created_at": now_utc_naive,
            "expires_at": expiration_time,
            "type": "forgot-password"  
        }

        if hasattr(models.OTPCodeModel, 'user_id'):
            otp_data["user_id"] = actual_user_id
        else:
            otp_data["USER_ID"] = actual_user_id

        otp_entry = models.OTPCodeModel(**otp_data)
        db.add(otp_entry)
        db.commit()
    except Exception as db_err:
        db.rollback()
        raise HTTPException(status_code=500, detail=f"Lỗi hệ thống khi tạo mã xác thực: {str(db_err)}")

    email_sent = send_otp_to_gmail(user.email, otp_generated)
    if not email_sent:
        raise HTTPException(status_code=500, detail="Không thể gửi email OTP lúc này.")

    return {"message": "Mã OTP xác nhận đã được gửi thành công vào Gmail của bạn."}


# =======================================================================
# --- 5. API XÁC MINH MÃ OTP ĐỔI MẬT KHẨU ---
# =======================================================================
@router.post("/verify-otp", response_model=schemas.MessageResponse)
def verify_otp(req: schemas.VerifyOTPRequest, db: Session = Depends(get_db)):
    user = db.query(models.UserModel).filter(models.UserModel.email == req.email.strip().lower()).first()
    if not user:
        raise HTTPException(status_code=404, detail="Email không hợp lệ.")

    actual_user_id = getattr(user, 'id', None) or getattr(user, 'ID', None)
    
    otp_record = db.query(models.OTPCodeModel).filter(
        (models.OTPCodeModel.user_id == actual_user_id) | (getattr(models.OTPCodeModel, 'USER_ID', None) == actual_user_id),
        models.OTPCodeModel.otp_code == req.otp_code.strip(),
        models.OTPCodeModel.is_used == 0,
        models.OTPCodeModel.type == "forgot-password"  # Chỉ bốc mã quên mật khẩu
    ).order_by(models.OTPCodeModel.created_at.desc()).first()

    if not otp_record:
        raise HTTPException(status_code=400, detail="Mã OTP không chính xác hoặc đã được sử dụng.")

    now_utc_naive = datetime.now(timezone.utc).replace(tzinfo=None)
    if now_utc_naive > otp_record.expires_at:
        raise HTTPException(status_code=400, detail="Mã OTP đã hết hiệu lực sử dụng.")

    return {"message": "Xác thực mã thành công, bạn có thể đổi mật khẩu."}


# =======================================================================
# --- 6. API ĐẶT LẠI MẬT KHẨU MỚI ---
# =======================================================================
@router.post("/reset-password", response_model=schemas.MessageResponse)
def reset_password(req: schemas.ResetPasswordRequest, db: Session = Depends(get_db)):
    if req.new_password != req.confirm_new_password:
        raise HTTPException(status_code=400, detail="Mật khẩu xác nhận mới không khớp.")

    user = db.query(models.UserModel).filter(models.UserModel.email == req.email.strip().lower()).first()
    if not user:
        raise HTTPException(status_code=404, detail="Yêu cầu không hợp lệ (Email không tồn tại).")

    actual_user_id = getattr(user, 'id', None) or getattr(user, 'ID', None)

    otp_record = db.query(models.OTPCodeModel).filter(
        (models.OTPCodeModel.user_id == actual_user_id) | (getattr(models.OTPCodeModel, 'USER_ID', None) == actual_user_id),
        models.OTPCodeModel.otp_code == req.otp_code.strip(),
        models.OTPCodeModel.is_used == 0,
        models.OTPCodeModel.type == "forgot-password"
    ).order_by(models.OTPCodeModel.created_at.desc()).first()

    if not otp_record:
        raise HTTPException(status_code=400, detail="Mã xác thực không hợp lệ hoặc đã được sử dụng.")

    now_utc_naive = datetime.now(timezone.utc).replace(tzinfo=None)
    if now_utc_naive > otp_record.expires_at:
        raise HTTPException(status_code=400, detail="Mã OTP đã hết hiệu lực sử dụng.")

    try:
        new_hashed_pwd = hash_password(req.new_password)

        # Cập nhật mật khẩu mới cho User
        db.query(models.UserModel).filter(
            (models.UserModel.id == actual_user_id) | (getattr(models.UserModel, 'ID', None) == actual_user_id)
        ).update({"hashed_password": new_hashed_pwd}, synchronize_session=False)

        # 🌟 ĐÃ SỬA LỖI 500: Cập nhật trực tiếp trên instance bản ghi đã bốc được cực an toàn
        otp_record.is_used = 1
        
        db.commit()
        return {"message": "Đổi mật khẩu mới thành công."}
        
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=f"Lỗi kết nối cơ sở dữ liệu: {str(e)}")


# =======================================================================
# --- 7. API ADMIN WHITELIST EMAIL ---
# =======================================================================
@router.post("/admin/whitelist-email", status_code=201)
def whitelist_email(email_in: schemas.ForgotPasswordRequest, db: Session = Depends(get_db)):
    now_utc_naive = datetime.now(timezone.utc).replace(tzinfo=None)
    cleaned_email = email_in.email.strip().lower()
    
    exists = db.query(models.UserModel).filter(models.UserModel.email == cleaned_email).first()
    if exists:
        raise HTTPException(status_code=400, detail="Email này đã tồn tại sẵn rồi.")
        
    try:
        fake_hashed_password = hash_password("whitelist_dummy_password_temporary")
        dummy_dob = datetime.combine(date(2000, 1, 1), time.min)

        new_preload = models.UserModel()
        new_preload.email = cleaned_email
        new_preload.full_name = "Chưa kích hoạt"
        
        if hasattr(new_preload, 'DOB'):
            setattr(new_preload, 'DOB', dummy_dob)
        else:
            setattr(new_preload, 'dob', dummy_dob)

        new_preload.hashed_password = fake_hashed_password
        new_preload.created_at = now_utc_naive
        
        db.add(new_preload)
        db.commit()
        return {"message": f"Đã nạp email {cleaned_email} vào danh sách trắng thành công!"}
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=f"Lỗi cơ sở dữ liệu khi whitelist: {str(e)}")


# =======================================================================
# --- 8. API GET OTP (DEBUG/TEST) ---
# =======================================================================
@router.get("/get-otp")
def get_otp_for_debug(email: str, db: Session = Depends(get_db)):
    user = db.query(models.UserModel).filter(models.UserModel.email == email.strip().lower()).first()
    if not user:
        raise HTTPException(status_code=404, detail="Không tìm thấy thành viên này.")
        
    actual_user_id = getattr(user, 'id', None) or getattr(user, 'ID', None)

    now_utc_naive = datetime.now(timezone.utc).replace(tzinfo=None)
    otp_record = db.query(models.OTPCodeModel).filter(
        (models.OTPCodeModel.user_id == actual_user_id) | (getattr(models.OTPCodeModel, 'USER_ID', None) == actual_user_id),
        models.OTPCodeModel.is_used == 0,
        models.OTPCodeModel.expires_at > now_utc_naive
    ).order_by(models.OTPCodeModel.created_at.desc()).first()
    
    if not otp_record:
        raise HTTPException(status_code=404, detail="Không có mã OTP nào khả dụng hoặc mã đã hết hạn.")
        
    return {"otp": str(otp_record.otp_code)}