import 'package:flutter/material.dart';
import 'auth_service.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;
  final String otpCode;

  const ResetPasswordScreen({
    super.key,
    required this.email,
    required this.otpCode,
  });

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final AuthService _authService = AuthService();

  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleResetPassword() async {
    // 🛡️ CHẶN LỖI TRÊN WEB: Kiểm tra nếu phiên làm việc bị mất do F5 trang
    if (widget.email.isEmpty || widget.otpCode.isEmpty) {
      _showSnackBar(
          'Phiên làm việc đã hết hạn do tải lại trang. Vui lòng thực hiện lại từ bước Quên mật khẩu!');
      return;
    }

    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (newPassword.isEmpty || confirmPassword.isEmpty) {
      _showSnackBar('Vui lòng nhập đầy đủ thông tin mật khẩu mới!');
      return;
    }

    if (newPassword != confirmPassword) {
      _showSnackBar('Mật khẩu xác nhận không trùng khớp!');
      return;
    }

    if (newPassword.length < 6) {
      _showSnackBar('Mật khẩu mới phải có ít nhất 6 ký tự!');
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
      final response = await _authService.resetPassword(
        email: widget.email,
        otpCode: widget.otpCode,
        newPassword: newPassword,
        confirmNewPassword: confirmPassword,
      );

      // Tắt hộp thoại Loading ngay khi nhận được phản hồi thành công
      if (mounted) Navigator.pop(context);

      if (response.statusCode == 200) {
        _showSnackBar('Đặt lại mật khẩu thành công! Vui lòng đăng nhập lại. 🎉',
            isError: false);

        // 🚀 ĐIỀU HƯỚNG AN TOÀN: Đưa về màn hình đầu tiên (Màn Login) và xóa toàn bộ lịch sử các màn trước đó
        if (mounted) {
          // Cách này hoạt động tốt với cả dự án KHÔNG dùng Named Routes, tránh lỗi đen màn hình trên Web
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      }
    } catch (e) {
      // Đảm bảo LUÔN LUÔN tắt loading nếu xảy ra lỗi mạng/lỗi kết nối API
      if (mounted) {
        Navigator.pop(context);
        _showSnackBar(e.toString());
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
        title: const Text('Đặt lại mật khẩu',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Tạo mật khẩu mới bảo mật hơn',
              style: TextStyle(
                  color: Colors.white70,
                  fontSize: 15,
                  fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 30),

            // Ô nhập Mật khẩu mới
            Container(
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              height: 55,
              child: TextField(
                controller: _newPasswordController,
                obscureText: _obscureNewPassword,
                style: const TextStyle(
                    color: Colors.black, fontWeight: FontWeight.w500),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Mật khẩu mới',
                  hintStyle: const TextStyle(color: Colors.black38),
                  icon: const Icon(Icons.lock_outline, color: Colors.black45),
                  suffixIcon: IconButton(
                    icon: Icon(
                        _obscureNewPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.black45),
                    onPressed: () => setState(
                        () => _obscureNewPassword = !_obscureNewPassword),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15),

            // Ô nhập Xác nhận mật khẩu mới
            Container(
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              height: 55,
              child: TextField(
                controller: _confirmPasswordController,
                obscureText: _obscureConfirmPassword,
                style: const TextStyle(
                    color: Colors.black, fontWeight: FontWeight.w500),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Xác nhận mật khẩu mới',
                  hintStyle: const TextStyle(color: Colors.black38),
                  icon: const Icon(Icons.lock_reset, color: Colors.black45),
                  suffixIcon: IconButton(
                    icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.black45),
                    onPressed: () => setState(() =>
                        _obscureConfirmPassword = !_obscureConfirmPassword),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 35),

            // Nút Lưu thay đổi
            SizedBox(
              height: 45,
              width: 160,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2ECC71),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
                onPressed: _handleResetPassword,
                child: const Text('Lưu thay đổi',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
