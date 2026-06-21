import 'package:doantotnghiep/FoodAndExercise/health_features.dart';
import 'package:doantotnghiep/PDF/patient_report_screen.dart';
import 'package:doantotnghiep/graph/graph_screen.dart';
import 'package:doantotnghiep/health_metrics/latest_metrics_screen.dart';
import 'package:doantotnghiep/graph/user_model.dart'; 
import 'package:doantotnghiep/main_menu/patient_info_screen.dart';
import 'package:doantotnghiep/reminder/reminder_list_page.dart';
import 'package:flutter/material.dart';

class MainMenuScreen extends StatelessWidget {
  final UserModel user;
  
  const MainMenuScreen({super.key, required this.user});

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
                        builder: (context) => LatestMetricsScreen(userId: user.id),
                      ),
                    );
                  },
                ),
                MenuButton(
                  title: 'Biểu đồ thống kê',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => GraphScreen(user: user),
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
                        // 🟢 ĐÃ FIX LỖI DÒNG 54: Bỏ const và truyền 'user' vào chuẩn bài
                        builder: (context) => ReminderListPage(user: user),
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
                        // 🟢 ĐÃ FIX LỖI DÒNG 54: Bỏ const và truyền 'user' vào chuẩn bài
                        builder: (context) => PatientReportScreen(user: user),
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
                        builder: (context) => PatientInfoScreen(user: user),
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