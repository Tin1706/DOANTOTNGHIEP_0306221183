import 'package:doantotnghiep/FoodAndExercise/exercise_list.dart';
import 'package:doantotnghiep/FoodAndExercise/food_list.dart';
import 'package:flutter/material.dart';
class HealthFeaturesScreen extends StatelessWidget {
  const HealthFeaturesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF00BCD4); // Màu nền xanh Cyan chủ đạo

    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            
            // 1. Nút bấm Khẩu phần ăn -> Điều hướng sang FoodListScreen
            _buildMenuButton(
              context: context,
              label: "Khẩu phần ăn",
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const FoodListScreen(),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 20), // Khoảng cách giữa 2 nút bấm
            
            // 2. Nút bấm Bài thể dục -> Điều hướng sang ExerciseListScreen
            _buildMenuButton(
              context: context,
              label: "Bài thể dục",
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const ExerciseListScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // Khung thiết kế nút bấm lớn nền trắng chữ đen, bo tròn góc chuẩn UI Figma
  Widget _buildMenuButton({
    required BuildContext context,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Container(
      height: 65, // Độ cao của nút bấm tạo cảm giác rộng rãi, dễ bấm
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12), // Bo góc giống hệt các ô Input dữ liệu
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3), // Tạo hiệu ứng đổ bóng nhẹ cho nút nổi lên
          ),
        ],
      ),
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold, // Chữ đậm rõ ràng giống thiết kế mẫu
          ),
        ),
      ),
    );
  }
}