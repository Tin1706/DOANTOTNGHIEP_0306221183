import 'package:flutter/material.dart';
import 'auth_service.dart'; // Đảm bảo đường dẫn chính xác
import 'package:doantotnghiep/onboarding/profile_setup_screen.dart'; // Màn hình setup profile của bạn
import 'package:doantotnghiep/graph/user_model.dart'; // 🟢 Import model để đóng gói dữ liệu

class VerifyRegisterOtpScreen extends StatefulWidget {
  final String email;
  final String fullName;
  final String dob;
  final String password;
  final int userId;

  const VerifyRegisterOtpScreen({
    super.key,
    required this.email,
    required this.fullName,
    required this.dob,
    required this.password,
    required this.userId,
  });

  @override
  State<VerifyRegisterOtpScreen> createState() =>
      _VerifyRegisterOtpScreenState();
}

class _VerifyRegisterOtpScreenState extends State<VerifyRegisterOtpScreen> {
  final TextEditingController _otpController = TextEditingController();
  final AuthService _authService = AuthService();

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _handleVerifyRegisterOtp() async {
    final otpCode = _otpController.text.trim();

    if (otpCode.isEmpty || otpCode.length < 6) {
      _showSnackBar('Vui lòng nhập đủ 6 ký tự mã OTP!');
      return;
    }

    // Hiển thị Loading chặn tương tác
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );

    try {
      // Gọi API verify-register-otp ở Backend
      final response = await _authService.verifyRegisterOtp(
        email: widget.email,
        fullName: widget.fullName,
        dob: widget.dob,
        password: widget.password,
        otpCode: otpCode,
      );

      if (mounted) Navigator.pop(context); // Tắt Loading ngay khi có response

      if (response.statusCode == 200 || response.statusCode == 201) {
        final rawData = response.data;
        int realUserId = 0;

        if (rawData != null && rawData is Map) {
          final innerData = rawData['data'] ?? rawData;

          // Ép kiểu chuỗi rồi parse sang int để an toàn tuyệt đối, tránh bị nhận số 0
          realUserId = int.tryParse(
                  (innerData['id'] ?? innerData['user_id'] ?? 0).toString()) ??
              0;
        }

        // Nếu backend không trả về ID hợp lệ, sử dụng cơ chế dự phòng từ widget (luồng whitelist)
        if (realUserId == 0) {
          realUserId = widget.userId;
        }

        if (realUserId == 0) {
          _showSnackBar('Lỗi: Không lấy được ID người dùng từ hệ thống!');
          return;
        }

        _showSnackBar('Xác thực thành công! 🎉', isError: false);

        if (!mounted) return;

        // 🟢 ĐÃ SỬA: Đóng gói toàn bộ thông tin đăng ký thành một đối tượng UserModel hoàn chỉnh
        final userModel = UserModel(
          id: realUserId,
          name: widget.fullName,
          email: widget.email,
          age: null, // Trường tuổi sẽ được cập nhật chi tiết tại bước ProfileSetupScreen sau này
        );

        // Tiến thẳng sang màn hình Setup Profile với thực thể user chuẩn cấu trúc mới
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ProfileSetupScreen(
              // 🟢 ĐÃ SỬA LỖI: Đổi từ 'userId: realUserId' sang tham số 'user: userModel' yêu cầu bởi Widget nhận
              user: userModel, 
              dob: widget.dob,
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // Tắt Loading nếu dính lỗi
      _showSnackBar(e.toString());
    }
  }

  void _showSnackBar(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
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
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Xác thực OTP',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  'Mã xác thực đã được gửi tới\n${widget.email}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 30),

                // Ô nhập mã OTP bo góc chuẩn UI
                Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  height: 55,
                  alignment: Alignment.centerLeft,
                  child: TextField(
                    controller: _otpController,
                    maxLength: 6,
                    buildCounter: (context,
                            {required currentLength,
                            required isFocused,
                            maxLength}) =>
                        null, // Ẩn bộ đếm chữ số mặc định
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black,
                        letterSpacing: 4.0), // Tạo khoảng cách giữa các số OTP
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Nhập mã 6 số',
                      hintStyle: TextStyle(
                          color: Colors.black45,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.0),
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // Nút Xác nhận
                SizedBox(
                  height: 45,
                  width: 140,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2ECC71),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                    ),
                    onPressed: _handleVerifyRegisterOtp,
                    child: const Text('Xác nhận',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15)),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}