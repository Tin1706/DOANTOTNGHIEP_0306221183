import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:audioplayers/audioplayers.dart'; // 🟢 1. THÊM THƯ VIỆN ĐỂ PHÁT CHUÔNG BÁO ĐỘNG

class HealthMetricsInputScreen extends StatefulWidget {
  final int userId; // Nhận userId từ màn hình Đăng nhập truyền sang

  const HealthMetricsInputScreen({Key? key, this.userId = 1}) : super(key: key);

  @override
  _HealthMetricsInputScreenState createState() =>
      _HealthMetricsInputScreenState();
}

class _HealthMetricsInputScreenState extends State<HealthMetricsInputScreen> {
  // 1. Khởi tạo các bộ điều khiển ô nhập dữ liệu (Controllers)
  final TextEditingController _bloodSugarController = TextEditingController();
  final TextEditingController _systolicBpController = TextEditingController();
  final TextEditingController _diastolicBpController = TextEditingController();
  final TextEditingController _heartRateController = TextEditingController();

  final Dio _dio = Dio();
  bool _isLoading = false;

  // 🟢 2. KHỞI TẠO PLAYER ĐỂ ĐIỀU KHIỂN ÂM THANH BÁO ĐỘNG
  final AudioPlayer _audioPlayer = AudioPlayer();

