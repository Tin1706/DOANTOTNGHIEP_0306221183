import 'package:doantotnghiep/auth/login_screen.dart';
import 'package:doantotnghiep/constant.dart';
import 'package:doantotnghiep/main_menu/update_health_screen.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:doantotnghiep/graph/user_model.dart';
import 'dart:convert';
import 'package:audioplayers/audioplayers.dart'; // 🌟 1. Import thư viện âm thanh

class PatientInfoScreen extends StatefulWidget {
  final UserModel user;

  const PatientInfoScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<PatientInfoScreen> createState() => _PatientInfoScreenState();
}

class _PatientInfoScreenState extends State<PatientInfoScreen> {
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

  // 🌟 2. Khai báo bộ điều khiển âm thanh và biến trạng thái cảnh báo
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isAlarmPlaying = false;
  String _alarmReason = ""; // Lý do báo động (ví dụ: Huyết áp cao!)

  @override
  void initState() {
    super.initState();
    _fetchPatientData();
  }

  // 🌟 3. Giải phóng bộ nhớ âm thanh khi thoát màn hình để tránh rò rỉ (leak) bộ nhớ
  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  // 🌟 4. Hàm kích hoạt phát chuông báo thức liên tục
  void _playAlarm(String reason) async {
    if (_isAlarmPlaying) return; // Nếu đang kêu rồi thì không bật đè lên nữa

    setState(() {
      _isAlarmPlaying = true;
      _alarmReason = reason;
    });

    try {
      // Thiết lập phát lặp đi lặp lại (Loop) cho đến khi bấm tắt
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      // Phát file âm thanh từ thư mục assets
      await _audioPlayer.play(AssetSource('chuong_bao_thuc.wav'));
    } catch (e) {
      print("🚨 Lỗi phát âm thanh báo thức: $e");
    }
  }

  // 🌟 5. Hàm tắt chuông báo thức bằng tay
  void _stopAlarm() async {
    await _audioPlayer.stop();
    setState(() {
      _isAlarmPlaying = false;
      _alarmReason = "";
    });
  }

  // 🌟 6. Hàm kiểm tra sức khỏe để kích hoạt chuông tự động
  void _checkHealthThresholds() {
    // Ví dụ cấu hình ngưỡng nguy hiểm:
    // Huyết áp tâm thu > 140 mmHg hoặc Đường huyết > 180 mg/dL hoặc Nhịp tim > 100 bpm
    if (_avgSystolicBp != null && _avgSystolicBp! > 140.0) {
      _playAlarm(
          "Huyết áp tâm thu trung bình cao vượt ngưỡng (${_avgSystolicBp!.toStringAsFixed(1)} mmHg)!");
    } else if (_avgBloodSugar != null && _avgBloodSugar! > 180.0) {
      _playAlarm(
          "Đường huyết trung bình cao nguy hiểm (${_avgBloodSugar!.toStringAsFixed(1)} mg/dL)!");
    } else if (_avgHeartRate != null && _avgHeartRate! > 100.0) {
      _playAlarm(
          "Nhịp tim trung bình đập quá nhanh (${_avgHeartRate!.toStringAsFixed(1)} bpm)!");
    }
  }

  Future<void> _fetchPatientData() async {
    try {
      final dio = Dio();
      final int userId = widget.user.id;

      final infoResponse =
          await dio.get(AppConstant.address + '/api/onboarding/$userId');

      final avgResponse = await dio.get(AppConstant.address +
          '/api/health-metrics/average?user_id=$userId&days=7');

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

          // --- B. GIẢI MÃ BỆNH NỀN ---
          var rawConditions =
              infoData['pre_existing_conditions'] ?? infoData['conditions'];
          if (rawConditions != null) {
            if (rawConditions is List) {
              _medicalHistory = rawConditions.isNotEmpty
                  ? rawConditions.join(', ')
                  : "Không có";
            } else {
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

          // --- C. GIẢI MÃ TRIỆU CHỨNG ---
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

        // 🌟 7. Sau khi setState xong dữ liệu mới, chạy hàm check ngưỡng cảnh báo luôn
        _checkHealthThresholds();
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
                child: CircularProgressIndicator(color: Colors.white),
              )
            : SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24.0, vertical: 10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 🌟 8. BANNER HIỂN THỊ CẢNH BÁO BÁO THỨC TRỰC QUAN ĐẦU TRANG
                      if (_isAlarmPlaying) _buildAlarmWidget(),

                      // 🟢 1. KHỐI THÔNG TIN CÁ NHÂN LẤY ĐỘNG 100%
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

                      // 🟢 2. KHỐI HIỂN THỊ DỮ LIỆU TRUNG BÌNH LẤY ĐỘNG
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
                              onPressed: () async {
                                // Nếu đang bật chuông, tắt trước khi sang trang khác tránh gây ồn
                                _stopAlarm();

                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => UpdateHealthScreen(
                                        currentUser: widget.user),
                                  ),
                                );
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
                                _stopAlarm(); // Tắt chuông khi đăng xuất
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

  // 🌟 9. Giao diện Banner Đỏ nhấp nháy báo động chuông và nút Tắt nhanh
  Widget _buildAlarmWidget() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade800,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4))
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.warning_amber_rounded,
                  color: Colors.white, size: 30),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "CẢNH BÁO SỨC KHỎE!",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _alarmReason,
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.red.shade800,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: _stopAlarm,
            icon: const Icon(Icons.volume_off),
            label: const Text("TẮT CHUÔNG BÁO THỨC",
                style: TextStyle(fontWeight: FontWeight.bold)),
          )
        ],
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
