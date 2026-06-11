import 'package:flutter/material.dart';
import 'auth_service.dart'; 
import 'reset_password_screen.dart'; 

class VerifyOtpScreen extends StatefulWidget {
  final String email;

  const VerifyOtpScreen({super.key, required this.email});

  @override
  State<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  final TextEditingController _otpController = TextEditingController();
  final AuthService _authService = AuthService();

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  // Hàm xử lý logic gọi API Xác thực OTP
  Future<void> _handleVerifyOtp() async {
    final otpCode = _otpController.text.trim();

    if (otpCode.isEmpty || otpCode.length < 6) {
      _showSnackBar('Vui lòng nhập đúng và đủ 6 ký tự mã OTP!');
      return;
    }

    // Hiển thị vòng xoay Loading chặn tương tác
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );

    try {
      final response = await _authService.verifyOtp(
        email: widget.email.trim(),
        otpCode: otpCode,
      );

      if (!mounted) return; // Bảo vệ Context an toàn trong Flutter
      Navigator.pop(context); // Tắt hộp thoại Loading

      if (response.statusCode == 200 || response.statusCode == 201) {
        _showSnackBar('Xác thực thành công mã OTP! 🎉', isError: false);

        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResetPasswordScreen(
              email: widget.email.trim(), 
              otpCode: otpCode,
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // Tắt hộp thoại Loading nếu xảy ra lỗi
      _showSnackBar(e.toString()); 
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
          'Xác thực OTP',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      // Bọc GestureDetector để khi bấm ra ngoài khoảng trống sẽ tự ẩn bàn phím ảo
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 🌟 ĐÃ SỬA: Thay thế FutureBuilder bằng đoạn Text thông báo tĩnh chuyên nghiệp
                const Icon(
                  Icons.mark_email_read_outlined,
                  size: 60,
                  color: Colors.white,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Mã xác thực đã được gửi',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Vui lòng kiểm tra hộp thư đến của email:\n${widget.email}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                
                const SizedBox(height: 40), 

                // Ô nhập mã OTP (Người dùng bắt buộc phải tự tay nhập)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white, 
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  height: 50,
                  alignment: Alignment.centerLeft,
                  child: TextField(
                    controller: _otpController,
                    maxLength: 6,
                    buildCounter: (context, {required currentLength, required isFocused, maxLength}) => null, 
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black,
                        letterSpacing: 8.0),
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Nhập mã 6 số',
                      contentPadding: EdgeInsets.only(left: 8.0), 
                      hintStyle: TextStyle(
                        color: Colors.black38, 
                        fontWeight: FontWeight.bold, 
                        letterSpacing: 8.0,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 35),

                // Nút Xác nhận OTP
                SizedBox(
                  height: 42,
                  width: 140,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2ECC71),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                    ),
                    onPressed: _handleVerifyOtp,
                    child: const Text(
                      'Xác nhận', 
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}