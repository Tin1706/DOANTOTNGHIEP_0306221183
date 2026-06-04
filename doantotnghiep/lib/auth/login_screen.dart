import 'package:doantotnghiep/main_menu/main_menu_screen.dart';
import 'package:flutter/material.dart';
import 'forgot_password_screen.dart';
import 'register_screen.dart';
import 'auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscurePassword = true;

  // 1. Tạo các bộ điều khiển để thu thập dữ liệu nhập vào
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Khởi tạo đối tượng AuthService
  final AuthService _authService = AuthService();

  @override
  void dispose() {
    // Giải phóng bộ nhớ khi không dùng màn hình này nữa
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // 2. Hàm xử lý logic gọi API Đăng nhập
  // Trong file login_screen.dart (Hàm xử lý nút Đăng nhập)
  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showSnackBar('Vui lòng nhập đầy đủ email và mật khẩu!');
      return;
    }

    // Hiển thị loading...
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );

    try {
      final response =
          await _authService.login(email: email, password: password);

      if (mounted) Navigator.pop(context); // Tắt loading

      if (response.statusCode == 200 || response.statusCode == 201) {
        _showSnackBar('Đăng nhập thành công 🎉', isError: false);

        // 🌟 LẤY USER ID TỪ DATABASE QUA RESPONSE CỦA DIO
        final rawData = response.data;
        int loggedInUserId = 0;

        if (rawData != null && rawData is Map) {
          // Hỗ trợ cả trường hợp api bọc trong cục 'data' hoặc trả về trực tiếp
          final innerData = rawData['data'] ?? rawData;
          loggedInUserId = innerData['id'] ?? innerData['user_id'] ?? 0;
        }

        print("🆔 Đăng nhập thành công với User ID từ DB: $loggedInUserId");

        // 🌟 ĐIỀU HƯỚNG SANG MENU CHÍNH VÀ TRUYỀN ID THỰC TẾ
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => MainMenuScreen(userId: loggedInUserId),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) Navigator.pop(context); // Tắt loading nếu lỗi
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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Đăng nhập',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),

            // Ô nhập Email
            Container(
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              height: 50,
              alignment: Alignment.centerLeft,
              child: TextField(
                controller: _emailController, // Gắn controller nhận diện email
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.black),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Địa chỉ email',
                  hintStyle: TextStyle(
                      color: Colors.black54, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Ô nhập Mật khẩu
            Container(
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              height: 50,
              alignment: Alignment.centerLeft,
              child: TextField(
                controller:
                    _passwordController, // Gắn controller nhận diện password
                obscureText: _obscurePassword,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.black),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Mật khẩu',
                  hintStyle: const TextStyle(
                      color: Colors.black54, fontWeight: FontWeight.bold),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: Colors.black,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
              ),
            ),

            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ForgotPasswordScreen()));
                },
                child: const Text(
                  'Quên mật khẩu',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      decoration: TextDecoration.underline),
                ),
              ),
            ),
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Nút Đăng nhập đã được map với hàm xử lý API kết nối phía trên
                _buildButton(
                  text: 'Đăng nhập',
                  color: const Color(0xFF2ECC71),
                  onPressed: _handleLogin,
                ),
                const SizedBox(width: 12),
                _buildButton(
                  text: 'Đăng ký',
                  color: const Color(0xFFFF8C00),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const RegisterScreen()));
                  },
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildButton(
      {required String text,
      required Color color,
      required VoidCallback onPressed}) {
    return SizedBox(
      height: 40,
      width: 120,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: onPressed,
        child: Text(text,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13)),
      ),
    );
  }
}
