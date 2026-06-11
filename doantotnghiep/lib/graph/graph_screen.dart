import 'package:flutter/material.dart';
import 'package:doantotnghiep/graph/user_model.dart'; // 🟢 Thêm import model
import 'blood_pressure_graph_screen.dart'; // Màn hình chọn phân loại huyết áp (hoặc truyền thẳng)
import 'heart_rate_graph_screen.dart';
import 'blood_sugar_graph_screen.dart';

class GraphScreen extends StatelessWidget {
  // 🟢 ĐỔI TẠI ĐÂY: Nhận hẳn đối tượng UserModel truyền vào thay vì hardcode id giả lập
  final UserModel user;

  const GraphScreen({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const Color primaryColor =
        Color(0xFF00BCD4); // Màu nền xanh Cyan chuẩn thiết kế

    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 22),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          "Sức khỏe của ${user.name}",
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 10),

            // 1. Nút bấm Huyết áp -> Truyền đối tượng user sang màn hình chọn phân loại (hoặc biểu đồ)
            _buildGraphMenuButton(
              context: context,
              title: "Huyết áp",
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    // 🟢 ĐÃ SỬA: Truyền tham số user (đối tượng UserModel) vào đây
                    // (Bạn nhớ sửa Constructor của BloodPressureGraphScreen nhận `user` tương tự nhé)
                    builder: (context) => BloodPressureGraphScreen(user: user),
                  ),
                );
              },
            ),

            // 2. Nút bấm Nhịp tim -> Truyền thẳng đối tượng user vào trang biểu đồ nhịp tim
            _buildGraphMenuButton(
              context: context,
              title: "Nhịp tim",
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    // 🟢 ĐÃ SỬA: Truyền tham số user chuẩn chỉnh cho file HeartRateGraphScreen mới sửa
                    builder: (context) => HeartRateGraphScreen(user: user),
                  ),
                );
              },
            ),

            // 3. Nút bấm Đường huyết -> Truyền thẳng đối tượng user vào trang biểu đồ đường huyết
            _buildGraphMenuButton(
              context: context,
              title: "Đường huyết",
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    // 🟢 ĐÃ SỬA: Truyền tham số user chuẩn chỉnh cho file BloodSugarGraphScreen mới sửa
                    builder: (context) => BloodSugarGraphScreen(user: user),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // Widget nút bấm menu dùng chung có tích hợp hiệu ứng hover chuột
  Widget _buildGraphMenuButton({
    required BuildContext context,
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
              border: Border.all(color: Colors.white.withOpacity(0.1)),
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
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
