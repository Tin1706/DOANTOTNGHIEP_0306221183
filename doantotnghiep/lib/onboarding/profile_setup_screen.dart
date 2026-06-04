// profile_setup_screen.dart
import 'package:doantotnghiep/onboarding/onboarding_payload.dart';
import 'package:flutter/material.dart';
import 'symptoms_type_screen.dart';

class ProfileSetupScreen extends StatefulWidget {
  final int userId;
  final String dob;
  const ProfileSetupScreen({
    super.key, 
    required this.userId, 
    required this.dob,
  });

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _allergyController = TextEditingController();

  void _onNext() {
    if (_heightController.text.isEmpty || _weightController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập chiều cao và cân nặng')),
      );
      return;
    }

    // 🌟 SỬA TẠI ĐÂY: Truyền thêm userId và dateOfBirth nhận được từ màn hình Login sang
    final payload = OnboardingPayload(
      userId: widget.userId,       // <--- Thêm dòng này
      dateOfBirth: widget.dob,     // <--- Thêm dòng này
      height: int.parse(_heightController.text),
      weight: int.parse(_weightController.text),
      allergies: _allergyController.text.isEmpty ? null : _allergyController.text,
    );

    // Chuyển sang màn hình tiếp theo, mang theo cục payload đầy đủ thông tin
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SymptomsTypeScreen(payload: payload, userId: widget.userId,),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00BCEB),
      appBar: AppBar(
        title: const Text('Khởi tạo hồ sơ', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF00BCEB),
        elevation: 0,
        leading: const BackButton(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  _buildTextField('Nhập chiều cao (cm)', _heightController, TextInputType.number),
                  _buildTextField('Nhập cân nặng (kg)', _weightController, TextInputType.number),
                  _buildTextField('Nhập dị ứng (nếu có)', _allergyController, TextInputType.text),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: _onNext,
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00E676)),
              child: const Text('Kế tiếp', style: TextStyle(color: Colors.white)),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String hint, TextEditingController controller, TextInputType type) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        keyboardType: type,
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        ),
      ),
    );
  }
}