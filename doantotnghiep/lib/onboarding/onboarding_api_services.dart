// onboarding_api_services.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class OnboardingApiService {
  // 🌟 ĐƯỜNG DẪN API BASELINE
  // Lưu ý: Nếu chạy trên điện thoại thật hoặc giả lập Android, hãy đổi 'localhost' thành IP mạng LAN hoặc '10.0.2.2'
  static const String baseUrl = 'http://localhost:8000/api/onboarding';

  // =========================================================================
  // 1. Hàm gửi toàn bộ dữ liệu hồ sơ lên Backend (Màn cuối gọi)
  // =========================================================================
  Future<Map<String, dynamic>> submitOnboarding(Map<String, dynamic> jsonData) async {
    final url = Uri.parse('$baseUrl/submit');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(jsonData),
      );

      final decodedResponse = jsonDecode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 201 || response.statusCode == 200) {
        // Trả về dữ liệu map chuẩn khi thành công
        return Map<String, dynamic>.from(decodedResponse);
      } else {
        // Xử lý lỗi nghiệp vụ từ Backend quăng ra
        throw Exception(decodedResponse['detail'] ?? 'Lỗi cấu hình từ phía Server.');
      }
    } catch (e) {
      print("🚨 [LỖI API SUBMIT]: $e");
      throw Exception('Không thể gửi dữ liệu Onboarding: $e');
    }
  }

  // =========================================================================
  // 2. Hàm lấy danh sách triệu chứng từ Dictionary
  // =========================================================================
  Future<List<Map<String, dynamic>>> getSymptoms() async {
    final url = Uri.parse('$baseUrl/symptoms');
    try {
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final List<dynamic> decodedList = jsonDecode(utf8.decode(response.bodyBytes));
        
        // 🔥 Ép kiểu an toàn từng phần tử, tránh lỗi sập Type Cast ngang xương
        return decodedList.map((e) => Map<String, dynamic>.from(e)).toList();
      } else {
        throw Exception('Server trả về mã lỗi: ${response.statusCode}');
      }
    } catch (e) {
      print("🚨 [LỖI API SYMPTOMS]: $e");
      throw Exception('Lỗi xử lý danh sách triệu chứng: $e');
    }
  }

  // =========================================================================
  // 3. Hàm lấy danh sách bệnh nền từ Dictionary
  // =========================================================================
  Future<List<Map<String, dynamic>>> getConditions() async {
    final url = Uri.parse('$baseUrl/conditions'); 

    try {
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final List<dynamic> decodedList = json.decode(utf8.decode(response.bodyBytes));
        
        // 🔥 Ép kiểu an toàn từng phần tử, giải quyết triệt để lỗi ép kiểu gây ra màn hình 500 giả
        return decodedList.map((e) => Map<String, dynamic>.from(e)).toList();
      } else {
        throw Exception('Server trả về mã lỗi: ${response.statusCode}');
      }
    } catch (e) {
      print("🚨 [LỖI API CONDITIONS]: $e");
      throw Exception('Lỗi xử lý danh sách bệnh nền: $e');
    }
  }
}