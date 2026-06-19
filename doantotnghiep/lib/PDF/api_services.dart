import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Thay đổi IP này phù hợp với máy ảo/thiết bị thật của bạn
  static const String baseUrl = "http://localhost:8000/api";

  // 1. API Ghi nhật ký khi bấm nút "Đã uống"
  static Future<bool> createMedicationLog({
    required int userId,
    required int reminderId,
    required String status, // 'taken' hoặc 'missed'
    String? notes,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/medication-logs/'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "user_id": userId,
          "reminder_id": reminderId,
          "status": status,
          "notes": notes,
        }),
      );
      if (response.statusCode == 201) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return data['success'] ?? false;
      }
      return false;
    } catch (e) {
      print("Lỗi ghi log: $e");
      return false;
    }
  }

  // 2. API Gọi Backend tính tỉ lệ tuân thủ thực tế
  // Trong file api_service.dart của Flutter:
  static Future<Map<String, dynamic>?> calculateAdherence({
    required int userId,
    required String startDate,
    required String endDate,
  }) async {
    try {
      final response = await http.post(
        // 🟢 ĐỔI ENDPOINT CHO KHỚP VỚI PREFIX CỦA ROUTER TRÊN PYTHON:
        Uri.parse('$baseUrl/diabetes-medications/calculate'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "user_id": userId,
          "start_date": startDate,
          "end_date": endDate,
        }),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(utf8.decode(response.bodyBytes));
        if (decoded['success'] == true) {
          return decoded['data'];
        }
      }
      return null;
    } catch (e) {
      print("Lỗi tính tỉ lệ: $e");
      return null;
    }
  }
}
