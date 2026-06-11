import 'package:doantotnghiep/onboarding/profile_setup_screen.dart';
import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'verify_register_otp_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _obscurePwd = true;
  bool _obscureConfirmPwd = true;
  DateTime? _selectedDate;

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final AuthService _authService = AuthService();

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    // 🌟 Ẩn bàn phím trước khi mở hộp thoại chọn ngày để tránh xung đột giao diện
    FocusScope.of(context).unfocus();

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime(2000, 1, 1),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      locale: const Locale('vi', 'VN'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF00BCE4),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // Hàm xử lý logic gọi API Đăng ký
  Future<void> _handleRegister() async {
    final fullName = _fullNameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (fullName.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty ||
        _selectedDate == null) {
      _showSnackBar('Vui lòng điền đầy đủ thông tin và chọn ngày sinh!');
      return;
    }

    if (password != confirmPassword) {
      _showSnackBar('Mật khẩu xác nhận không khớp!');
      return;
    }

    String dobFormatted =
        "${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}";

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          const Center(child: CircularProgressIndicator(color: Colors.white)),
    );

    try {
      final response = await _authService.register(
        fullName: fullName,
        email: email,
        dob: dobFormatted,
        password: password,
        confirmPassword: confirmPassword,
      );

      if (!mounted) return;
      Navigator.pop(context); // Tắt hộp thoại Loading

      if (response.statusCode == 200 || response.statusCode == 201) {
        final rawData = response.data;
        int newUserId = 0;

        if (rawData != null && rawData is Map) {
          // Nếu là luồng lách whitelist thành công
          if (rawData['is_whitelist_bypassed'] == true) {
            newUserId = -1; // Đặt ID tạm thời để qua màn OTP
          } else {
            // Luồng chuẩn khi email hợp lệ không bị chặn whitelist
            final innerData = rawData['data'] ?? rawData;
            newUserId = int.tryParse(
                    (innerData['id'] ?? innerData['user_id'] ?? 0)
                        .toString()) ??
                0;
          }
        }

        // Chuyển thẳng sang màn hình OTP với ID tạm -1
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VerifyRegisterOtpScreen(
              email: email,
              fullName: fullName,
              dob: dobFormatted, // Biến định dạng ngày sinh của bạn
              password: password,
              userId: newUserId,
            ),
          ),
        );
      }
      // ... Đoạn logic xử lý OTP gốc của bạn giữ nguyên bên dưới ...
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // Tắt hộp thoại Loading
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
    String dateText = _selectedDate == null
        ? 'Ngày sinh'
        : "${_selectedDate!.day.toString().padLeft(2, '0')}/${_selectedDate!.month.toString().padLeft(2, '0')}/${_selectedDate!.year}";

    return Scaffold(
      backgroundColor: const Color(0xFF00BCE4),
      // 🌟 ĐÃ SỬA: Thêm GestureDetector giúp click ra ngoài khoảng trống tự tắt bàn phím ảo
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                const Text(
                  'Đăng ký',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 30),

                // Ô nhập Họ và Tên
                _buildNormalField('Họ và tên', _fullNameController,
                    isEmail: false),
                const SizedBox(height: 16),

                // Ô nhập Địa chỉ Email
                _buildNormalField('Địa chỉ email', _emailController,
                    isEmail: true),
                const SizedBox(height: 16),

                // Ô chọn Ngày Sinh
                GestureDetector(
                  onTap: () => _selectDate(context),
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    height: 50,
                    alignment: Alignment.centerLeft,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          dateText,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: _selectedDate == null
                                ? Colors.black54
                                : Colors.black,
                          ),
                        ),
                        const Icon(Icons.calendar_today_outlined,
                            color: Colors.black54, size: 20),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),
                _buildPasswordField(
                    'Mật khẩu',
                    _passwordController,
                    _obscurePwd,
                    () => setState(() => _obscurePwd = !_obscurePwd)),
                const SizedBox(height: 16),
                _buildPasswordField(
                    'Xác nhận mật khẩu',
                    _confirmPasswordController,
                    _obscureConfirmPwd,
                    () => setState(
                        () => _obscureConfirmPwd = !_obscureConfirmPwd)),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildButton(
                      text: 'Đăng ký',
                      color: const Color(0xFF2ECC71),
                      onPressed: _handleRegister,
                    ),
                    const SizedBox(width: 12),
                    _buildButton(
                      text: 'Thoát',
                      color: const Color(0xFFFF8C00),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 🌟 ĐÃ SỬA: Thêm tham số `isEmail` để cấu hình riêng bàn phím chuẩn cho Email
  Widget _buildNormalField(String hint, TextEditingController controller,
      {required bool isEmail}) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(10)),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      height: 50,
      alignment: Alignment.centerLeft,
      child: TextField(
        controller: controller,
        keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
        autocorrect: !isEmail,
        enableSuggestions: !isEmail,
        style: const TextStyle(
            fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
          hintStyle: const TextStyle(
              color: Colors.black54, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildPasswordField(String hint, TextEditingController controller,
      bool obscure, VoidCallback onToggle) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(10)),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      height: 50,
      alignment: Alignment.centerLeft,
      child: TextField(
        controller: controller,
        obscureText: obscure,
        style: const TextStyle(
            fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
          hintStyle: const TextStyle(
              color: Colors.black54, fontWeight: FontWeight.bold),
          suffixIcon: IconButton(
            icon: Icon(
                obscure
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: Colors.black),
            onPressed: onToggle,
          ),
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