  // 🟢 3. HÀM TẠO HỘP THOẠI CẢNH BÁO NGUY HIỂM (MÀU ĐỎ) + TẮT CHUÔNG
  void _showDangerAlertDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible:
          false, // Bắt buộc người dùng bấm nút mới được tắt chuông
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red, size: 32),
              SizedBox(width: 10),
              Text(
                "🚨 NGUY HIỂM KHẨN CẤP",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                    fontSize: 18),
              ),
            ],
          ),
          content: Text(
            "$message\nVui lòng chú ý điều chỉnh chế độ ăn uống/tiêm thuốc hoặc liên hệ bác sĩ ngay lập tức nếu cơ thể mệt mỏi!",
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () async {
                await _audioPlayer.stop(); // 🟢 TẮT TIẾNG CHUÔNG BÁO THỨC NGAY
                if (mounted) {
                  Navigator.of(dialogContext)
                      .pop(); // Đóng AlertDialog cảnh báo đỏ
                  Navigator.of(context).pop(); // Quay về trang trước đó
                }
              },
              child: const Text(
                "Tôi đã hiểu & Tắt báo động",
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
            )
          ],
        );
      },
    );
  }

  // 4. Logic xử lý gửi dữ liệu lên Python Backend khi bấm nút
  Future<void> _submitMetrics() async {
    // Kiểm tra tính hợp lệ dữ liệu cơ bản trước khi gọi API
    if (_bloodSugarController.text.isEmpty ||
        _systolicBpController.text.isEmpty ||
        _diastolicBpController.text.isEmpty ||
        _heartRateController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Vui lòng nhập đầy đủ tất cả các chỉ số sức khỏe!"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final double bloodSugar =
        double.tryParse(_bloodSugarController.text) ?? 0.0;

    try {
      // Địa chỉ API submit cục bộ (Chỉnh lại nếu dùng IP tĩnh hoặc máy ảo 10.0.2.2)
      final String apiUrl = "http://127.0.0.1:8000/api/health-metrics/submit";

      // Tạo cấu trúc JSON Payload đồng bộ 100% với Pydantic Schema ở Python
      final Map<String, dynamic> payload = {
        "user_id": widget.userId,
        "blood_sugar": bloodSugar,
        "unit": "mg/dL",
        "systolic_bp": int.tryParse(_systolicBpController.text) ?? 0,
        "diastolic_bp": int.tryParse(_diastolicBpController.text) ?? 0,
        "heart_rate": int.tryParse(_heartRateController.text) ?? 0,
      };

      final response = await _dio.post(apiUrl, data: payload);

      if (response.statusCode == 201 && response.data['success'] == true) {
        final evaluation = response.data['data'];

        // 🟢 4. KIỂM TRA ĐIỀU KIỆN ĐƯỜNG HUYẾT ĐỂ NỔ CHUÔNG + DIALOG NGUY HIỂM ĐỎ
        if (bloodSugar > 180 || bloodSugar < 70) {
          String alertMsg = bloodSugar > 180
              ? "Chỉ số đường huyết vừa nhập là ${bloodSugar} mg/dL. Bạn đang bị TĂNG ĐƯỜNG HUYẾT vượt ngưỡng an toàn!"
              : "Chỉ số đường huyết vừa nhập là ${bloodSugar} mg/dL. Bạn đang bị HẠ ĐƯỜNG HUYẾT cực kỳ nguy hiểm!";

          try {
            await _audioPlayer
                .setReleaseMode(ReleaseMode.loop); // Bật lặp vô hạn
            await _audioPlayer.play(
                AssetSource('chuong_bao_thuc.mp3')); // Gáy nhạc chuông lên
          } catch (e) {
            print("Không thể phát chuông báo động: $e");
          }

          // Nổ hộp thoại nguy hiểm màu đỏ
          if (mounted) _showDangerAlertDialog(alertMsg);
        } else {
          // Ngược lại, nếu đường huyết bình thường -> Hiện Dialog kết quả teal truyền thống của bạn
          if (mounted) {
            _showResultDialog(
              sugarStatus: evaluation['blood_sugar_status'],
              sugarWarn: evaluation['blood_sugar_warning'],
              bpWarn: evaluation['blood_pressure_warning'],
              hrWarn: evaluation['heart_rate_warning'],
            );
          }
        }
      }
    } catch (e) {
      String serverError = "Không thể kết nối đến máy chủ.";
      if (e is DioException && e.response != null) {
        serverError =
            e.response?.data['detail'] ?? "Lỗi xử lý dữ liệu hệ thống.";
      } else {
        serverError = e.toString();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Lỗi hệ thống: $serverError"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // 5. Hàm tạo hộp thoại hiển thị dòng Kết quả sức khỏe thông thường
  void _showResultDialog({
    required String sugarStatus,
    required String sugarWarn,
    required String bpWarn,
    required String hrWarn,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Row(
            children: [
              Icon(Icons.health_and_safety, color: Colors.teal),
              SizedBox(width: 10),
              Text("Kết quả phân tích",
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildResultRow(
                "Đường huyết:",
                "$sugarStatus - $sugarWarn",
                sugarStatus == "Bình thường" ? Colors.green : Colors.red,
              ),
              const Divider(),
              _buildResultRow(
                "Huyết áp:",
                bpWarn,
                bpWarn == "Huyết áp bình thường" ? Colors.green : Colors.red,
              ),
              const Divider(),
              _buildResultRow(
                "Nhịp tim:",
                hrWarn,
                hrWarn == "Nhịp tim bình thường" ? Colors.green : Colors.red,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                Navigator.of(context).pop();
              },
              child: const Text("Xác nhận & Đóng",
                  style: TextStyle(fontSize: 16, color: Colors.teal)),
            )
          ],
        );
      },
    );
  }

  Widget _buildResultRow(String title, String value, Color statusColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          const SizedBox(height: 3),
          Text(
            value,
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 15, color: statusColor),
          ),
        ],
      ),
    );
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
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          "Nhập chỉ số",
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 10),
            _buildInputField(
                controller: _bloodSugarController,
                hintText: "Nhập đường huyết",
                suffixText: "mg/dL",
                keyboardType: const TextInputType.numberWithOptions()),
            const SizedBox(height: 20),
            _buildInputField(
              controller: _systolicBpController,
              hintText: "Nhập huyết áp tâm thu:",
              suffixText: "mmHg",
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            _buildInputField(
              controller: _diastolicBpController,
              hintText: "Nhập huyết áp tâm trương:",
              suffixText: "mmHg",
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            _buildInputField(
              controller: _heartRateController,
              hintText: "Nhập nhịp tim",
              suffixText: "bpm",
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitMetrics,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 3),
                      )
                    : const Text(
                        "Xác nhận",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    required String suffixText,
    required TextInputType keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(
            fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(
              color: Colors.black54, fontWeight: FontWeight.w500),
          suffixText: suffixText,
          suffixStyle: const TextStyle(
              color: Colors.black87, fontWeight: FontWeight.bold),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          border: InputBorder.none,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose(); // 🟢 GIẢI PHÓNG AUDIO PLAYER KHI THOÁT TRANG
    _bloodSugarController.dispose();
    _systolicBpController.dispose();
    _diastolicBpController.dispose();
    _heartRateController.dispose();
    super.dispose();
  }
}
