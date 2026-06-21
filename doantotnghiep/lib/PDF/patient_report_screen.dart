import 'package:doantotnghiep/PDF/patient_report_models.dart';
import 'package:doantotnghiep/PDF/patient_report_services.dart';
import 'package:doantotnghiep/graph/user_model.dart';
import 'package:flutter/material.dart';

class PatientReportScreen extends StatefulWidget {
  final UserModel user; // Truyền userId của bệnh nhân vào đây
  const PatientReportScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<PatientReportScreen> createState() => _PatientReportScreenState();
}

class _PatientReportScreenState extends State<PatientReportScreen> {
  final PatientReportService _reportService = PatientReportService();
  late Future<PatientReportResponse> _reportFuture;

  @override
  void initState() {
    super.initState();
    _reportFuture = _reportService.fetchPatientReport(widget.user.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Báo cáo bệnh án')),
      body: FutureBuilder<PatientReportResponse>(
        future: _reportFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError ||
              !snapshot.hasData ||
              !snapshot.data!.success) {
            return Center(
              child: Text(snapshot.data?.message ?? "Không thể tải dữ liệu"),
            );
          }

          final report = snapshot.data!.data!;

          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(
                      color: Colors.cyan,
                      width: 4.0), // Khung viền xanh cyan chủ đạo
                  color: Colors.white,
                ),
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hàng chứa nút PDF và Checkmark
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.picture_as_pdf,
                              size: 30, color: Colors.redAccent),
                          onPressed: () async {
                            // 1. Hiển thị thông báo bắt đầu xử lý dữ liệu
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Đang khởi tạo cấu trúc và tải file PDF...'),
                                duration: Duration(seconds: 2),
                              ),
                            );

                            try {
                              // 2. Thực thi tải và kích hoạt mở file PDF lên màn hình điện thoại
                              await _reportService
                                  .downloadAndOpenPDF(widget.user.id);
                            } catch (e) {
                              // 3. Báo lỗi ra màn hình nếu mất kết nối hoặc IP sai cấu hình
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text('Lỗi xuất PDF thất bại: $e')),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Thông tin cá nhân cơ bản
                    _buildTextRow("Họ và tên:", report.name,
                        trailingLabel: "Tuổi: ${report.age}"),
                    _buildTextRow("Chiều cao:", "${report.height}cm",
                        trailingLabel: "Cân nặng: ${report.weight}kg"),

                    const SizedBox(height: 5),
                    const Divider(color: Colors.black26),
                    const SizedBox(height: 5),

                    // Các chỉ số sức khỏe lấy trung bình 7 ngày từ FastAPI
                    _buildTextRow("Đường huyết:", report.bloodSugar),
                    _buildTextRow("Huyết áp tâm thu:", report.systolic),
                    _buildTextRow("Huyết áp tâm trương:", report.diastolic),
                    _buildTextRow("Nhịp tim:", report.heartRate),

                    // Thông tin lâm sàng
                    _buildTextRow("Bệnh nền:", report.underlyingDisease),
                    _buildTextRow("Triệu chứng:", report.symptoms),
                    _buildTextRow("Dị ứng:", report.allergy),

                    const SizedBox(height: 20),

                    // BẢNG THUỐC ĐIỀU TRỊ (Vẽ khung đen bo góc viền mảnh theo UI)
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black, width: 1.0),
                      ),
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Center(
                            child: Text(
                              'Bảng thuốc điều trị',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ),
                          const SizedBox(height: 10),

                          // Vòng lặp hiển thị danh sách thuốc động trả về từ DB
                          if (report.medications.isEmpty)
                            const Center(
                                child: Text("Không có chỉ định thuốc."))
                          else
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: report.medications.length,
                              itemBuilder: (context, index) {
                                final med = report.medications[index];
                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4.0),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('${index + 1}.  ',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      Expanded(
                                        child: RichText(
                                          text: TextSpan(
                                            style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 14),
                                            children: [
                                              const TextSpan(
                                                  text: "Tên thuốc: ",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold)),
                                              TextSpan(text: "${med.name}\n"),
                                              const TextSpan(
                                                  text: "Liều lượng: ",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold)),
                                              TextSpan(text: med.dosage),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Hàm helper để build hàng text nhanh gọn, chuẩn chữ đậm/nhạt
  Widget _buildTextRow(String title, String value, {String? trailingLabel}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          RichText(
            text: TextSpan(
              style: const TextStyle(color: Colors.black, fontSize: 14),
              children: [
                TextSpan(
                    text: "$title ",
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(text: value),
              ],
            ),
          ),
          if (trailingLabel != null) ...[
            const Spacer(),
            RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.black, fontSize: 14),
                children: [
                  TextSpan(
                    text: trailingLabel.split(': ')[0] + ": ",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: trailingLabel.split(': ')[1]),
                ],
              ),
            ),
          ]
        ],
      ),
    );
  }
}

// Trick mở rộng để bọc BoxDecoration tiện lợi hơn
extension BoxExtension on BoxDecoration {
  BoxDecoration wrapBox() => const BoxDecoration(
          border: Border(
        top: BorderSide(color: Colors.black),
        left: BorderSide(color: Colors.black),
        right: BorderSide(color: Colors.black),
        bottom: BorderSide(color: Colors.black),
      ));
}
