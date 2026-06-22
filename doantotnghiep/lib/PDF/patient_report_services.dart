import 'dart:convert';
import 'package:doantotnghiep/constant.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:doantotnghiep/PDF/patient_report_models.dart';
import 'dart:io';
class PatientReportService {
  // 🟢 Đảm bảo baseUrl nằm ở đầu class để tất cả các hàm bên dưới đều đọc được
  final String baseUrl = AppConstant.address +"/api/diabetes-medications";

  // --- HÀM 1: LẤY DỮ LIỆU JSON ---
  Future<PatientReportResponse> fetchPatientReport(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/patient-report?user_id=$userId'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        return PatientReportResponse.fromJson(data);
      } else {
        return PatientReportResponse(
          success: false,
          message: "Lỗi kết nối server: ${response.statusCode}",
        );
      }
    } catch (e) {
      return PatientReportResponse(
        success: false,
        message: "Đã xảy ra lỗi: $e",
      );
    }
  }

  // --- HÀM 2: TẢI VÀ MỞ FILE PDF ---
  Future<void> downloadAndOpenPDF(int userId) async {
    try {
      final url = Uri.parse('$baseUrl/export-pdf?user_id=$userId');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        // 🟢 1. Lấy thư mục lưu trữ ngoài của Android (Dành riêng cho các máy như Xiaomi)
        final externalDir = await getExternalStorageDirectory();
        if (externalDir == null) {
          throw Exception("Không thể truy cập bộ nhớ máy Xiaomi");
        }

        // Tạo một đường dẫn file nằm ở khu vực công khai, dễ thở hơn cho hệ thống
        final filePath = '${externalDir.path}/Bao_Cao_Benh_An_ID_$userId.pdf';
        
        // 🟢 2. Ghi đè mảng byte dữ liệu
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);

        // 🟢 3. Mở file bằng OpenFilex
        final result = await OpenFilex.open(filePath);
        
        if (result.type != ResultType.done) {
          print("Lỗi mở file trên Xiaomi: ${result.message}");
        }
      } else {
        throw Exception("Lỗi Server: ${response.statusCode}");
      }
    } catch (e) {
      print("Lỗi hệ thống PDF: $e");
      rethrow;
    }
  }
} 