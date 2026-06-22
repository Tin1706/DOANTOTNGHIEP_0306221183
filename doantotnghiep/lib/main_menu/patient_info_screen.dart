import 'package:doantotnghiep/auth/login_screen.dart';
import 'package:doantotnghiep/main_menu/update_health_screen.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart'; // Đã thêm import Dio thành công
import 'package:doantotnghiep/graph/user_model.dart';
import 'dart:convert'; // 🌟 Bắt buộc phải có để dùng jsonDecode

class PatientInfoScreen extends StatefulWidget {
  final UserModel user;

  const PatientInfoScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<PatientInfoScreen> createState() => _PatientInfoScreenState();
}

class _PatientInfoScreenState extends State<PatientInfoScreen> {
  // 🟢 Khai báo các biến lưu dữ liệu động kéo từ các API về
  bool _isLoading = true;
  int? _age;
  double? _height;
  double? _weight;
  String? _medicalHistory;
  String? _symptoms;
  String? _allergies;

  double? _avgBloodSugar;
  double? _avgSystolicBp;
  double? _avgDiastolicBp;
  double? _avgHeartRate;

  @override
  void initState() {
    super.initState();
    _fetchPatientData(); // Tự động kéo dữ liệu khi màn hình được bật lên
  }

  // 🟢 Hàm kết hợp gọi song song 2 API (Onboarding & Health Metrics)
  // 🟢 Hàm kết hợp gọi song song 2 API (Onboarding & Health Metrics)
  // ======================================================================
  // 🚀 HÀM KHÁNG LỖI PARSE: Tự động bóc tách Mảng/Chuỗi JSON từ Database
  // ======================================================================
  Future<void> _fetchPatientData() async {
    try {
      final dio = Dio();
      final int userId = widget.user.id;

      // 1. Gọi API lấy thông tin cá nhân (Cụm onboarding)
      final infoResponse =
          await dio.get('http://192.168.0.236:8000/api/onboarding/$userId');

      // 2. Gọi API lấy chỉ số trung bình sức khỏe 7 ngày
      final avgResponse = await dio.get(
          'http://192.168.0.236:8000/api/health-metrics/average?user_id=$userId&days=7');

      print("🎁 DỮ LIỆU ONBOARDING CHUẨN: ${infoResponse.data}");
      print("🎁 DỮ LIỆU TRUNG BÌNH THỰC TẾ LÀ: ${avgResponse.data}");

      if (infoResponse.statusCode == 200 && infoResponse.data != null) {
        Map<String, dynamic> infoData;
        final rawInfo = infoResponse.data;

        if (rawInfo is Map<String, dynamic>) {
          if (rawInfo.containsKey('results') &&
              rawInfo['results'] is Map<String, dynamic>?) {
            infoData = rawInfo['results'] ?? {};
          } else if (rawInfo.containsKey('data') &&
              rawInfo['data'] is Map<String, dynamic>?) {
            infoData = rawInfo['data'] ?? {};
          } else {
            infoData = rawInfo;
          }
        } else {
          infoData = {};
        }

        Map<String, dynamic>? avgData;
        if (avgResponse.statusCode == 200 && avgResponse.data != null) {
          final rawData = avgResponse.data;
          if (rawData is Map<String, dynamic>) {
            avgData = rawData.containsKey('data') &&
                    rawData['data'] is Map<String, dynamic>
                ? rawData['data']
                : rawData;
          }
        }

        setState(() {
          // --- A. Gán dữ liệu cơ bản dạng Số ---
          _age = infoData['Age'] != null
              ? int.tryParse(infoData['Age'].toString())
              : null;
          _height = infoData['height'] != null
              ? double.tryParse(infoData['height'].toString())
              : null;
          _weight = infoData['weight'] != null
              ? double.tryParse(infoData['weight'].toString())
              : null;
          _allergies = infoData['allergies']?.toString() ?? "Không có";

          // --- B. GIẢI MÃ BỆNH NỀN (Hỗ trợ cả List dynamic và String JSON) ---
          var rawConditions =
              infoData['pre_existing_conditions'] ?? infoData['conditions'];
          if (rawConditions != null) {
            if (rawConditions is List) {
              // Trường hợp API trả thẳng về mảng
              _medicalHistory = rawConditions.isNotEmpty
                  ? rawConditions.join(', ')
                  : "Không có";
            } else {
              // Trường hợp API trả về chuỗi kí tự đại diện mảng hoặc chuỗi thô
              String condStr = rawConditions.toString().trim();
              if (condStr.startsWith('[') && condStr.endsWith(']')) {
                try {
                  List<dynamic> parsedList = jsonDecode(condStr);
                  _medicalHistory = parsedList.isNotEmpty
                      ? parsedList.join(', ')
                      : "Không có";
                } catch (e) {
                  _medicalHistory = condStr
                      .replaceAll('[', '')
                      .replaceAll(']', '')
                      .replaceAll('"', '')
                      .trim();
                }
              } else {
                _medicalHistory = condStr.isNotEmpty ? condStr : "Không có";
              }
            }
          } else {
            _medicalHistory = "Không có";
          }

          // --- C. GIẢI MÃ TRIỆU CHỨNG (Hỗ trợ cả List dynamic và String JSON) ---
          var rawSymptoms = infoData['symptoms'];
          if (rawSymptoms != null) {
            if (rawSymptoms is List) {
              _symptoms =
                  rawSymptoms.isNotEmpty ? rawSymptoms.join(', ') : "Không có";
            } else {
              String symStr = rawSymptoms.toString().trim();
              if (symStr.startsWith('[') && symStr.endsWith(']')) {
                try {
                  List<dynamic> parsedList = jsonDecode(symStr);
                  _symptoms = parsedList.isNotEmpty
                      ? parsedList.join(', ')
                      : "Không có";
                } catch (e) {
                  _symptoms = symStr
                      .replaceAll('[', '')
                      .replaceAll(']', '')
                      .replaceAll('"', '')
                      .trim();
                }
              } else {
                _symptoms = symStr.isNotEmpty ? symStr : "Không có";
              }
            }
          } else {
            _symptoms = "Không có";
          }

          // --- D. Gán khối chỉ số đo trung bình ---
          _avgBloodSugar = avgData?['avg_blood_sugar'] != null
              ? double.tryParse(avgData!['avg_blood_sugar'].toString())
              : null;
          _avgSystolicBp = avgData?['avg_systolic_bp'] != null
              ? double.tryParse(avgData!['avg_systolic_bp'].toString())
              : null;
          _avgDiastolicBp = avgData?['avg_diastolic_bp'] != null
              ? double.tryParse(avgData!['avg_diastolic_bp'].toString())
              : null;
          _avgHeartRate = avgData?['avg_heart_rate'] != null
              ? double.tryParse(avgData!['avg_heart_rate'].toString())
              : null;

          _isLoading = false;
        });
      }
    } catch (e) {
      print("🚨 Lỗi hệ thống khi fetch dữ liệu đồ án: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF00BCD4);

    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 22),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          "Thông tin bệnh nhân",
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                    color:
                        Colors.white)) // Hiện vòng loading khi đợi API trả về
            : SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24.0, vertical: 10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 🟢 1. KHỐI THÔNG TIN CÁ NHÂN LẤY ĐỘNG 100% TỪ DATABASE BIẾN ĐỘNG _
                      _buildInfoRow("Tên bệnh nhân :", widget.user.name,
                          isBold: true),
                      _buildInfoRow(
                          "Tuổi:", _age != null ? "$_age" : "Chưa cập nhật"),
                      _buildInfoRow("Địa chỉ email:", widget.user.email),
                      _buildInfoRow(
                          "Chiều cao:",
                          _height != null
                              ? "${_height!.toStringAsFixed(0)}cm"
                              : "Chưa đo"),
                      _buildInfoRow(
                          "Cân nặng:",
                          _weight != null
                              ? "${_weight!.toStringAsFixed(0)}kg"
                              : "Chưa đo"),
                      _buildInfoRow("Bệnh nền:", _medicalHistory ?? "Không có"),
                      _buildInfoRow("Triệu chứng:", _symptoms ?? "Không có"),
                      _buildInfoRow("Dị ứng:", _allergies ?? "Không có"),

