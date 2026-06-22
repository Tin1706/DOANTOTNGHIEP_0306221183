import 'package:doantotnghiep/constant.dart';
import 'package:doantotnghiep/health_metrics/health_metrics_input_screen.dart';
import 'package:doantotnghiep/health_metrics/health_metrics_models.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LatestMetricsScreen extends StatefulWidget {
  final int userId;
  const LatestMetricsScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _LatestMetricsScreenState createState() => _LatestMetricsScreenState();
}

class _LatestMetricsScreenState extends State<LatestMetricsScreen> {
  List<MetricPoint> _metricsList = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchLatestMetrics();
  }

  Future<void> _fetchLatestMetrics() async {
    // Thay đổi URL phù hợp với môi trường chạy (10.0.2.2 là localhost cho máy ảo Android)
    final url = Uri.parse(
        AppConstant.address + '/api/health-metrics/latest?user_id=${widget.userId}&limit=10');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          final List<dynamic> chartData = responseData['chartData'];
          setState(() {
            _metricsList =
                chartData.map((json) => MetricPoint.fromJson(json)).toList();
            // Vì backend trả về danh sách đảo ngược để vẽ biểu đồ, ta đảo ngược lại lần nữa để bản ghi mới nhất lên đầu danh sách giống UI
            _metricsList = _metricsList.reversed.toList();
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Lỗi kết nối server: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Không thể tải dữ liệu: $e';
        _isLoading = false;
      });
    }
  }

  // Hàm helper để sinh text trạng thái và màu sắc cho Đường Huyết
  Widget _buildBloodSugarRow(double? value) {
    if (value == null || value == 0) return const SizedBox.shrink();
    String status = " - bình thường";
    Color color = Colors.green;

    if (value >= 181) {
      status = " - cao, cần tiêm insulin";
      color = Colors.red;
    } else if (value >= 126) {
      status = " - cao";
      color = Colors.red;
    } else if (value <= 69) {
      status = " - thấp, cần uống nước đường";
      color = Colors.red;
    }

    return _buildRichText(
        "Chỉ số đường huyết: ${value.toStringAsFixed(0)}mg/dL", status, color);
  }

  // Hàm helper cho Huyết Áp Tâm Thu
  Widget _buildSystolicRow(int? value) {
    if (value == null || value == 0) return const SizedBox.shrink();
    bool isHigh = value >= 140;
    bool isLow = value < 90;
    return _buildRichText(
        "Chỉ số huyết áp tâm thu: ${value}mmHg",
        isHigh ? " - cao" : (isLow ? " - thấp" : " - bình thường"),
        (isHigh || isLow) ? Colors.red : Colors.green);
  }

  // Hàm helper cho Huyết Áp Tâm Trương
  Widget _buildDiastolicRow(int? value) {
    if (value == null || value == 0) return const SizedBox.shrink();
    bool isHigh = value >= 90;
    bool isLow = value < 60;
    return _buildRichText(
        "Chỉ số huyết áp tâm trương: ${value}mmHg",
        isHigh ? " - cao" : (isLow ? " - thấp" : " - bình thường"),
        (isHigh || isLow) ? Colors.red : Colors.green);
  }

  // Hàm helper cho Nhịp Tim
  Widget _buildHeartRateRow(int? value) {
    if (value == null || value == 0) return const SizedBox.shrink();
    bool isHigh = value > 100;
    bool isLow = value < 60;
    return _buildRichText(
        "Chỉ số nhịp tim: ${value}bpm",
        isHigh ? " - cao" : (isLow ? " - thấp" : " - bình thường"),
        (isHigh || isLow) ? Colors.red : Colors.green);
  }

  Widget _buildRichText(String mainText, String statusText, Color statusColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(
              color: Colors.black, fontSize: 13, fontWeight: FontWeight.w600),
          children: [
            TextSpan(text: mainText),
            TextSpan(
              text: statusText,
              style: TextStyle(
                  color: statusColor,
                  fontSize: 11,
                  fontWeight: FontWeight.normal),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00BBE4), // Màu nền xanh cyan giống ảnh
      appBar: AppBar(
        backgroundColor: const Color(0xFF00BBE4),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Trang chủ',
          style: TextStyle(
              color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Text(_errorMessage,
                      style: const TextStyle(color: Colors.white)))
              : ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  itemCount: _metricsList.length,
                  itemBuilder: (context, index) {
                    final item = _metricsList[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 15),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Stack(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildBloodSugarRow(item.bloodSugar),
                              _buildSystolicRow(item.systolicBp),
                              _buildDiastolicRow(item.diastolicBp),
                              _buildHeartRateRow(item.heartRate),
                              const SizedBox(height: 5),
                              Text(
                                "Thời gian: ${item.date}",
                                style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 11,
                                    fontWeight: FontWeight.normal),
                              ),
                            ],
                          ),
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Text(
                              '${index + 1}', // Đánh số thứ tự tăng dần từ dưới lên
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          )
                        ],
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Chuyển hướng sang trang nhập liệu chỉ số sức khỏe
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  HealthMetricsInputScreen(userId: widget.userId), // Thay 'CreateMetricsScreen' bằng tên Class trang nhập liệu thật của bạn
            ),
          ).then((value) {
            // Hàm này chạy KHI NGƯỜI DÙNG QUAY LẠI từ trang nhập liệu
            // Gọi lại hàm load API để cập nhật ngay danh sách mới mà không cần F5 ứng dụng
            _fetchLatestMetrics();
          });
        },
        backgroundColor: Colors.white,
        child: const Icon(Icons.add, color: Colors.black, size: 30),
      ),
    );
  }
}
