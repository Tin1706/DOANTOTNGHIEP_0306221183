import 'package:doantotnghiep/health_metrics/health_metrics_input_screen.dart';
import 'package:flutter/material.dart';

class MainMenuScreen extends StatelessWidget {
  final int userId;
  const MainMenuScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    // Lấy màu nền xanh Cyan giống trong thiết kế của bạn
    const backgroundColor = Color(0xFF00BCEB);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Padding(
          // Khoảng cách thụt lề hai bên cho toàn bộ menu
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Center(
            child: ListView(
              shrinkWrap: true, // Thụt gọn danh sách theo nội dung bên trong
              children: [
                MenuButton(
                  title: 'Quản lý chỉ số sức khoẻ',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            HealthMetricsInputScreen(userId: userId),
                      ),
                    );
                  },
                ),
                MenuButton(
                  title: 'Biểu đồ thống kê',
                  onTap: () {
                    // Logic khi ấn nút 2
                  },
                ),
                MenuButton(
                  title: 'Nhắc nhở',
                  onTap: () {
                    // Logic khi ấn nút 3
                  },
                ),
                MenuButton(
                  title: 'Xuất file PDF',
                  onTap: () {
                    // Logic khi ấn nút 4
                  },
                ),
                MenuButton(
                  title: 'Quản lý thức ăn và bài thể dục',
                  onTap: () {
                    // Logic khi ấn nút 5
                  },
                ),
                MenuButton(
                  title: 'Quản lý tài khoản và sức khoẻ cá nhân',
                  onTap: () {
                    // Logic khi ấn nút 6
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// 🌟 Widget dùng chung cho các nút Menu để tránh lặp lại code
class MenuButton extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const MenuButton({
    super.key,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Khoảng cách dòng giữa các nút (Spacing)
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: SizedBox(
        width: double.infinity, // Giúp nút kéo giãn hết chiều ngang màn hình
        height: 60, // Chiều cao của mỗi nút bấm
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white, // Màu nền trắng của nút
            foregroundColor: Colors.black, // Màu khi bấm vào nút
            elevation: 0, // Độ đổ bóng (bằng 0 để phẳng giống Figma)
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12), // Bo góc giống thiết kế
            ),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold, // Chữ in đậm
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}
