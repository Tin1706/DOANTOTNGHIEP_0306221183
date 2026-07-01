import 'dart:async'; // Quản lý Timer
import 'dart:convert'; // Giải mã JSON
import 'package:doantotnghiep/constant.dart';
import 'package:http/http.dart' as http; // Gọi API
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // Kiểm tra nền tảng Web
import 'package:doantotnghiep/FoodAndExercise/health_features.dart';
import 'package:doantotnghiep/PDF/patient_report_screen.dart';
import 'package:doantotnghiep/graph/graph_screen.dart';
import 'package:doantotnghiep/health_metrics/latest_metrics_screen.dart';
import 'package:doantotnghiep/graph/user_model.dart';
import 'package:doantotnghiep/main_menu/patient_info_screen.dart';
import 'package:doantotnghiep/reminder/reminder_list_page.dart';
import 'package:doantotnghiep/reminder/notification_services.dart';

class MainMenuScreen extends StatefulWidget {
  final UserModel user;

  const MainMenuScreen({super.key, required this.user});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  Timer? _alarmTrackerTimer;
  bool _isDialogShowing = false;
  bool _browserInteracted = false;
  int?
      _lastTriggeredMinute; // Ngăn chặn một phút reo báo thức nhiều lần do Timer 10 giây quét lại

  @override
  void initState() {
    super.initState();
    // Tải dữ liệu từ API trước, sau đó phân phối xử lý theo nền tảng
    _fetchRemindersFromServer().then((_) {
      _startWebAlarmTracker(); // Nếu là Web/Desktop thì chạy bộ quét Timer
    });
  }

  @override
  void dispose() {
    _alarmTrackerTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchRemindersFromServer() async {
    try {
      final response = await http.get(
        Uri.parse("${AppConstant.address}/reminders/user/${widget.user.id}"),
        headers: {"Content-Type": "application/json"},
      );

      print(
          "📥 [Menu API] Tải danh sách nhắc nhở - StatusCode: ${response.statusCode}");

      if (response.statusCode == 200) {
        final resData = json.decode(response.body);
        if (resData['success'] == true && resData['data'] != null) {
          NotificationService.webRemindersList.clear(); // Làm sạch bộ nhớ tạm

          final notificationService =
              NotificationService(); // Khởi tạo instance cho Mobile

          for (var item in resData['data']) {
            if (item['reminder_time'] != null) {
              List<String> timeParts =
                  item['reminder_time'].toString().split(':');
              int serverHour = int.tryParse(timeParts[0]) ?? 0;
              int serverMinute = int.tryParse(timeParts[1]) ?? 0;
              int id = item['id'] ?? item['reminder_id'] ?? 0;
              String title = item['title'] ?? "Nhắc nhở y tế!";
              String body = item['dosage'] ?? "Thực hiện đúng giờ";

              // 1. Đồng bộ vào danh sách bộ nhớ tạm (Dùng cho giao diện hoặc tracker cục bộ)
              NotificationService.addWebReminder(
                id: id,
                title: title,
                body: body,
                hour: serverHour,
                minute: serverMinute,
              );

              // 2. 🟢 ĐÃ SỬA CHO MOBILE: Nếu chạy trên điện thoại, đăng ký lịch trực tiếp với hệ điều hành
              if (!kIsWeb) {
                await notificationService.scheduleDailyNotification(
                  id: id,
                  title: title,
                  body: body,
                  hour: serverHour,
                  minute: serverMinute,
                );
              }
            }
          }
          print(
              "✅ Đã đồng bộ thành công hệ thống nhắc nhở trên nền tảng hiện tại.");
        }
      }
    } catch (e) {
      print("🚨 Lỗi đồng bộ API tại Menu: $e");
    }
  }

  // Bộ quét cục bộ chạy bằng Timer (Chỉ áp dụng và hoạt động ổn định trên Web/Desktop)
  // 🟢 ĐÃ SỬA: Bộ quét chạy cho cả Web và Điện thoại khi ứng dụng đang mở (Foreground)
  void _startWebAlarmTracker() {
    _alarmTrackerTimer =
        Timer.periodic(const Duration(seconds: 10), (timer) async {
      final now = DateTime.now();
      final currentHour = now.hour;
      final currentMinute = now.minute;

      if (_lastTriggeredMinute == currentMinute) return;

      for (var reminder in NotificationService.webRemindersList) {
        if (reminder['hour'] == currentHour &&
            reminder['minute'] == currentMinute &&
            !_isDialogShowing) {
          _lastTriggeredMinute = currentMinute;
          _isDialogShowing = true;

          // Kích hoạt chuông reo
          NotificationService.playGlobalAlarm();

          // Hiển thị Dialog ngay tại màn hình MainMenu
          _showAlarmDialog(
            reminder['title'] ?? "Nhắc nhở y tế!",
            reminder['body'] ?? "Đã đến giờ thực hiện lịch trình của bạn.",
          );
          break;
        }
      }
    });
  }

  void _showAlarmDialog(String title, String body) {
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Color(0xFFFF5252),
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15), topRight: Radius.circular(15)),
            ),
            child: Row(
              children: [
                const Icon(Icons.alarm, color: Colors.white, size: 28),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(title,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18)),
                ),
              ],
            ),
          ),
          titlePadding: EdgeInsets.zero,
          content: Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: Text(body,
                style: const TextStyle(fontSize: 16, color: Colors.black87)),
          ),
          actions: [
            Center(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF26C6DA),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () {
                      NotificationService.stopGlobalAlarm();
                      _isDialogShowing = false;
                      Navigator.of(context).pop();
                    },
                    child: const Text("Xác nhận đã thực hiện",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16)),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFF00BCEB);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (!_browserInteracted && kIsWeb) {
          _browserInteracted = true;
          NotificationService.playGlobalAlarm();
          Future.delayed(const Duration(milliseconds: 100), () {
            NotificationService.stopGlobalAlarm();
          });
          print("🔓 [Web] Trình duyệt đã mở khóa âm thanh, sẵn sàng báo thức!");
        }
      },
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: SafeArea(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Center(
              child: ListView(
                shrinkWrap: true,
                children: [
                  MenuButton(
                    title: 'Quản lý chỉ số sức khoẻ',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              LatestMetricsScreen(userId: widget.user.id),
                        ),
                      );
                    },
                  ),
                  MenuButton(
                    title: 'Biểu đồ thống kê',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => GraphScreen(user: widget.user),
                        ),
                      );
                    },
                  ),
                  MenuButton(
                    title: 'Nhắc nhở',
                    onTap: () async {
                      // Chuyển sang trang danh sách nhắc nhở, đợi khi người dùng quay lại thì đồng bộ lại dữ liệu mới nhất
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ReminderListPage(user: widget.user),
                        ),
                      );
                      _fetchRemindersFromServer();
                    },
                  ),
                  MenuButton(
                    title: 'Xuất file PDF',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              PatientReportScreen(user: widget.user),
                        ),
                      );
                    },
                  ),
                  MenuButton(
                    title: 'Quản lý thức ăn và bài thể dục',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HealthFeaturesScreen(),
                        ),
                      );
                    },
                  ),
                  MenuButton(
                    title: 'Quản lý tài khoản và sức khoẻ cá nhân',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              PatientInfoScreen(user: widget.user),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Giữ nguyên widget MenuButton của bạn bên dưới...

class MenuButton extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const MenuButton({
    super.key,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: SizedBox(
        width: double.infinity,
        height: 60,
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
          ),
        ),
      ),
    );
  }
}
