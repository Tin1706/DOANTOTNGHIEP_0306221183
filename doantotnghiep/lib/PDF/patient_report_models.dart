class PatientReportResponse {
  final bool success;
  final String message;
  final PatientReportData? data;

  PatientReportResponse({required this.success, required this.message, this.data});

  factory PatientReportResponse.fromJson(Map<String, dynamic> json) {
    return PatientReportResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? PatientReportData.fromJson(json['data']) : null,
    );
  }
}

class PatientReportData {
  final String name;
  final int age;
  final int height;
  final int weight;
  final String bloodSugar;
  final String systolic;
  final String diastolic;
  final String heartRate;
  final String underlyingDisease;
  final String symptoms;
  final String allergy;
  final List<MedicationInfo> medications;

  PatientReportData({
    required this.name,
    required this.age,
    required this.height,
    required this.weight,
    required this.bloodSugar,
    required this.systolic,
    required this.diastolic,
    required this.heartRate,
    required this.underlyingDisease,
    required this.symptoms,
    required this.allergy,
    required this.medications,
  });

  factory PatientReportData.fromJson(Map<String, dynamic> json) {
    var list = json['medications'] as List? ?? [];
    List<MedicationInfo> medList = list.map((i) => MedicationInfo.fromJson(i)).toList();

    // 🟢 SỬ DỤNG .toInt() HOẶC .toString() ĐỂ TRÁNH LỖI ĐỊNH DẠNG TỪ BACKEND
    return PatientReportData(
      name: json['name'] ?? '',
      // Dùng num.parse hoặc ép kiểu thông minh đề phòng dữ liệu trả về dạng double từ phép tính
      age: json['age'] is num ? (json['age'] as num).toInt() : 0,
      height: json['height'] is num ? (json['height'] as num).toInt() : 0,
      weight: json['weight'] is num ? (json['weight'] as num).toInt() : 0,
      
      // Chuyển toàn bộ chỉ số thành String an toàn để hiển thị text dạng "150.89 mg/dL (7 ngày)"
      bloodSugar: json['blood_sugar']?.toString() ?? 'Chưa đo',
      systolic: json['systolic']?.toString() ?? 'Chưa đo',
      diastolic: json['diastolic']?.toString() ?? 'Chưa đo',
      heartRate: json['heart_rate']?.toString() ?? 'Chưa đo',
      
      underlyingDisease: json['underlying_disease'] ?? 'Không có',
      symptoms: json['symptoms'] ?? 'Không có',
      allergy: json['allergy'] ?? 'Không có',
      medications: medList,
    );
  }
}

class MedicationInfo {
  final String name;
  final String dosage;

  MedicationInfo({required this.name, required this.dosage});

  factory MedicationInfo.fromJson(Map<String, dynamic> json) {
    return MedicationInfo(
      name: json['name'] ?? '',
      dosage: json['dosage']?.toString() ?? 'Theo chỉ định',
    );
  }
}