import 'package:doantotnghiep/constant.dart';
import 'package:flutter/material.dart';
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

  const MainMenuScreen({
    super.key,
    required this.user,
  });

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  @override
  void initState() {
    super.initState();
    _syncFcmToken();
  }

  /// Tự động gửi FCM Token của người dùng hiện tại lên FastAPI Backend bằng AppConstants.address
  Future<void> _syncFcmToken() async {
    try {
      // Dùng AppConstants.address làm baseUrl cho API
      await NotificationService.sendFcmTokenToServer(
        widget.user.id, 
        AppConstant.address,
      );
      print("✅ [MainMenu] Đã đồng bộ FCM token cho User ${widget.user.id} thành công.");
    } catch (e) {
      print("🚨 [MainMenu] Lỗi đồng bộ FCM Token: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFF00BCEB);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
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
                        builder: (context) => LatestMetricsScreen(userId: widget.user.id),
                      ),
                    );
                  },
                ),
                MenuButton(
                  title: 'Biểu đồ thống kê',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GraphScreen(user: widget.user),
                      ),
                    );
                  },
                ),
                MenuButton(
                  title: 'Nhắc nhở',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ReminderListPage(user: widget.user),
                      ),
                    );
                  },
                ),
                MenuButton(
                  title: 'Xuất file PDF',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PatientReportScreen(user: widget.user),
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
                        builder: (context) => PatientInfoScreen(user: widget.user),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}