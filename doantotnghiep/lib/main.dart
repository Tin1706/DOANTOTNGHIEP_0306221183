import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; // 1. Thêm dòng import này
import 'auth/login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Đồ án quản lý hỗ trợ bệnh nhân tiểu đường',
      debugShowCheckedModeBanner: false,
      
      // 2. Thêm cấu hình ngôn ngữ vào đây:
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('vi', 'VN'), // Tiếng Việt
        Locale('en', 'US'), // Tiếng Anh
      ],
      locale: const Locale('vi', 'VN'), // Đặt mặc định cho ứng dụng là tiếng Việt
      
      theme: ThemeData(
        fontFamily: 'Roboto',
      ),
      home: const LoginScreen(),
    );
  }
}