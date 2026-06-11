import 'package:doantotnghiep/graph/user_model.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:dio/dio.dart';

class SystolicGraphScreen extends StatefulWidget {
  // 🟢 ĐỔI TẠI ĐÂY: Nhận hẳn đối tượng UserModel truyền vào thay vì int userId
  final UserModel user;

  const SystolicGraphScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<SystolicGraphScreen> createState() => _SystolicGraphScreenState();
}

class _SystolicGraphScreenState extends State<SystolicGraphScreen> {
  final Dio _dio = Dio();
  List<FlSpot> _spots = [];
  List<String> _dateTimeLabels =
      []; // Danh sách chứa nhãn Ngày/Giờ thực tế từ DB
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      // 🟢 Bốc ID trực tiếp từ đối tượng user của widget
      print("======> THỰC TẾ FLUTTER GỬI USER ID LÀ: ${widget.user.id}");

      final response = await _dio.get(
        "http://localhost:8000/api/health-metrics/latest",
        queryParameters: {
          "user_id": widget.user.id,
          "limit": 7,
        },
      );
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> chartList = response.data['chartData'] ?? [];

        setState(() {
          _spots = [];
          _dateTimeLabels = []; // Reset danh sách nhãn

          // 🟢 Duyệt danh sách theo tiến trình thời gian chuẩn của Backend
          for (int i = 0; i < chartList.length; i++) {
            var item = chartList[i];
            if (item['systolic_bp'] != null) {
              double value = double.parse(item['systolic_bp'].toString());
              // Lưu tọa độ điểm vẽ bắt đầu từ index 0
              _spots.add(FlSpot(i.toDouble(), value));

              // Lưu lại mốc thời gian định dạng ngày/tháng giờ:phút
              _dateTimeLabels.add(item['date'] ?? "");
            }
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = "Không thể tải dữ liệu: $e";
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
            icon:
                const Icon(Icons.arrow_back_ios, color: Colors.black, size: 22),
            onPressed: () => Navigator.of(context).pop()),
        // 🟢 Lấy trực tiếp tên hiển thị từ widget.user.name lên AppBar
        title: Text(
          "Huyết áp của ${widget.user.name}",
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : _error != null
              ? Center(
                  child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(_error!,
                          style: const TextStyle(color: Colors.white),
                          textAlign: TextAlign.center)))
              : Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      // 🟢 Dòng hiển thị tên Bệnh nhân động phía trên biểu đồ
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding:
                              const EdgeInsets.only(bottom: 12.0, left: 4.0),
                          child: Text(
                            "Bệnh nhân: ${widget.user.name}",
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                      Expanded(
                        child: _buildChartContainer("Huyết áp tâm thu (mmHg)",
                            _spots, Colors.redAccent, 70, 180),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildChartContainer(String title, List<FlSpot> spots, Color lineColor,
      double minY, double maxY) {
    return Container(
      padding: const EdgeInsets.only(top: 20, bottom: 12, left: 10, right: 24),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          SizedBox(
            height: 250,
            child: spots.isEmpty
                ? const Center(
                    child:
                        Text("Không có dữ liệu đo trong khoảng thời gian này"))
                : LineChart(LineChartData(
                    minX: 0,
                    maxX: spots.length > 1 ? (spots.length - 1).toDouble() : 6,
                    minY: minY,
                    maxY: maxY,
                    gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (value) => FlLine(
                            color: Colors.grey.shade200, strokeWidth: 1)),
                    borderData: FlBorderData(show: false),
                    titlesData: FlTitlesData(
                      show: true,
                      rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                              showTitles: true,
                              interval: 1,
                              getTitlesWidget: (v, m) {
                                int index = v.toInt();
                                String labelText = "";
                                // Map chính xác vị trí sang chuỗi thời gian thực tế
                                if (index >= 0 &&
                                    index < _dateTimeLabels.length) {
                                  labelText = _dateTimeLabels[index];
                                }
                                return Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Text(
                                    labelText,
                                    style: const TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold),
                                  ),
                                );
                              })),
                      leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 35,
                              getTitlesWidget: (v, m) => Text(
                                  v.toInt().toString(),
                                  style: const TextStyle(fontSize: 11)))),
                    ),
                    lineBarsData: [
                      LineChartBarData(
                          spots: spots,
                          isCurved: true,
                          color: lineColor,
                          barWidth: 4,
                          dotData: const FlDotData(show: true),
                          belowBarData: BarAreaData(
                              show: true, color: lineColor.withOpacity(0.1)))
                    ],
                  )),
          ),
        ],
      ),
    );
  }
}
