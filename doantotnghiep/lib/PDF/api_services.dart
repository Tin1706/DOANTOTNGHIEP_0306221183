import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // 🟢 Khởi tạo Base URL sạch sẽ, dùng chung cho toàn bộ App
  static const String baseUrl =
      "http://localhost:8000/api/diabetes-medications";

  // 1. API Ghi nhật ký khi bấm nút "Đã uống" (Taken) hoặc hệ thống quét tự động (Missed)
  static Future<bool> createMedicationLog({
    required int userId,
    required int reminderId,
    required String status, // 'taken' hoặc 'missed'
    String? notes,
  }) async {
    try {
      final response = await http.post(
        // 🟢 Đã sửa: Đồng bộ chính xác với endpoint /logs/log-intake trong ReminderListPage
        Uri.parse('$baseUrl/logs/log-intake'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "user_id": userId,
          "reminder_id": reminderId,
          "status": status,
          "notes": notes ??
              (status == "taken"
                  ? "Người dùng chủ động bấm xác nhận"
                  : "Hệ thống tự động ghi nhận bỏ lỡ"),
        }),
      );

      // 🟢 Lưu ý: Nếu Backend trả về 201 (Created) hoặc 200 (OK) thì đều chấp nhận thành công
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return data['success'] ?? false;
      }
      print("❌ Lỗi API ghi log, Mã lỗi: ${response.statusCode}");
      return false;
    } catch (e) {
      print("❌ Lỗi hệ thống khi gọi API ghi log: $e");
      return false;
    }
  }

  // 2. API Gọi Backend tính tỉ lệ tuân thủ thực tế
  // 2. API Gọi Backend tính tỉ lệ tuân thủ thực tế
  static Future<Map<String, dynamic>?> calculateAdherence({
    required int userId,
    required String startDate,
    required String endDate,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/calculate'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "user_id": userId,
          "start_date": startDate,
          "end_date": endDate,
        }),
      );

      // 🎯 SỬA ĐOẠN KIỂM TRA ĐẦU RA NÀY:
      if (response.statusCode == 200) {
        // Trả về toàn bộ Map gốc ban đầu (bao gồm cả 'success' và 'data')
        return jsonDecode(utf8.decode(response.bodyBytes))
            as Map<String, dynamic>;
      } else {
        // Nếu lỗi (400, 422, 500...), cũng cố gắng trả về body để report_screen đọc được trường 'detail'
        return jsonDecode(utf8.decode(response.bodyBytes))
            as Map<String, dynamic>;
      }
    } catch (e) {
      print("❌ Lỗi hệ thống khi gọi API tính tỉ lệ: $e");
      return null;
    }
  }
}
