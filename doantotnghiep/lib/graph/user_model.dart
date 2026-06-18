class UserModel {
  final int id;
  final String name;
  final String email;
  final int? age;

  // 🟢 THÊM CÁC THÔNG SỐ LÂM SÀNG LẤY TỪ DATABASE
  final double? height;
  final double? weight;
  final String? medicalHistory;
  final String? symptoms;
  final String? allergies;

  // CÁC CHỈ SỐ TRUNG BÌNH (7 NGÀY)
  final double? avgBloodSugar;
  final double? avgSystolicBp;
  final double? avgDiastolicBp;
  final double? avgHeartRate;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.age,
    this.height,
    this.weight,
    this.medicalHistory,
    this.symptoms,
    this.allergies,
    this.avgBloodSugar,
    this.avgSystolicBp,
    this.avgDiastolicBp,
    this.avgHeartRate,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final rawAge = json['Age'] ?? json['age'];
    final avg = json['average_metrics'] ?? json['averageMetrics'] ?? {};

    return UserModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      name: json['full_name'] ?? json['name'] ?? '',
      email: json['email'] ?? '',
      age: rawAge != null ? int.tryParse(rawAge.toString()) : null,

      // 🟢 PARSE ĐỘNG CÁC THÔNG TIN LÂM SÀNG (Đề phòng null hoặc sai kiểu dữ liệu)
      height: json['height'] != null ? double.tryParse(json['height'].toString()) : null,
      weight: json['weight'] != null ? double.tryParse(json['weight'].toString()) : null,
      medicalHistory: json['medical_history'] ?? json['medicalHistory'] ?? 'Không có',
      symptoms: json['symptoms'] ?? 'Không có',
      allergies: json['allergies'] ?? 'Không có',

      // PARSE CÁC CHỈ SỐ TRUNG BÌNH
      avgBloodSugar: avg['avg_blood_sugar'] != null ? double.tryParse(avg['avg_blood_sugar'].toString()) : null,
      avgSystolicBp: avg['avg_systolic_bp'] != null ? double.tryParse(avg['avg_systolic_bp'].toString()) : null,
      avgDiastolicBp: avg['avg_diastolic_bp'] != null ? double.tryParse(avg['avg_diastolic_bp'].toString()) : null,
      avgHeartRate: avg['avg_heart_rate'] != null ? double.tryParse(avg['avg_heart_rate'].toString()) : null,
    );
  }
}