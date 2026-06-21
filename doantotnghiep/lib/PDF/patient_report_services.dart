import 'dart:convert';
import 'dart:io' as io; 
import 'package:flutter/foundation.dart' show kIsWeb; 
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:doantotnghiep/PDF/patient_report_models.dart';

class PatientReportService {
  // 🟢 Đảm bảo baseUrl nằm ở đầu class để tất cả các hàm bên dưới đều đọc được
  final String baseUrl = "http://127.0.0.1:8000/api/diabetes-medications";

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
    final String urlString = '$baseUrl/export-pdf?user_id=$userId';
    final Uri url = Uri.parse(urlString);

    // Xử lý môi trường Web
    if (kIsWeb) {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        throw Exception("Không thể kích hoạt lệnh tải file trên trình duyệt.");
      }
      return; 
    }

    // Xử lý môi trường Mobile (Android/iOS)
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final directory = await getTemporaryDirectory();
        final filePath = '${directory.path}/Bao_Cao_Benh_An_ID_$userId.pdf';
        
        final file = io.File(filePath);
        await file.writeAsBytes(response.bodyBytes);

        final result = await OpenFilex.open(filePath);
        if (result.type != ResultType.done) {
          print("Không thể mở file trên điện thoại: ${result.message}");
        }
      } else {
        throw Exception("Server trả về lỗi: ${response.statusCode}");
      }
    } catch (e) {
      print("Lỗi xử lý file trên Mobile: $e");
      rethrow;
    }
  }
} 