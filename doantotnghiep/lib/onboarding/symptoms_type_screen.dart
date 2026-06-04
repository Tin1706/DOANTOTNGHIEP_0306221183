// symptoms_type_screen.dart
import 'package:doantotnghiep/onboarding/selection_title.dart';
import 'package:flutter/material.dart';
import 'onboarding_payload.dart';
import 'low_sugar_symptoms_screen.dart';
import 'high_sugar_symptoms_screen.dart';
import 'conditions_screen.dart';

class SymptomsTypeScreen extends StatelessWidget {
  final int userId;
  final OnboardingPayload payload;
  const SymptomsTypeScreen({super.key, required this.payload, required this.userId});

  @override
  Widget build(BuildContext context) {
    const mainCyanColor = Color(0xFF00BCEB);

    // Danh sách các lựa chọn tương ứng theo Figma
    final List<Map<String, dynamic>> menuOptions = [
      {
        'title': 'Hạ đường huyết',
        // 🌟 SỬA: Thay 'widget.userId' bằng 'userId' trực tiếp vì đây là StatelessWidget
        'target': (BuildContext context) => LowSugarSymptomsScreen(payload: payload, userId: userId),
      },
      {
        'title': 'Tăng đường huyết',
        // 🌟 SỬA: Bổ sung truyền tiếp tham số userId sang cho HighSugarSymptomsScreen
        'target': (BuildContext context) => HighSugarSymptomsScreen(payload: payload, userId: userId),
      },
      {
        'title': 'Ổn định',
        // 🌟 SỬA: Bổ sung truyền tiếp tham số userId sang cho ConditionsScreen
        'target': (BuildContext context) => ConditionsScreen(payload: payload, userId: userId),
      },
    ];

    return Scaffold(
      backgroundColor: mainCyanColor,
      appBar: AppBar(
        title: const Text(
          'Chọn triệu chứng',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: mainCyanColor,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tiêu đề hướng dẫn phía trên danh sách
              const SelectionTitle(
                title: 'Tình trạng hiện tại của bạn',
                subtitle: 'Vui lòng chọn trạng thái sức khỏe gần đây để chúng tôi thu thập triệu chứng chính xác.',
              ),
              
              // Tạo các khối hộp trắng bo góc chuẩn đét theo thiết kế Figma
              Expanded(
                child: ListView.builder(
                  itemCount: menuOptions.length,
                  itemBuilder: (context, index) {
                    final option = menuOptions[index];
                    
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0), // Khoảng cách giữa các hộp trắng
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white, // Nền trắng rõ ràng
                          borderRadius: BorderRadius.circular(12), // Bo góc mượt mà
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                          title: Text(
                            option['title'],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          trailing: const Icon(
                            Icons.arrow_forward_ios, 
                            size: 16, 
                            color: Colors.black54,
                          ), // Thêm mũi tên hướng đi cho đúng tính chất menu chuyển màn
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => option['target'](context),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}