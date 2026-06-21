import json

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from fastapi.responses import StreamingResponse
# Import các thành phần cần thiết từ dự án của bạn
# Hãy điều chỉnh lại đường dẫn import (app.pdf...) cho đúng với cấu trúc thư mục thực tế
from app.pdf import services  
from app.pdf import schemas   # Hoặc import trực tiếp từ app.schemas nếu bạn để file schema ở ngoài
from app.database import get_db
import io  
import os
from reportlab.lib.pagesizes import letter 
from reportlab.pdfgen import canvas  
from reportlab.pdfbase import pdfmetrics 
from reportlab.pdfbase.ttfonts import TTFont
from reportlab.platypus import Paragraph
from reportlab.lib.styles import ParagraphStyle
router = APIRouter(
    prefix="/api/diabetes-medications",
    tags=["Patient Report"]
)

@router.get("/patient-report", response_model=schemas.PatientReportResponse)
def get_patient_report(user_id: int, db: Session = Depends(get_db)):
    try:
        # Gọi hàm xử lý logic từ file services.py đã kết nối Database thực tế
        report_data = services.get_patient_report_data(db, user_id=user_id)
        
        # Nếu không tìm thấy hồ sơ bệnh nhân (bảng patient_profiles chưa có dữ liệu)
        if not report_data:
            return schemas.PatientReportResponse(
                success=False,
                message="Không tìm thấy hồ sơ thông tin cho bệnh nhân này. Vui lòng cập nhật profile trước.",
                data=None
            )
            
        # Trả về dữ liệu thành công chuẩn cấu trúc Pydantic Schema cho Flutter
        return schemas.PatientReportResponse(
            success=True,
            message="Tải hồ sơ bệnh án thành công!",
            data=report_data
        )
        
    except Exception as e:
        # Trả về lỗi 500 nếu hệ thống Backend gặp sự cố trong quá trình query dữ liệu
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Lỗi hệ thống Backend khi tạo báo cáo: {str(e)}"
        )
