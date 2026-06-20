import 'package:doantotnghiep/PDF/api_services.dart';
import 'package:flutter/material.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  String _displayResult = "Chưa có dữ liệu (Bấm nút để lấy)";

  // Hàm gọi API và gán kết quả vào biến hiển thị
  void _checkAdherenceRateOnly() async {
    setState(() {
      _displayResult = "⏳ Đang kết nối backend...";
    });

    // 📅 1. LẤY THỜI GIAN THỰC TẾ
    final now = DateTime.now();
    final sevenDaysLater = now.add(const Duration(days: 7));

    // 🛠️ 2. ĐỊNH DẠNG ĐỊNH DẠNG CHUỖI YYYY-MM-DD ĐỂ GỬI LÊN BACKEND
    String formatDate(DateTime date) {
      String year = date.year.toString();
      String month = date.month.toString().padLeft(2, '0');
      String day = date.day.toString().padLeft(2, '0');
      return "$year-$month-$day";
    }

    final String startDateStr = formatDate(now); // Định dạng ngày hôm nay
    final String endDateStr =
        formatDate(sevenDaysLater); // Định dạng 7 ngày sau

    print(
        "⏳ Đang quét tỉ lệ tuân thủ từ ngày $startDateStr đến ngày $endDateStr...");

    // 🚀 3. GỌI API VỚI NGÀY TỰ ĐỘNG
    final data = await ApiService.calculateAdherence(
      userId: 1,
      startDate: startDateStr, // Truyền ngày hôm nay (Ví dụ: "2026-06-20")
      endDate: endDateStr, // Truyền 7 ngày sau (Ví dụ: "2026-06-27")
    );

    if (data != null) {
      var rate = data['adherence_rate'];

      print("==================================================");
      print("🎯 TỈ LỆ TUÂN THỦ TỪ $startDateStr ĐẾN $endDateStr: $rate%");
      print("==================================================");

      if (mounted) {
        setState(() {
          _displayResult = "🎯 TỈ LỆ TUÂN THỦ UỐNG THUỐC THÀNH CÔNG: $rate%";
        });
      }
    } else {
      print("❌ Lỗi: Không nhận được dữ liệu từ Backend. Hãy kiểm tra server!");
      if (mounted) {
        setState(() {
          _displayResult = "❌ Lỗi: Không nhận được dữ liệu từ Backend!";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Kiểm tra Tỉ lệ")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed:
                  _checkAdherenceRateOnly, // Bấm nút để kích hoạt lệnh print và hiển thị
              style:
                  ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
              child: const Text("Bấm để PRINT tỉ lệ % ra Console & Giao diện",
                  style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(height: 30),
            // Dòng chữ hiển thị kết quả ngay trên màn hình dưới nút bấm
            Text(
              _displayResult,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
