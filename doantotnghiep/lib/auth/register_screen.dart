import 'package:doantotnghiep/onboarding/profile_setup_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'auth_service.dart'; // Đảm bảo đường dẫn này đúng với file chứa AuthService của bạn

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _obscurePwd = true;
  bool _obscureConfirmPwd = true;
  DateTime? _selectedDate;

  // 1. Khai báo các bộ điều khiển để lấy dữ liệu từ các ô nhập
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  // Khởi tạo AuthService
  final AuthService _authService = AuthService();

  @override
  void dispose() {
    // Giải phóng bộ nhớ khi đóng màn hình
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
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

  // 2. Hàm xử lý logic gọi API Đăng ký
  Future<void> _handleRegister() async {
    final fullName = _fullNameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    // Kiểm tra dữ liệu hợp lệ cơ bản (Validation)
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

    // Định dạng ngày sinh thành chuỗi "YYYY-MM-DD" để đồng bộ với định dạng Pydantic/FastAPI mong muốn
    String dobFormatted =
        "${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}";

    // Hiển thị vòng xoay tải dữ liệu (Loading)
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          const Center(child: CircularProgressIndicator(color: Colors.white)),
    );

    try {
      // Tiến hành gọi API thông qua AuthService
      final response = await _authService.register(
        fullName: fullName,
        email: email,
        dob: dobFormatted,
        password: password,
        confirmPassword: confirmPassword,
      );

      Navigator.pop(context); // Tắt hộp thoại Loading

      if (response.statusCode == 200 || response.statusCode == 201) {
        _showSnackBar('Đăng ký tài khoản thành công 🎉', isError: false);

        final rawData = response.data;

        // 🌟 1. In hẳn cục dữ liệu Server trả về ra Console để kiểm tra
        print("🔍 DỮ LIỆU THỰC TẾ TỪ SERVER: $rawData");

        int newUserId = 0;

        if (rawData != null) {
          // Nếu Backend trả về dạng Map (JSON Object)
          if (rawData is Map) {
            final innerData = rawData['data'] ?? rawData;

            // Thử ép kiểu cẩn thận vì đôi khi ID từ server có thể là String hoặc Int
            var idValue = innerData['id'] ?? innerData['user_id'];
            if (idValue != null) {
              newUserId = int.tryParse(idValue.toString()) ?? 0;
            }
          }
          // Nếu Backend trả về dạng chuỗi String thuần (Do bạn return thẳng string ở FastAPI)
          else if (rawData is String) {
            newUserId = int.tryParse(rawData) ?? 0;
          }
        }

        print("🎯 ID bóc tách được sau khi sửa: $newUserId");

        // 🌟 2. Bỏ đoạn ép gán bằng 1 đi, nếu bằng 0 thì báo lỗi ngay để biết đường sửa
        if (newUserId == 0) {
          _showSnackBar('Lỗi: Server không trả về ID người dùng hợp lệ!');
          return; // Dừng lại không cho chuyển màn hình để tránh rác dữ liệu user_id = 1
        }

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ProfileSetupScreen(
              userId: newUserId,
              dob: dobFormatted,
            ),
          ),
        );
      }
    } catch (e) {
      Navigator.pop(context); // Tắt hộp thoại Loading
      _showSnackBar(e.toString()); // Hiển thị lỗi nhận từ Backend lên màn hình
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            const Text(
              'Đăng ký',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            _buildNormalField(
                'Họ và tên', _fullNameController), // Gắn controller
            const SizedBox(height: 16),
            _buildNormalField(
                'Địa chỉ email', _emailController), // Gắn controller
            const SizedBox(height: 16),

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
                () => setState(
                    () => _obscurePwd = !_obscurePwd)), // Gắn controller
            const SizedBox(height: 16),
            _buildPasswordField(
                'Xác nhận mật khẩu',
                _confirmPasswordController,
                _obscureConfirmPwd,
                () => setState(() => _obscureConfirmPwd =
                    !_obscureConfirmPwd)), // Gắn controller
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildButton(
                  text: 'Đăng ký',
                  color: const Color(0xFF2ECC71),
                  onPressed:
                      _handleRegister, // Trỏ đến hàm xử lý đăng ký đã viết ở trên
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
    );
  }

  // Cập nhật lại các Widget phụ trợ để nhận thêm Controller dữ liệu
  Widget _buildNormalField(String hint, TextEditingController controller) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(10)),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      height: 50,
      alignment: Alignment.centerLeft,
      child: TextField(
        controller: controller, // Gắn bộ điều khiển
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
        controller: controller, // Gắn bộ điều khiển
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