@router.get("/export-pdf")
def export_patient_report_pdf(user_id: int, db: Session = Depends(get_db)):
    try:
        report_data = services.get_patient_report_data(db, user_id=user_id)
        if not report_data:
            raise HTTPException(status_code=404, detail="Không tìm thấy hồ sơ bệnh nhân")

        buffer = io.BytesIO()
        p = canvas.Canvas(buffer, pagesize=letter)
        
        # Mặc định dự phòng font
        font_regular = 'Helvetica'
        font_bold = 'Helvetica-Bold'
        
        # Đọc font động từ thư mục app/fonts/
        current_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
        font_path = os.path.join(current_dir, "fonts", "arial.ttf")
        font_bold_path = os.path.join(current_dir, "fonts", "arialbd.ttf")
        
        if os.path.exists(font_path) and os.path.exists(font_bold_path):
            pdfmetrics.registerFont(TTFont('ArialCustom', font_path))
            pdfmetrics.registerFont(TTFont('ArialCustom-Bold', font_bold_path))
            font_regular = 'ArialCustom'
            font_bold = 'ArialCustom-Bold'

        # --- TIẾN HÀNH VẼ GIAO DIỆN PDF ---
        
        # 1. Vẽ Khung Viền Xanh Cyan bao quanh (Mép lề cách 30 đơn vị)
        p.setStrokeColorRGB(0.0, 0.749, 1.0) 
        p.setLineWidth(5)
        p.rect(30, 30, 552, 732) 
        
        p.setFillColorRGB(0, 0, 0)
        y = 720 # Tọa độ trục Y đi từ trên xuống
        
        # 2. Điền các thông tin hành chính cơ bản (Chuỗi ngắn cố định)
        p.setFont(font_bold, 13)
        p.drawString(50, y, "Họ và tên:")
        p.setFont(font_regular, 13)
        p.drawString(130, y, f"{report_data.get('name', 'N/A')}")
        
        p.setFont(font_bold, 13)
        p.drawString(340, y, "Tuổi:")
        p.setFont(font_regular, 13)
        p.drawString(380, y, f"{report_data.get('age', 'N/A')}")
        
        y -= 25
        p.setFont(font_bold, 13)
        p.drawString(50, y, "Chiều cao:")
        p.setFont(font_regular, 13)
        p.drawString(130, y, f"{report_data.get('height', 'N/A')}cm")
        
        p.setFont(font_bold, 13)
        p.drawString(340, y, "Cân nặng:")
        p.setFont(font_regular, 13)
        p.drawString(420, y, f"{report_data.get('weight', 'N/A')}kg")
        
        # 3. Điền các chỉ số sức khỏe trung bình định dạng cố định
        y -= 30
        fixed_metrics = [
            ("Đường huyết:", f"{report_data.get('blood_sugar', 'N/A')}  (Trung bình) (7 ngày)"),
            ("Huyết áp tâm thu:", f"{report_data.get('systolic', 'N/A')} mmHg  (Trung bình) (7 ngày)"),
            ("Huyết áp tâm trương:", f"{report_data.get('diastolic', 'N/A')} mmHg  (Trung bình) (7 ngày)"),
            ("Nhịp tim:", f"{report_data.get('heart_rate', 'N/A')} bpm  (Trung bình) (7 ngày)")
        ]
        
        for label, val in fixed_metrics:
            p.setFont(font_bold, 13)
            p.drawString(50, y, label)
            p.setFont(font_regular, 13)
            p.drawString(190, y, f" {val}")
            y -= 25

        # 🟢 4. KHỐI XỬ LÝ XUỐNG DÒNG TỰ ĐỘNG CHO BỆNH NỀN, TRIỆU CHỨNG, DỊ ỨNG
        # Khởi tạo kiểu định dạng chữ xuống dòng tương thích Font tiếng Việt
        style_regular = ParagraphStyle(
            'VietnameseWrap',
            fontName=font_regular,
            fontSize=13,
            leading=18  # Khoảng cách giữa các dòng khi xuống hàng
        )
        
        # Định dạng tiền xử lý dữ liệu (Nếu mảng JSON dạng ["A", "B"] thì nối lại thành chuỗi "A, B")
        def format_dynamic_text(input_data):
            if isinstance(input_data, list):
                return ", ".join(input_data)
            try:
                # Trường hợp nhận vào dạng chuỗi biểu diễn mảng chưa parse
                parsed = json.loads(input_data)
                if isinstance(parsed, list):
                    return ", ".join(parsed)
            except Exception:
                pass
            return str(input_data)

        dynamic_metrics = [
            ("Bệnh nền:", format_dynamic_text(report_data.get('underlying_disease', 'Không có'))),
            ("Triệu chứng:", format_dynamic_text(report_data.get('symptoms', 'Không có'))),
            ("Dị ứng:", format_dynamic_text(report_data.get('allergy', 'Không có')))
        ]

        # Vùng giới hạn chiều rộng chữ có thể vẽ (từ X=190 đến X=540 -> Rộng 350 đơn vị)
        wrap_width = 350 

        for label, text_content in dynamic_metrics:
            # Vẽ tiêu đề nhãn chữ đậm trước
            p.setFont(font_bold, 13)
            p.drawString(50, y, label)
            
            # Tạo một Paragraph để tự động tính toán bẻ dòng văn bản
            story_p = Paragraph(text_content, style_regular)
            
            # Tính toán kích thước xem đoạn văn này chiếm bao nhiêu chiều cao dựa trên độ rộng giới hạn
            p_width, p_height = story_p.wrap(wrap_width, y)
            
            # Vẽ Paragraph xuống tọa độ đích (X=190, Y=y trừ đi chiều cao của nó để text căn đỉnh dọc hàng ngang)
            story_p.drawOn(p, 190, y - p_height + 10)
            
            # Trừ trục Y động dựa vào độ dài thực tế văn bản vừa chiếm dụng
            y -= max(p_height, 20) + 8

        # 5. Tạo Khung Bảng Chứa Danh Sách Thuốc Điều Trị
        y -= 15
        table_top_y = y 
        
        p.setFont(font_bold, 13)
        p.drawCentredString(306, y - 20, "Bảng thuốc điều trị") 
        
        y_med_line = y - 45
        medications_list = report_data.get('medications', [])
        
        if not medications_list:
            p.setFont(font_regular, 12)
            p.drawCentredString(306, y_med_line, "Không có chỉ định thuốc lâm sàng.")
            y_med_line -= 25
        else:
            for idx, med in enumerate(medications_list, start=1):
                p.setFont(font_bold, 12)
                p.drawString(70, y_med_line, f"{idx}. Tên thuốc:")
                p.setFont(font_regular, 12)
                p.drawString(150, y_med_line, f"{med.get('name', '')}")
                
                p.setFont(font_bold, 12)
                p.drawString(360, y_med_line, "Liều lượng:")
                p.setFont(font_regular, 12)
                p.drawString(440, y_med_line, f"{med.get('dosage', '')}")
                y_med_line -= 25 

        # Vẽ hộp bao quanh bảng thuốc
        p.setStrokeColorRGB(0.3, 0.3, 0.3) 
        p.setLineWidth(1)
        p.rect(50, y_med_line + 10, 512, table_top_y - y_med_line - 10)

        # Hoàn thiện xuất trang PDF
        p.showPage()
        p.save()
        buffer.seek(0)
        
        return StreamingResponse(
            buffer, 
            media_type="application/pdf", 
            headers={
                "Content-Disposition": f"attachment; filename=report_{user_id}.pdf",
                "Access-Control-Expose-Headers": "Content-Disposition"
            }
        )
    except Exception as e:
        print(f"Lỗi tạo PDF: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))