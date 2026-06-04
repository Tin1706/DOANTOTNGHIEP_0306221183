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
  late Future<String> _otpFuture;

  @override
  void initState() {
    super.initState();
    _otpFuture = _authService.getOtpFromDatabase(email: widget.email);
  }

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

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );

    try {
      final response = await _authService.verifyOtp(
        email: widget.email,
        otpCode: otpCode,
      );

      if (mounted) Navigator.pop(context); // Tắt hộp thoại Loading

      if (response.statusCode == 200) {
        _showSnackBar('Xác thực thành công mã OTP! 🎉', isError: false);

        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ResetPasswordScreen(
                email: widget.email, 
                otpCode: otpCode,
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) Navigator.pop(context); // Tắt hộp thoại Loading nếu lỗi
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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FutureBuilder<String>(
              future: _otpFuture, 
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Column(
                    children: [
                      Text(
                        'Đang lấy mã OTP từ hệ thống...',
                        style: TextStyle(color: Colors.white70, fontSize: 15),
                      ),
                      SizedBox(height: 10),
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.amber, strokeWidth: 2),
                      ),
                    ],
                  );
                }

                if (snapshot.hasError) {
                  return Column(
                    children: [
                      const Text('Không thể lấy mã OTP', style: TextStyle(color: Colors.redAccent)),
                      const SizedBox(height: 5),
                      Text('Lỗi: ${snapshot.error}', style: const TextStyle(color: Colors.white60, fontSize: 12)),
                    ],
                  );
                }

                if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  String displayCode = snapshot.data!;
                  
                  // 🔥 FIX LỖI CHÍ MẠNG: Đưa lệnh gán vào microtask để tránh xung đột luồng vẽ UI của Flutter
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (_otpController.text != displayCode) {
                      _otpController.text = displayCode;
                    }
                  });

                  return Column(
                    children: [
                      const Text(
                        'Mã OTP tự động lấy từ hệ thống:',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white70, fontSize: 15, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        displayCode, 
                        style: const TextStyle(
                            color: Colors.amber,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 4),
                      ),
                    ],
                  );
                }

                return const Text(
                  'Không tìm thấy mã OTP khả dụng!',
                  style: TextStyle(color: Colors.amber),
                );
              },
            ),
            
            const SizedBox(height: 30, width: double.infinity), 

            // Ô nhập mã OTP (Bây giờ đã được tự động điền đầy đủ)
            Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
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
                  hintText: '• • • • • •',
                  contentPadding: EdgeInsets.only(left: 8.0), 
                  hintStyle: TextStyle(color: Colors.black38, fontWeight: FontWeight.bold, letterSpacing: 8.0),
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Nút Xác nhận OTP
            SizedBox(
              height: 40,
              width: 120,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2ECC71),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
                onPressed: _handleVerifyOtp,
                child: const Text('Xác nhận', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}