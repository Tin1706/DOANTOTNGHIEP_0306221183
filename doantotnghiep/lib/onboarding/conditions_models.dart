// condition_model.dart
import 'dart:convert';

class ConditionModel {
  final int id;
  final String conditionName;
  final String? description; // Cho phép null nếu CSDL không có mô tả

  ConditionModel({
    required this.id,
    required this.conditionName,
    this.description,
  });

  // 1. Hàm chuyển đổi từ Map (JSON đã decode) sang Object ConditionModel
  factory ConditionModel.fromMap(Map<String, dynamic> map) {
    return ConditionModel(
      id: map['id'] as int,
      conditionName: map['condition_name'] as String, // Khớp với tên cột trong MySQL
      description: map['description'] != null ? map['description'] as String : null,
    );
  }

  // 2. Hàm chuyển đổi từ chuỗi JSON thô sang Object
  factory ConditionModel.fromJson(String source) => 
      ConditionModel.fromMap(json.decode(source) as Map<String, dynamic>);

  // 3. Hàm chuyển ngược từ Object sang Map JSON (Nếu cần gửi lên)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'condition_name': conditionName,
      'description': description,
    };
  }

  String toJson() => json.encode(toMap());
}