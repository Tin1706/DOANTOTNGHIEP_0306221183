import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'health_metrics_input_screen.dart'; // Đảm bảo import đúng đường dẫn tới file nhập liệu
import 'package:doantotnghiep/constant.dart'; // Thay đổi đường dẫn này nếu bạn đặt file constant.dart ở thư mục khác
class HealthMetricsHistoryScreen extends StatefulWidget {
  final int userId;

  const HealthMetricsHistoryScreen({Key? key, this.userId = 1}) : super(key: key);

  @override
  _HealthMetricsHistoryScreenState createState() => _HealthMetricsHistoryScreenState();
}

class _HealthMetricsHistoryScreenState extends State<HealthMetricsHistoryScreen> {
  final Dio _dio = Dio();
  bool _isLoading = true;
  List<dynamic> _historyData = [];
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  // 🔄 Hàm gọi API lấy danh sách lịch sử đo từ FastAPI
  Future<void> _fetchHistory() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Điều chỉnh lại URL endpoint theo đúng thiết kế Router của Backend Python
      final String apiUrl = AppConstant.address + "/api/health-metrics/history/${widget.userId}";
      final response = await _dio.get(apiUrl);

      if (response.statusCode == 200 && response.data['success'] == true) {
        setState(() {
          _historyData = response.data['data'] ?? [];
        });
      } else {
        setState(() {
          _errorMessage = "Không thể tải danh sách dữ liệu.";
        });
      }
    } catch (e) {
      setState(() {
        if (e is DioException && e.response != null) {
          _errorMessage = e.response?.data['detail'] ?? "Lỗi xử lý dữ liệu từ máy chủ.";
        } else {
          _errorMessage = "Lỗi kết nối máy chủ: ${e.toString()}";
        }
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF00BCD4); // Màu nền xanh Cyan theo thiết kế Figma

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
          "Trang chủ",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      _errorMessage,
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : _historyData.isEmpty
                  ? const Center(
                      child: Text(
                        "Chưa có chỉ số đo nào được ghi lại.",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                      itemCount: _historyData.length,
                      itemBuilder: (context, index) {
                        final item = _historyData[index];
                        // Biến đếm số thứ tự hiển thị ngược hoặc xuôi theo danh sách trả về
                        final recordNumber = _historyData.length - index; 

                        return _buildHistoryCard(item, recordNumber);
                      },
                    ),

      // ➕ Nút bấm tròn (FloatingActionButton) thiết kế chuẩn theo Figma ở góc phải dưới
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Điều hướng chuyển tiếp sang màn hình nhập chỉ số sức khỏe
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HealthMetricsInputScreen(userId: widget.userId),
            ),
          );
          // Sau khi người dùng nhập dữ liệu xong và bấm back quay lại, tự động làm mới danh sách lịch sử
          _fetchHistory();
        },
        backgroundColor: Colors.white,
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.black, size: 32),
      ),
    );
  }

  // 🗂️ Khung thiết kế từng Card hiển thị bộ chỉ số y tế theo Figma mẫu
  Widget _buildHistoryCard(Map<String, dynamic> data, int recordNumber) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Hiển thị số thứ tự bản ghi (1, 2, 3...) tại góc phải trên cùng của Card
          Positioned(
            top: 16,
            right: 20,
            child: Text(
              "$recordNumber",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMetricRow(
                  "Chỉ số đường huyết:",
                  "${data['blood_sugar']} ${data['unit'] ?? 'mg/dL'}",
                  data['blood_sugar_status'] ?? "Bình thường",
                  _getStatusColor(data['blood_sugar_status']),
                ),
                const SizedBox(height: 10),
                _buildMetricRow(
                  "Chỉ số huyết áp tâm thu:",
                  "${data['systolic_bp']} mmHg",
                  data['systolic_bp_status'] ?? "",
                  _getStatusColor(data['systolic_bp_status']),
                ),
                const SizedBox(height: 10),
                _buildMetricRow(
                  "Chỉ số huyết áp tâm trương:",
                  "${data['diastolic_bp']} mmHg",
                  data['diastolic_bp_status'] ?? "",
                  _getStatusColor(data['diastolic_bp_status']),
                ),
                const SizedBox(height: 10),
                _buildMetricRow(
                  "Chỉ số nhịp tim:",
                  "${data['heart_rate']} bpm",
                  data['heart_rate_status'] ?? "Bình thường",
                  _getStatusColor(data['heart_rate_status']),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Hàm tạo dòng text chi tiết của từng loại chỉ số bên trong thẻ Card lịch sử
  Widget _buildMetricRow(String label, String value, String status, Color statusColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black),
            ),
            const SizedBox(width: 6),
            Text(
              value,
              style: const TextStyle(fontSize: 15, color: Colors.black87, fontWeight: FontWeight.w500),
            ),
            if (status.isNotEmpty) ...[
              const Text("  -  ", style: TextStyle(color: Colors.black54)),
              Text(
                status,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: statusColor),
              ),
            ],
          ],
        ),
      ],
    );
  }

  // 🎨 Hàm tự động phân tích nhãn trạng thái để gán màu sắc trực quan (Đỏ khi cao/thấp, Xanh khi ổn định)
  Color _getStatusColor(String? status) {
    if (status == null) return Colors.black54;
    final lowercaseStatus = status.toLowerCase();
    if (lowercaseStatus.contains('bình thường') || lowercaseStatus.contains('ổn định')) {
      return Colors.green;
    } else if (lowercaseStatus.contains('cao') || lowercaseStatus.contains('thấp') || lowercaseStatus.contains('nguy hiểm')) {
      return Colors.red;
    }
    return Colors.orange;
  }
}