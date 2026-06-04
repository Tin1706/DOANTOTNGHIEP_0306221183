// onboarding_payload.dart
import 'dart:convert';

class OnboardingPayload {
  final int userId;
  final String dateOfBirth; // Định dạng: YYYY-MM-DD
  final int weight;
  final int height;
  final String? allergies;
  final List<int> conditionIds;
  final List<int> symptomIds;

  OnboardingPayload({
    required this.userId,        // Ép buộc phải truyền id từ màn Login
    required this.dateOfBirth,   // Ép buộc phải truyền ngày sinh từ màn Login
    this.weight = 0,
    this.height = 0,
    this.allergies,
    List<int>? conditionIds,
    List<int>? symptomIds,
  })  : conditionIds = conditionIds ?? [],
        symptomIds = symptomIds ?? [];

  // Hàm copyWith giúp cập nhật dữ liệu cuốn chiếu qua từng màn hình cực mượt
  OnboardingPayload copyWith({
    int? userId,
    String? dateOfBirth,
    int? weight,
    int? height,
    String? allergies,
    List<int>? conditionIds,
    List<int>? symptomIds,
  }) {
    return OnboardingPayload(
      userId: userId ?? this.userId,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      allergies: allergies ?? this.allergies,
      conditionIds: conditionIds ?? this.conditionIds,
      symptomIds: symptomIds ?? this.symptomIds,
    );
  }

  // Chuyển đổi sang Map để chuẩn bị mã hóa JSON gửi lên Backend FastAPI
  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'date_of_birth': dateOfBirth,
      'weight': weight,
      'height': height,
      'allergies': allergies,
      'target_low': 70,   // Ngưỡng hạ đường huyết mặc định
      'target_high': 180, // Ngưỡng tăng đường huyết mặc định
      'condition_ids': conditionIds,
      'symptom_ids': symptomIds,
    };
  }

  // Hàm xuất chuỗi JSON thô (Sử dụng trực tiếp trong body của http/dio request nếu cần)
  String toJson() => json.encode(toMap());
}