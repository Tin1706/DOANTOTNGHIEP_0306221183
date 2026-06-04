import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class HealthMetricsInputScreen extends StatefulWidget {
  final int userId; // Nhận userId từ màn hình Đăng nhập truyền sang

  const HealthMetricsInputScreen({Key? key, this.userId = 1}) : super(key: key);

  @override
  _HealthMetricsInputScreenState createState() => _HealthMetricsInputScreenState();
}

class _HealthMetricsInputScreenState extends State<HealthMetricsInputScreen> {
  // 1. Khởi tạo các bộ điều khiển ô nhập dữ liệu (Controllers)
  final TextEditingController _bloodSugarController = TextEditingController();
  final TextEditingController _systolicBpController = TextEditingController();
  final TextEditingController _diastolicBpController = TextEditingController();
  final TextEditingController _heartRateController = TextEditingController();

  final Dio _dio = Dio();
  bool _isLoading = false;

  // 2. Logic xử lý gửi dữ liệu lên Python Backend khi bấm nút
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

    try {
      // Địa chỉ API submit cục bộ (Chỉnh lại cổng port nếu bạn cấu hình khác)
      final String apiUrl = "http://127.0.0.1:8000/api/health-metrics/submit";

      // Tạo cấu trúc JSON Payload đồng bộ 100% với Pydantic Schema ở Python
      final Map<String, dynamic> payload = {
        "user_id": widget.userId,
        "blood_sugar": double.tryParse(_bloodSugarController.text) ?? 0.0,
        "unit": "mg/dL",
        "systolic_bp": int.tryParse(_systolicBpController.text) ?? 0,
        "diastolic_bp": int.tryParse(_diastolicBpController.text) ?? 0,
        "heart_rate": int.tryParse(_heartRateController.text) ?? 0,
      };

      final response = await _dio.post(apiUrl, data: payload);

      if (response.statusCode == 201 && response.data['success'] == true) {
        // Trích xuất dữ liệu phân tích sức khỏe mà Python vừa trả về
        final evaluation = response.data['data'];

        // Gọi hàm hiển thị Dialog thông báo kết quả chi tiết
        _showResultDialog(
          sugarStatus: evaluation['blood_sugar_status'],
          sugarWarn: evaluation['blood_sugar_warning'],
          bpWarn: evaluation['blood_pressure_warning'],
          hrWarn: evaluation['heart_rate_warning'],
        );
      }
    } catch (e) {
      String serverError = "Không thể kết nối đến máy chủ.";
      if (e is DioException && e.response != null) {
        // Đọc chi tiết lỗi nghiệp vụ thật từ FastAPI (ví dụ lỗi logic 500 hoặc validation 422)
        serverError = e.response?.data['detail'] ?? "Lỗi xử lý dữ liệu hệ thống.";
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
      setState(() {
        _isLoading = false;
      });
    }
  }

  // 3. Hàm tạo hộp thoại hiển thị dòng Cảnh báo Y Tế lấy từ Python
  void _showResultDialog({
    required String sugarStatus,
    required String sugarWarn,
    required String bpWarn,
    required String hrWarn,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Row(
            children: [
              Icon(Icons.health_and_safety, color: Colors.teal),
              SizedBox(width: 10),
              Text("Kết quả phân tích", style: TextStyle(fontWeight: FontWeight.bold)),
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
                Navigator.of(context).pop(); // Đóng hộp thoại kết quả
                // Xóa trắng ô nhập liệu sau khi lưu thành công để sẵn sàng cho lần sau
                _bloodSugarController.clear();
                _systolicBpController.clear();
                _diastolicBpController.clear();
                _heartRateController.clear();
              },
              child: const Text("Xác nhận & Đóng", style: TextStyle(fontSize: 16, color: Colors.teal)),
            )
          ],
        );
      },
    );
  }

  // Hàm bổ trợ thiết kế dòng kết quả phân tích trong Dialog
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
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: statusColor),
          ),
        ],
      ),
    );
  }

  // 4. Giao diện thiết kế theo chuẩn bản phối Figma màu xanh Cyan của bạn
  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF00BCD4); // Màu nền xanh Cyan chủ đạo

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
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 10),
            // Ô nhập chỉ số Đường huyết
            _buildInputField(
              controller: _bloodSugarController,
              hintText: "Nhập đường huyết",
              suffixText: "mg/dL",
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 20),
            // Ô nhập Huyết áp tâm thu
            _buildInputField(
              controller: _systolicBpController,
              hintText: "Nhập huyết áp tâm thu:",
              suffixText: "mmHg",
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            // Ô nhập Huyết áp tâm trương
            _buildInputField(
              controller: _diastolicBpController,
              hintText: "Nhập huyết áp tâm trương:",
              suffixText: "mmHg",
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            // Ô nhập Nhịp tim
            _buildInputField(
              controller: _heartRateController,
              hintText: "Nhập nhịp tim",
              suffixText: "bpm",
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 40),
            
            // Nút bấm Xác nhận màu xanh lá cây đồng bộ layout
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitMetrics,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50), // Màu xanh lá cây nút xác nhận
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                      )
                    : const Text(
                        "Xác nhận",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Khung thiết kế ô TextField bo tròn nền trắng chuẩn UI Figma
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
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.black54, fontWeight: FontWeight.w500),
          suffixText: suffixText,
          suffixStyle: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          border: InputBorder.none,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _bloodSugarController.dispose();
    _systolicBpController.dispose();
    _diastolicBpController.dispose();
    _heartRateController.dispose();
    super.dispose();
  }
}