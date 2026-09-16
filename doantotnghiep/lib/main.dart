import 'package:doantotnghiep/constant.dart'; // 🟢 Import AppConstant
import 'package:doantotnghiep/reminder/notification_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'auth/login_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Khởi tạo Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print("🔥 [Firebase] Đã kết nối Firebase phía Flutter thành công.");
  } catch (e) {
    print("🚨 Lỗi khởi tạo Firebase: $e");
  }

  // 2. Khởi tạo Múi giờ
  try {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Ho_Chi_Minh'));
  } catch (e) {
    print("Lỗi khởi tạo múi giờ: $e");
  }

  // 3. Khởi tạo Push Notification Service
  try {
    // 🟢 Gán key từ AppConstant cho NotificationService (nếu service cần)
    NotificationService.navigatorKey = AppConstant.navigatorKey;
    await NotificationService().initNotification();
    print("🔔 [Notification] Đã khởi tạo lắng nghe Push Notification.");
  } catch (e) {
    print("🚨 Lỗi khởi tạo NotificationService: $e");
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
      // 🟢 Sử dụng navigatorKey từ AppConstant
      navigatorKey: AppConstant.navigatorKey,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('vi', 'VN'),
        Locale('en', 'US'),
      ],
      locale: const Locale('vi', 'VN'),
      theme: ThemeData(
        fontFamily: 'Roboto',
      ),
      home: const LoginScreen(),
    );
  }
}
