import 'dart:convert';
import 'package:doantotnghiep/constant.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:doantotnghiep/PDF/patient_report_models.dart';
import 'dart:io' as io;

// 🟢 ĐỔI TỪ 'dart:html' SANG CÁI NÀY ĐỂ ANDROID KHÔNG BỊ CRASH KHI BUILD
import 'package:universal_html/html.dart' as html; 

class PatientReportService {
  // 🟢 Đảm bảo baseUrl nằm ở đầu class để tất cả các hàm bên dưới đều đọc được
  final String baseUrl = AppConstant.address + "api/diabetes-medications";

  // --- HÀM 1: LẤY DỮ LIỆU JSON ---
  Future<PatientReportResponse> fetchPatientReport(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/patient-report?user_id=$userId'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data =
            json.decode(utf8.decode(response.bodyBytes));
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
        final fileName = 'Bao_Cao_Benh_An_ID_$userId.pdf';

        // 🟢 CHẶN ĐẦU TIÊN: NẾU LÀ WEB THÌ XỬ LÝ LUÔN RỒI RETURN
        if (kIsWeb) {
          final blob = html.Blob([response.bodyBytes], 'application/pdf');
          final urlBlob = html.Url.createObjectUrlFromBlob(blob);

          final anchor = html.document.createElement('a') as html.AnchorElement
            ..href = urlBlob
            ..style.display = 'none'
            ..download = fileName;

          html.document.body?.children.add(anchor);
          anchor.click(); // Kích hoạt trình duyệt tự tải xuống thư mục Downloads

          html.document.body?.children.remove(anchor);
          html.Url.revokeObjectUrl(urlBlob);
          print("Đã tải PDF về máy qua trình duyệt web thành công!");
          return; // Dừng hàm tại đây, không chạy xuống phần code Mobile/Desktop bên dưới
        }

        // 🟢 TRƯỜNG HỢP 2: NỀN TẢNG NATIVE (MOBILE / DESKTOP APP)
        String? targetDirPath;

        // Lúc này dùng io.Platform thay vì Platform thuần để an toàn tuyệt đối
        if (io.Platform.isAndroid || io.Platform.isIOS) {
          final externalDir = await getExternalStorageDirectory();
          if (externalDir == null) {
            throw Exception("Không thể truy cập bộ nhớ thiết bị di động");
          }
          targetDirPath = externalDir.path;
        } else if (io.Platform.isWindows ||
            io.Platform.isMacOS ||
            io.Platform.isLinux) {
          final downloadsDir = await getDownloadsDirectory();
          if (downloadsDir != null) {
            targetDirPath = downloadsDir.path;
          } else {
            final documentsDir = await getApplicationDocumentsDirectory();
            targetDirPath = documentsDir.path;
          }
        } else {
          throw Exception("Nền tảng này chưa được hỗ trợ lưu file");
        }

        // Ghi file và mở file bằng OpenFilex trên Mobile/Desktop app
        final filePath = '$targetDirPath/$fileName';
        final file = io.File(filePath);
        await file.writeAsBytes(response.bodyBytes);
        print("Đã lưu file thành công tại: $filePath");

        final result = await OpenFilex.open(filePath);
        if (result.type != ResultType.done) {
          print("Lỗi mở file: ${result.message}");
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