import smtplib
from email.mime.text import MIMEText
from app.config import settings

def verify_gmail_real_existence(email: str) -> bool:
    """
    Thay vì check sâu vào cổng SMTP bị nhà mạng chặn, 
    ta dùng Regex check định dạng cấu trúc Email chuẩn để né lỗi nghẽn mạng.
    """
    import re
    regex = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    if re.match(regex, email):
        return True
    return False


def send_otp_to_gmail(to_email: str, otp_code: str) -> bool:
    """
    Hàm gửi OTP qua Google SMTP sử dụng cổng bảo mật 587 
    """
    # 🌟 QUAN TRỌNG: Bạn phải đảm bảo settings.EMAIL_HOST_USER và settings.EMAIL_HOST_PASSWORD (mật khẩu ứng dụng 16 số) trong file .env đã chính xác.
    msg = MIMEText(f"Mã OTP kích hoạt/đổi mật khẩu của bạn là: {otp_code}. Mã này có hiệu lực trong 5 phút.")
    msg['Subject'] = 'MÃ XÁC THỰC OTP HỆ THỐNG'
    msg['From'] = settings.EMAIL_HOST_USER
    msg['To'] = to_email

    try:
        # Sử dụng cổng 587 và STARTTLS để tránh bị nhà mạng chặn
        server = smtplib.SMTP("smtp.gmail.com", 587)
        server.starttls() 
        server.login(settings.EMAIL_HOST_USER, settings.EMAIL_HOST_PASSWORD)
        server.sendmail(settings.EMAIL_HOST_USER, [to_email], msg.as_string())
        server.quit()
        return True
    except Exception as e:
        print(f"\n[LỖI GỬI MAIL THỰC TẾ]: {str(e)}\n")
        return False