import 'package:doantotnghiep/graph/user_model.dart';
import 'package:flutter/material.dart';
// Import đúng 2 trang biểu đồ chi tiết của bạn
import 'systolic_graph_screen.dart';
import 'diastolic_graph_screen.dart';

class BloodPressureGraphScreen extends StatelessWidget {
  final UserModel user;
  // 🟢 BƯỚC 2: Thêm 'required this.userId' vào hàm khởi tạo Constructor
  const BloodPressureGraphScreen({Key? key, required this.user})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    const Color primaryColor =
        Color(0xFF00BCD4); // Giữ tone nền xanh chuẩn thiết kế

    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 22),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Nút bấm Huyết áp tâm thu
            _buildGraphButton(
              title: "Huyết áp tâm thu",
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    // 🟢 BƯỚC 3A: Truyền tiếp userId vào trang đồ thị tâm thu
                    builder: (context) => SystolicGraphScreen(user: user),
                  ),
                );
              },
            ),

            // 2. Nút bấm Huyết áp tâm trương
            _buildGraphButton(
              title: "Huyết áp tâm trương",
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    // 🟢 BƯỚC 3B: Truyền tiếp userId vào trang đồ thị tâm trương
                    builder: (context) => DiastolicGraphScreen(user: user),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // Widget tạo nút bấm đồng bộ, hỗ trợ hiệu ứng hover chuột chuẩn chỉnh
  Widget _buildGraphButton({
    required String title,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          mouseCursor: SystemMouseCursors.click,
          hoverColor: Colors.grey.shade100,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 22.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