                      const SizedBox(height: 15),

                      // 🟢 2. KHỐI HIỂN THỊ DỮ LIỆU TRUNG BÌNH LẤY ĐỘNG TỪ API HEALTH-METRICS
                      _buildAverageRow("Chỉ số đường huyết trung bình:",
                          _avgBloodSugar, "mg/dL"),
                      _buildAverageRow("Chỉ số huyết áp tâm thu trung bình:",
                          _avgSystolicBp, "mmHg"),
                      _buildAverageRow("Chỉ số huyết áp tâm trương trung bình:",
                          _avgDiastolicBp, "mmHg"),
                      _buildAverageRow(
                          "Chỉ số nhịp tim trung bình:", _avgHeartRate, "bpm"),

                      const SizedBox(height: 35),

                      // 3. KHỐI NÚT CHỨC NĂNG
                      // 3. KHỐI NÚT CHỨC NĂNG
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4CAF50),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                              // 🌟 SỬA ĐOẠN NÀY: Thêm await và gọi lại hàm fetch dữ liệu khi quay về
                              onPressed: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => UpdateHealthScreen(
                                      currentUser: widget.user,
                                    ),
                                  ),
                                );

                                // 🔥 Khi người dùng bấm lưu và quay lại từ UpdateHealthScreen, dòng này sẽ chạy:
                                print(
                                    "🔄 Người dùng đã quay lại màn hình thông tin! Tiến hành refresh dữ liệu mới nhất...");
                                _fetchPatientData();
                              },
                              child: const Text(
                                "Cập nhật",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          // ... Giữ nguyên nút Đăng xuất phía dưới của bác ...
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFF8522),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => LoginScreen()));
                              },
                              child: const Text("Đăng xuất",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        "$label $value",
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _buildAverageRow(String label, double? value, String unit) {
    final String displayValue =
        value != null ? "${value.toStringAsFixed(1)} $unit" : "Đang tính...";
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        "$label  $displayValue (7 ngày)",
        style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2),
      ),
    );
  }
}
