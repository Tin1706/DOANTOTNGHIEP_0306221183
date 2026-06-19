// symptoms_type_screen.dart
import 'package:doantotnghiep/graph/user_model.dart';
import 'package:doantotnghiep/onboarding/selection_title.dart';
import 'package:flutter/material.dart';
import 'onboarding_payload.dart';
import 'low_sugar_symptoms_screen.dart';
import 'high_sugar_symptoms_screen.dart';
import 'conditions_screen.dart';

class SymptomsTypeScreen extends StatefulWidget {
  final UserModel user;
  final OnboardingPayload payload;
  final bool isFromUpdate;

  const SymptomsTypeScreen({
    super.key,
    required this.payload,
    required this.user,
    this.isFromUpdate = false,
  });

  @override
  State<SymptomsTypeScreen> createState() => _SymptomsTypeScreenState();
}

class _SymptomsTypeScreenState extends State<SymptomsTypeScreen> {
  @override
  Widget build(BuildContext context) {
    const mainCyanColor = Color(0xFF00BCEB);

    // 1. Khởi tạo danh sách các lựa chọn đầy đủ ban đầu
    final List<Map<String, dynamic>> menuOptions = [
      {
        'title': 'Hạ đường huyết',
        'target': (BuildContext context) => LowSugarSymptomsScreen(
              payload: widget.payload,
              user: widget.user,
              isFromUpdate: widget.isFromUpdate,
            ),
      },
      {
        'title': 'Tăng đường huyết',
        'target': (BuildContext context) => HighSugarSymptomsScreen(
              payload: widget.payload,
              user: widget.user,
              isFromUpdate: widget.isFromUpdate,
            ),
      },
      {
        'title': 'Ổn định',
        'target': (BuildContext context) => ConditionsScreen(
              payload: widget.payload,
              user: widget.user,
              isFromUpdate: widget.isFromUpdate,
            ),
      },
    ];

    // 🌟 ĐOẠN SỬA ĐỔI: Nếu đi từ màn hình Update (isFromUpdate == true), lọc bỏ "Ổn định"
    if (widget.isFromUpdate) {
      menuOptions.removeWhere((option) => option['title'] == 'Ổn định');
    }

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
                subtitle:
                    'Vui lòng chọn trạng thái sức khỏe gần đây để chúng tôi thu thập triệu chứng chính xác.',
              ),

              // Tạo các khối hộp trắng bo góc chuẩn đét theo thiết kế Figma
              Expanded(
                child: ListView.builder(
                  itemCount: menuOptions.length,
                  itemBuilder: (context, index) {
                    final option = menuOptions[index];

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8.0), // Khoảng cách giữa các hộp trắng
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white, // Nền trắng rõ ràng
                          borderRadius:
                              BorderRadius.circular(12), // Bo góc mượt mà
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20.0, vertical: 8.0),
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
                          onTap: () async {
                            // Dùng await để hứng dữ liệu mảng String từ màn hình con trả về
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => option['target'](context),
                              ),
                            );

                            // Nếu màn hình con có trả về danh sách triệu chứng hoặc bệnh lý đã chọn,
                            // lập tức pop tiếp để tuồn dữ liệu về màn hình UpdateHealthScreen gốc
                            if (result != null) {
                              Navigator.pop(context, result);
                            }
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
