import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'health_metrics_input_screen.dart';
import 'package:doantotnghiep/constant.dart';

class HealthMetricsHistoryScreen extends StatefulWidget {
  final int userId;

  const HealthMetricsHistoryScreen({Key? key, this.userId = 1})
      : super(key: key);

  @override
  _HealthMetricsHistoryScreenState createState() =>
      _HealthMetricsHistoryScreenState();
}

class _HealthMetricsHistoryScreenState
    extends State<HealthMetricsHistoryScreen> {
  final Dio _dio = Dio();
  bool _isLoading = true;
  List<dynamic> _historyData = [];
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final String apiUrl =
          "${AppConstant.address}api/health-metrics/history/${widget.userId}";
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
          _errorMessage =
              e.response?.data['detail'] ?? "Lỗi xử lý dữ liệu từ máy chủ.";
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
    const Color primaryColor = Color(0xFF00BCD4);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Đổi nền xám nhạt để nổi bật Card trắng
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          "Lịch sử chỉ số sức khỏe",
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: primaryColor))
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      _errorMessage,
                      style: const TextStyle(
                          color: Colors.redAccent,
                          fontSize: 16,
                          fontWeight: FontWeight.w500),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : _historyData.isEmpty
                  ? const Center(
                      child: Text(
                        "Chưa có chỉ số đo nào được ghi lại.",
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 14.0),
                      itemCount: _historyData.length,
                      itemBuilder: (context, index) {
                        final item = _historyData[index];
                        final recordNumber = _historyData.length - index;
                        return _buildHistoryCard(item, recordNumber);
                      },
                    ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    HealthMetricsInputScreen(userId: widget.userId)),
          );
          _fetchHistory();
        },
        backgroundColor: primaryColor,
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 32),
      ),
    );
  }

  Widget _buildHistoryCard(Map<String, dynamic> data, int recordNumber) {
    // 1. Ép kiểu dữ liệu từ JSON API
    int heartRate = int.tryParse(data['heart_rate'].toString()) ?? 0;
    int bloodSugar = int.tryParse(data['blood_sugar'].toString()) ?? 0;
    int systolicBp = int.tryParse(data['systolic_bp'].toString()) ?? 0;
    int diastolicBp = int.tryParse(data['diastolic_bp'].toString()) ?? 0;

    // 2. Map trực tiếp các key từ ảnh Response Body của bạn
    String sugarStatus = data['blood_sugar_status'] ?? "Bình thường";
    String sugarWarning = data['blood_sugar_warning'] ?? "Ổn định";
    String bpWarning = data['blood_pressure_warning'] ?? "Huyết áp bình thường";
    String hrWarning = data['heart_rate_warning'] ?? "Nhịp tim bình thường";
    String timeDisplay = data['logged_at'] ?? "";

    // Kết hợp trạng thái đường huyết để hiển thị đầy đủ (Ví dụ: "Bình thường (Ổn định)")
    String fullSugarStatus = "$sugarStatus ($sugarWarning)";

    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Số thứ tự bản ghi nằm ở góc phải
          Positioned(
            top: 16,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF00BCD4).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Text(
                "#$recordNumber",
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00BCD4)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Chỉ số đường huyết
                _buildMetricRow(
                  icon: Icons.bloodtype,
                  iconColor: Colors.redAccent,
                  label: "Đường huyết:",
                  value: "$bloodSugar ${data['unit'] ?? 'mg/dL'}",
                  status: fullSugarStatus,
                  statusColor: _getStatusColor(sugarStatus),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Divider(color: Color(0xFFECEFF1)),
                ),
                // Chỉ số huyết áp (Gộp cả tâm thu và tâm trương vào 1 dòng cho chuyên nghiệp)
                _buildMetricRow(
                  icon: Icons.favorite,
                  iconColor: Colors.pink,
                  label: "Huyết áp:",
                  value: "$systolicBp / $diastolicBp mmHg",
                  status: bpWarning,
                  statusColor: _getStatusColor(bpWarning),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Divider(color: Color(0xFFECEFF1)),
                ),
                // Chỉ số nhịp tim
                _buildMetricRow(
                  icon: Icons.monitor_heart,
                  iconColor: Colors.orange,
                  label: "Nhịp tim:",
                  value: "$heartRate bpm",
                  status: hrWarning,
                  statusColor: _getStatusColor(hrWarning),
                ),
                
                if (timeDisplay.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        "Thời gian: $timeDisplay",
                        style: const TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ]
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required String status,
    required Color statusColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: iconColor, size: 22),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: Colors.black87),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    value,
                    style: const TextStyle(
                        fontSize: 15,
                        color: Colors.black,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              if (status.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  status,
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: statusColor),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  // Bộ lọc màu tự động phân tích chuỗi tiếng Việt trả về từ Backend FastAPI
  Color _getStatusColor(String status) {
    String lowerStatus = status.toLowerCase();
    
    // Các trường hợp cảnh báo nguy hiểm / bất thường -> Đỏ
    if (lowerStatus.contains('cao') ||
        lowerStatus.contains('nhanh') ||
        lowerStatus.contains('thấp') || 
        lowerStatus.contains('chậm') || 
        lowerStatus.contains('khẩn cấp')) {
      return Colors.red.shade700;
    }
    
    // Các trường hợp tiền báo động (nếu có sau này ví dụ: "Tiền cao huyết áp") -> Cam
    if (lowerStatus.contains('tiền') || lowerStatus.contains('nguy cơ')) {
      return Colors.orange.shade700;
    }
    
    // Mặc định an toàn (Bình thường / Ổn định) -> Xanh lá
    return Colors.green.shade700;
  }
}