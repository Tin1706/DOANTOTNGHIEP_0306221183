import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
// 🟢 1. Thêm import thư viện múi giờ (timezone)
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'auth/login_screen.dart';

// 🟢 2. Chuyển hàm main() thành hàm async để đợi khởi tạo múi giờ
void main() async {
  // Bắt buộc phải gọi dòng này đầu tiên khi dùng async trong main
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // 🟢 3. Khởi tạo dữ liệu múi giờ hệ thống (Fix triệt để lỗi _local chưa gán giá trị)
    tz.initializeTimeZones();
    // Đặt múi giờ mặc định của thiết bị là Việt Nam (Băng Cốc/Hồ Chí Minh)
    tz.setLocalLocation(tz.getLocation('Asia/Ho_Chi_Minh'));
  } catch (e) {
    print("Lỗi khởi tạo múi giờ: $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Đồ án quản lý hỗ trợ bệnh nhân tiểu đường',
      debugShowCheckedModeBanner: false,
      
      // Cấu hình ngôn ngữ (Giữ nguyên cấu trúc chuẩn của bạn)
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('vi', 'VN'), // Tiếng Việt
        Locale('en', 'US'), // Tiếng Anh
      ],
      locale: const Locale('vi', 'VN'), // Mặc định tiếng Việt
      
      theme: ThemeData(
        fontFamily: 'Roboto',
      ),
      home: const LoginScreen(),
    );
  }
}