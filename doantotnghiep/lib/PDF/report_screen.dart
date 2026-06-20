import 'package:doantotnghiep/PDF/api_services.dart';
import 'package:doantotnghiep/graph/user_model.dart';
import 'package:flutter/material.dart';

class ReportScreen extends StatefulWidget {
  final UserModel user;

  const ReportScreen({super.key, required this.user});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  String _displayResult = "Chưa có dữ liệu (Bấm nút để lấy)";

  void _checkAdherenceRateOnly() async {
    setState(() {
      _displayResult = "⏳ Đang kết nối backend...";
    });

    final now = DateTime.now();
    final thirtyDaysLater = now.add(const Duration(days: 30));

    String formatDate(DateTime date) {
      String year = date.year.toString();
      String month = date.month.toString().padLeft(2, '0');
      String day = date.day.toString().padLeft(2, '0');
      return "$year-$month-$day";
    }

    final String startDateStr = formatDate(now);
    final String endDateStr = formatDate(thirtyDaysLater);
    print(
        "⏳ Đang quét tỉ lệ tuân thủ từ ngày $startDateStr đến ngày $endDateStr...");

    final response = await ApiService.calculateAdherence(
      userId: widget.user.id,
      startDate: startDateStr,
      endDate: endDateStr,
    );

    // 🚀 KIỂM TRA VÀ TRÍCH XUẤT ĐÚNG CẤU TRÚC JSON CỦA FASTAPI
    if (response != null && response['success'] == true) {
      // Vì FastAPI bọc các trường vào trong object 'data'
      var nestedData = response['data'];

      if (nestedData != null) {
        var rate = nestedData['adherence_rate'] ?? 0;
        int totalScheduled = nestedData['total_scheduled'] ?? 0;
        int totalTaken = nestedData['total_taken'] ?? 0;

        // Tính số lần chưa uống (Bỏ lỡ) trực tiếp bằng Tổng lịch trừ đi Đã uống
        int totalMissed = totalScheduled - totalTaken;
        if (totalMissed < 0) totalMissed = 0; // Đề phòng trường hợp log lỗi

        // 📝 LOG RA CONSOLE
        print("==================================================");
        print(
            "🎯 THÔNG SỐ BÁO CÁO CỦA USER ${widget.user.id}: ${widget.user.name}");
        print("⏰ Khoảng thời gian: $startDateStr -> $endDateStr");
        print("📊 Tổng số lịch nhắc hẹn: $totalScheduled lần");
        print("✅ Số lần ĐÃ UỐNG: $totalTaken lần");
        print("❌ Số lần CHƯA UỐNG (Bỏ lỡ): $totalMissed lần");
        print("🎯 TỈ LỆ TUÂN THỦ: $rate%");
        print("==================================================");

        if (mounted) {
          setState(() {
            // HIỂN THỊ TRỰC QUAN LÊN GIAO DIỆN FLUTTER
            _displayResult = "🎯 TỈ LỆ TUÂN THỦ: $rate%\n\n"
                "✅ Đã uống: $totalTaken lần\n"
                "❌ Chưa uống: $totalMissed lần\n"
                "📊 Tổng lịch: $totalScheduled lần";
          });
        }
      } else {
        _showError("Không tìm thấy thuộc tính 'data' trong phản hồi!");
      }
    } else {
      String errMsg = response != null
          ? (response['message'] ??
              response['detail'] ??
              "Lỗi không xác định từ Backend.")
          : "Không nhận được dữ liệu từ Backend.";
      print("❌ Lỗi: $errMsg");
      _showError(errMsg);
    }
  }

  // Hàm phụ để cập nhật giao diện khi lỗi
  void _showError(String message) {
    if (mounted) {
      setState(() {
        _displayResult = "❌ Lỗi: $message";
      });
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
            Text("Đang xem báo cáo của: ${widget.user.name}",
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text("User ID: ${widget.user.id}",
                style: const TextStyle(fontSize: 13, color: Colors.grey)),

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _checkAdherenceRateOnly,
              style:
                  ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
              child: const Text("Bấm để PRINT tỉ lệ % ra Console & Giao diện",
                  style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(height: 30),

            // Khung hiển thị kết quả trực quan hơn một chút
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.blueGrey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _displayResult,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey,
                    height: 1.5), // Giúp giãn dòng chuỗi kết quả
                textAlign: TextAlign
                    .start, // Đổi thành start để các dòng chữ căn lề đẹp hơn
              ),
            ),
          ],
        ),
      ),
    );
  }
}
