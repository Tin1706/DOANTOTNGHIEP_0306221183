import 'package:flutter/material.dart';
import 'verify_otp_screen.dart';
import 'auth_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final AuthService _authService = AuthService();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  // Hàm xử lý logic gọi API Quên mật khẩu
  Future<void> _handleForgotPassword() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      _showSnackBar('Vui lòng nhập địa chỉ email của bạn!');
      return;
    }

    // Hiển thị hiệu ứng Loading chặn màn hình
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );

    try {
      // Gọi API gửi yêu cầu OTP tới Backend
      final response = await _authService.forgotPassword(email);

      if (response.statusCode == 200) {
        // Tắt loading trước khi hiển thị SnackBar hoặc chuyển màn hình
        if (mounted) Navigator.pop(context);

        _showSnackBar('Mã OTP đã được gửi về email của bạn! ✉️',
            isError: false);

        // Chuyển sang màn hình xác thực OTP và truyền kèm email qua Constructor
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VerifyOtpScreen(email: email),
            ),
          );
        }
      }
    } catch (e) {
      // Đóng Loading lập tức nếu xảy ra lỗi (Sai email, sập server, lỗi mạng)
      if (mounted) {
        Navigator.pop(context);
        _showSnackBar("Lỗi thực tế: ${e.toString()}");
      }
    }
  }

  void _showSnackBar(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00BCE4),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Quên mật khẩu',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ô nhập Email
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              height: 50,
              alignment: Alignment.centerLeft,
              child: TextField(
                controller: _emailController,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.black,
                ),
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Địa chỉ email',
                  hintStyle: TextStyle(
                    color: Colors.black54,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Nút Xác nhận
            SizedBox(
              height: 40,
              width: 120,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2ECC71),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                onPressed: _handleForgotPassword,
                child: const Text(
                  'Xác nhận',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
