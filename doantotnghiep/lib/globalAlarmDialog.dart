import 'package:doantotnghiep/constant.dart';
import 'package:flutter/material.dart';
class GlobalAlarmDialog {
  static void show(Map<String, dynamic> item) {
    // Tìm context hiện tại của màn hình đang hiển thị trên cùng
    final context = AppConstant.navigatorKey.currentContext;
    if (context == null) return;

    showDialog(
      context: context,
      barrierDismissible: true, // Cho phép bấm ra ngoài để đóng
      builder: (BuildContext ctx) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 12,
          titlePadding: const EdgeInsets.all(0),
          title: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            decoration: const BoxDecoration(
              color: Color(0xFFFF5252), // Màu hồng đỏ chuẩn báo động
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: const Row(
              children: [
                Icon(Icons.alarm_on, color: Colors.white, size: 28),
                SizedBox(width: 12),
                Text(
                  'ĐẾN GIỜ UỐNG THUỐC!',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Hệ thống phát hiện đã đến lịch hẹn y tế. Vui lòng sử dụng thuốc đúng liều lượng:",
                style: TextStyle(color: Colors.grey, fontSize: 13, height: 1.4),
              ),
              const SizedBox(height: 18),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.local_hospital_rounded,
                      color: Colors.blueGrey[400], size: 24),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      item['title'] ?? "Nhắc nhở đo đường huyết",
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Icon(Icons.assignment_turned_in,
                      color: Colors.blueGrey[400], size: 24),
                  const SizedBox(width: 10),
                  Text("Liều lượng: ",
                      style: TextStyle(fontSize: 15, color: Colors.grey[700])),
                  Expanded(
                    child: Text(
                      item['body'] ?? item['dosage'] ?? "Thực hiện đúng giờ",
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.cyan),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actionsPadding:
              const EdgeInsets.only(bottom: 20, right: 16, left: 16),
          actions: [
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(0xff22cbd5), // Màu xanh cyan chuẩn theo UI
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                ),
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
                child: const Text(
                  'Xác nhận đã thực hiện',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
