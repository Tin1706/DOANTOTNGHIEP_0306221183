import 'package:doantotnghiep/PDF/api_services.dart';
import 'package:flutter/material.dart';


class ReportScreen extends StatelessWidget {
  const ReportScreen({super.key});

  // Hàm rút gọn chỉ làm đúng nhiệm vụ gọi API và print kết quả ra console
  void _checkAdherenceRateOnly() async {
    print("⏳ Đang kết nối backend để lấy tỉ lệ tuân thủ...");

    final data = await ApiService.calculateAdherence(
      userId: 1,
      startDate: "2026-06-10",
      endDate: "2026-06-19",
    );

    if (data != null) {
      // Lấy chính xác key 'adherence_rate' từ Map dữ liệu trả về
      var rate = data['adherence_rate'];
      
      print("==================================================");
      print("🎯 TỈ LỆ TUÂN THỦ UỐNG THUỐC THÀNH CÔNG: $rate%");
      print("==================================================");
    } else {
      print("❌ Lỗi: Không nhận được dữ liệu từ Backend. Hãy kiểm tra server!");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Kiểm tra Tỉ lệ")),
      body: Center(
        child: ElevatedButton(
          onPressed: _checkAdherenceRateOnly, // Bấm nút để kích hoạt lệnh print
          style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
          child: const Text("Bấm để PRINT tỉ lệ % ra Console", style: TextStyle(fontSize: 16)),
        ),
      ),
    );
  }
}