import 'package:doantotnghiep/constant.dart';
import 'package:doantotnghiep/graph/user_model.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:dio/dio.dart';

class BloodSugarGraphScreen extends StatefulWidget {
  // 🟢 ĐỔI TẠI ĐÂY: Nhận hẳn đối tượng UserModel truyền vào
  final UserModel user;

  const BloodSugarGraphScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<BloodSugarGraphScreen> createState() => _BloodSugarGraphScreenState();
}

class _BloodSugarGraphScreenState extends State<BloodSugarGraphScreen> {
  final Dio _dio = Dio();
  List<FlSpot> _spots = [];
  List<String> _dateTimeLabels = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      // 🟢 Bốc ID trực tiếp từ đối tượng user được truyền vào để gọi API đồ thị
      print("======> THỰC TẾ FLUTTER GỬI USER ID LÀ: ${widget.user.id}");

      final response = await _dio.get(
        AppConstant.address + "api/health-metrics/latest",
        queryParameters: {
          "user_id": widget.user.id, // 🟢 Dùng ID của user ở đây
          "limit": 7,
        },
      );
      print("Dữ liệu chỉ số sức khỏe: ${response.data}");

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> chartList = response.data['chartData'] ?? [];

        setState(() {
          _spots = [];
          _dateTimeLabels = [];

          for (int i = 0; i < chartList.length; i++) {
            var item = chartList[i];
            if (item['blood_sugar'] != null) {
              double value = double.parse(item['blood_sugar'].toString());
              _spots.add(FlSpot(i.toDouble(), value));
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
        // 🟢 Lấy trực tiếp tên từ widget.user.name hiển thị lên AppBar
        title: Text(
          "Đường huyết của ${widget.user.name}",
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
                      // 🟢 Lấy trực tiếp tên từ widget.user.name hiển thị lên dòng giới thiệu
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
                        child: _buildChartContainer("Đường huyết (mg/dL)",
                            _spots, Colors.orange, 50, 210),
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

                    // 🔴 THÊM ĐOẠN NÀY ĐỂ HIGHLIGHT VÙNG AN TOÀN (70 - 125)
                    extraLinesData: ExtraLinesData(
                      horizontalLines: [
                        // 🩸 ĐƯỜNG CHẶN TRÊN (125 mg/dL)
                        HorizontalLine(
                          y: 125,
                          color: Colors.green.withOpacity(0.4),
                          strokeWidth: 1.5,
                          dashArray: [5, 5], // Tạo nét đứt thanh lịch
                          label: HorizontalLineLabel(
                            show: true,
                            alignment: Alignment.topRight,
                            style: TextStyle(
                              color: Colors.green.shade800,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                            labelResolver: (line) => "Tối đa: 125",
                          ),
                        ),
                        // 🩸 ĐƯỜNG CHẶN DƯỚI (70 mg/dL)
                        HorizontalLine(
                          y: 70,
                          color: Colors.green.withOpacity(0.4),
                          strokeWidth: 1.5,
                          dashArray: [5, 5],
                          label: HorizontalLineLabel(
                            show: true,
                            alignment: Alignment.topRight,
                            style: TextStyle(
                              color: Colors.green.shade800,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                            labelResolver: (line) => "Tối thiểu: 70",
                          ),
                        ),
                        // 🩸 VÙNG HIGHLIGHT NẰM GIỮA (70 - 125)
                        HorizontalLine(
                          y: 97.5, // (125 + 70) / 2
                          strokeWidth:
                              50, // Độ dày lõi trong dải màu xanh để bao trọn từ 70 đến 125
                          color: Colors.green.withOpacity(0.12),
                          label: HorizontalLineLabel(
                            show: true,
                            alignment: Alignment.centerLeft,
                            style: TextStyle(
                              color: Colors.green.shade700,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            labelResolver: (line) => " VÙNG AN TOÀN",
                          ),
                        ),
                      ],
                    ),
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
                                String text = "";
                                if (index >= 0 &&
                                    index < _dateTimeLabels.length) {
                                  text = _dateTimeLabels[index];
                                }
                                return Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Text(
                                    text,
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
