// onboarding_api_services.dart
import 'dart:convert';
import 'package:doantotnghiep/constant.dart';
import 'package:http/http.dart' as http;

class OnboardingApiService {
  // 🌟 ĐƯỜNG DẪN API BASELINE
  // Lưu ý: Nếu chạy trên điện thoại thật hoặc giả lập Android, hãy đổi 'localhost' thành IP mạng LAN hoặc '10.0.2.2'
  static const String baseUrl = AppConstant.address + '/api/onboarding';

  // =========================================================================
  // 1. Hàm gửi toàn bộ dữ liệu hồ sơ lên Backend (Màn cuối gọi)
  // =========================================================================
  Future<Map<String, dynamic>> submitOnboarding(
      Map<String, dynamic> jsonData) async {
    final url = Uri.parse('$baseUrl/submit');

    try {
      print(
          "🔄 [HỆ THỐNG]: Đang tiến hành gộp và map mảng ID sang mảng chữ từ Dictionary...");

      // A. XỬ LÝ GỘP LUỒNG BỆNH NỀN (pre_existing_conditions)
      if (jsonData.containsKey('condition_ids') &&
          jsonData['condition_ids'] != null) {
        List<int> conditionIds = List<int>.from(jsonData['condition_ids']);
        List<Map<String, dynamic>> conditionsDict = await getConditions();
        List<String> conditionNames = [];

        for (var item in conditionsDict) {
          int dbId = int.parse(item['id'].toString());
          if (conditionIds.contains(dbId)) {
            if (item['condition_name'] != null) {
              conditionNames.add(item['condition_name'].toString());
            }
          }
        }
        jsonData['pre_existing_conditions'] = conditionNames;
      } else if (!jsonData.containsKey('pre_existing_conditions')) {
        jsonData['pre_existing_conditions'] = [];
      }

      // B. XỬ LÝ GỘP LUỒNG TRIỆU CHỨNG (symptoms)
      if (jsonData.containsKey('symptom_ids') &&
          jsonData['symptom_ids'] != null) {
        List<int> symptomIds = List<int>.from(jsonData['symptom_ids']);
        List<Map<String, dynamic>> symptomsDict = await getSymptoms();
        List<String> symptomNames = [];

        for (var item in symptomsDict) {
          int dbId = int.parse(item['id'].toString());
          if (symptomIds.contains(dbId)) {
            if (item['symptom_name'] != null) {
              symptomNames.add(item['symptom_name'].toString());
            } else if (item['name'] != null) {
              symptomNames.add(item['name'].toString());
            }
          }
        }
        jsonData['symptoms'] = symptomNames;
      } else if (!jsonData.containsKey('symptoms')) {
        jsonData['symptoms'] = [];
      }

      // C. CHẶN LỖI NULL GIÁ TRỊ TARGET ĐỂ BẢO VỆ MYSQL
      if (!jsonData.containsKey('target_low') ||
          jsonData['target_low'] == null) {
        jsonData['target_low'] = 70;
      }
      if (!jsonData.containsKey('target_high') ||
          jsonData['target_high'] == null) {
        jsonData['target_high'] = 180;
      }

      print("🚀 [PAYLOAD GỘP CHUẨN]: $jsonData");

      // Tiến hành bắn cục JSON tổng hợp sang Backend FastAPI
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(jsonData),
      );

      final decodedResponse = jsonDecode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 201 || response.statusCode == 200) {
        return Map<String, dynamic>.from(decodedResponse);
      } else {
        throw Exception(
            decodedResponse['detail'] ?? 'Lỗi cấu hình từ phía Server.');
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
        final List<dynamic> decodedList =
            jsonDecode(utf8.decode(response.bodyBytes));
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
        final List<dynamic> decodedList =
            json.decode(utf8.decode(response.bodyBytes));
        return decodedList.map((e) => Map<String, dynamic>.from(e)).toList();
      } else {
        throw Exception('Server trả về mã lỗi: ${response.statusCode}');
      }
    } catch (e) {
      print("🚨 [LỖI API CONDITIONS]: $e");
      throw Exception('Lỗi xử lý danh sách bệnh nền: $e');
    }
  }

  // =========================================================================
  // 2. Hàm lấy danh sách triệu chứng từ Dictionary
  // =========================================================================
}
