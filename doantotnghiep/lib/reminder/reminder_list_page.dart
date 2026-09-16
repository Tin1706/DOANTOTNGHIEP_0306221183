import 'dart:convert';
import 'package:doantotnghiep/constant.dart';
import 'package:doantotnghiep/graph/user_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'reminder_models.dart';
import 'add_reminder_page.dart';
import 'notification_services.dart'; // 🟢 Import NotificationService toàn cục
import 'dart:async';

class ReminderListPage extends StatefulWidget {
  final UserModel user;

  const ReminderListPage({Key? key, required this.user}) : super(key: key);

  @override
  _ReminderListPageState createState() => _ReminderListPageState();
}

class _ReminderListPageState extends State<ReminderListPage> {
  final String baseUrl = AppConstant.address + "/api/diabetes-medications";
  List<ReminderItem> _reminders = [];
  bool _isLoading = true;
  static final List<Timer> _reminderTimers =
      []; // 🟢 Giữ Timer tĩnh để không bị huỷ khi chuyển trang

  @override
  void initState() {
    super.initState();
    _fetchReminders();
  }

  @override
  void dispose() {
    // 🟢 KHÔNG cancel() Timer ở đây để báo thức vẫn đếm ngược ngầm khi về MainMenuScreen!
    super.dispose();
  }

  // 🟢 HÀM KIỂM TRA VÀ GHI NHẬN CÁC LỊCH NHẮC ĐÃ BỊ BỎ LỠ (MISSED) TRONG NGÀY
  Future<void> _checkAndLogMissedReminders(List<ReminderItem> reminders) async {
    final now = DateTime.now();

    for (var item in reminders) {
      if (item.isActive == 1) {
        final String timeStr = item.reminderTime;
        if (timeStr.isEmpty) continue;

        try {
          final parts = timeStr.split(':');
          final int hour = int.parse(parts[0]);
          final int minute = int.parse(parts[1]);

          final scheduledToday =
              DateTime(now.year, now.month, now.day, hour, minute, 0);

          if (scheduledToday
              .isBefore(now.subtract(const Duration(minutes: 1)))) {
            final String todayStr =
                "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

            final checkResponse = await http.post(
              Uri.parse("$baseUrl/calculate"),
              headers: {"Content-Type": "application/json"},
              body: json.encode({
                "user_id": widget.user.id,
                "start_date": todayStr,
                "end_date": todayStr
              }),
            );

            if (checkResponse.statusCode == 200) {
              await _sendMedicationLog(item.id, status: "missed", isAuto: true);
            }
          }
        } catch (e) {
          print("Lỗi khi quét lịch bỏ lỡ của ${item.title}: $e");
        }
      }
    }
  }

  // ⏳ LÊN LỊCH TƯƠNG LAI: KÍCH HOẠT HỆ THỐNG ĐẾM NGƯỢC BÁO THỨC TRÊN APP TOÀN CỤC
  void _startWebAlarmSystem(List<ReminderItem> reminders) {
    for (var timer in _reminderTimers) {
      timer.cancel();
    }
    _reminderTimers.clear();

    final now = DateTime.now();

    for (var item in reminders) {
      if (item.isActive == 1) {
        final String timeStr = item.reminderTime;
        if (timeStr.isEmpty) continue;

        try {
          final parts = timeStr.split(':');
          final int hour = int.parse(parts[0]);
          final int minute = int.parse(parts[1]);

          var scheduledDate =
              DateTime(now.year, now.month, now.day, hour, minute, 0);

          if (hour == now.hour && minute == now.minute) {
            print(
                "⏰ [Báo thức] Khung giờ trùng hiện tại. Kích hoạt báo thức toàn cục!");
            Timer(const Duration(milliseconds: 500), () {
              // 🟢 Gọi NotificationService toàn cục thay vì gọi hàm cục bộ
              NotificationService.showLocalAlarmNotification(
                id: item.id,
                title: "💊 ĐẾN GIỜ UỐNG THUỐC!",
                body: "${item.title} - Liều lượng: ${item.dosage}",
              );
            });
            scheduledDate = scheduledDate.add(const Duration(days: 1));
          } else if (scheduledDate.isBefore(now)) {
            scheduledDate = scheduledDate.add(const Duration(days: 1));
          }

          final duration = scheduledDate.difference(now);
          print(
              "⏳ Nhắc nhở [${item.title}] đã được lên lịch. Sẽ nổ sau: ${duration.inMinutes} phút");

          final timer = Timer(duration, () {
            // 🟢 Gọi NotificationService toàn cục khi đếm ngược về 0
            NotificationService.showLocalAlarmNotification(
              id: item.id,
              title: "💊 ĐẾN GIỜ UỐNG THUỐC!",
              body: "${item.title} - Liều lượng: ${item.dosage}",
            );
            _startWebAlarmSystem(reminders);
          });

          _reminderTimers.add(timer);
        } catch (e) {
          print("Lỗi định dạng thời gian của nhắc nhở ${item.title}: $e");
        }
      }
    }
  }

  // 🎯 GỬI NHẬT KÝ UỐNG THUỐC
  Future<void> _sendMedicationLog(int reminderId,
      {required String status, bool isAuto = false}) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/logs/log-intake"),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "user_id": widget.user.id,
          "reminder_id": reminderId,
          "status": status,
          "notes": isAuto
              ? "Hệ thống tự động ghi nhận Bỏ lỡ (missed) do người dùng không bật app đúng giờ"
              : "Người dùng chủ động xác nhận Đã thực hiện (taken) từ màn hình App"
        }),
      );

      if (response.statusCode == 201) {
        final Map<String, dynamic> resData =
            json.decode(utf8.decode(response.bodyBytes));
        if (resData['success'] == true) {
          if (status == "taken") {
            print(
                "🎯 [CONSOLE LOG] Cập nhật trạng thái thành công: [TAKEN] cho reminder_id: $reminderId");
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text(
                      '🎉 Hệ thống đã ghi nhận lịch sử uống thuốc thực tế!')));
            }
          } else if (status == "missed") {
            print(
                "🔴 [CONSOLE LOG] Cập nhật trạng thái thành công: [MISSED] cho reminder_id: $reminderId");
          }
        }
      } else {
        print("❌ API phản hồi code lỗi: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ LỖI HỆ THỐNG KHI GỬI LOG ($status): $e");
    }
  }

  // API 1: Tải danh sách nhắc nhở của User
  Future<void> _fetchReminders() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final response = await http
          .get(Uri.parse("$baseUrl/reminders/user/${widget.user.id}"));
      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedData =
            json.decode(utf8.decode(response.bodyBytes));
        if (decodedData['success'] == true) {
          final List<dynamic> listData = decodedData['data'];
          if (mounted) {
            setState(() {
              _reminders =
                  listData.map((item) => ReminderItem.fromJson(item)).toList();
              _isLoading = false;
            });

            _checkAndLogMissedReminders(_reminders);
            _startWebAlarmSystem(_reminders);
          }
        }
      }
    } catch (e) {
      print("Lỗi tải danh sách: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // API 2: Xóa mềm nhắc nhở
  Future<void> _deleteReminder(int reminderId) async {
    try {
      final response =
          await http.delete(Uri.parse("$baseUrl/reminders/delete/$reminderId"));
      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Đã hủy bỏ lịch nhắc nhở thành công!')));
        }
        _fetchReminders();
      }
    } catch (e) {
      print("Lỗi khi xóa: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.cyan[400],
      appBar: AppBar(
        backgroundColor: Colors.cyan[400],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Nhắc nhở',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : _reminders.isEmpty
              ? const Center(
                  child: Text("Chưa có lịch nhắc nhở nào",
                      style: TextStyle(color: Colors.white, fontSize: 16)))
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: _reminders.length,
                  itemBuilder: (context, index) {
                    final item = _reminders[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16.0),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Nội dung: ${item.title}",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16)),
                                  const SizedBox(height: 4),
                                  Text("Tên thuốc: ${item.title}"),
                                  const SizedBox(height: 4),
                                  Text("Liều lượng: ${item.dosage}"),
                                  const SizedBox(height: 4),
                                  Text(
                                      "Khung giờ: ${item.reminderTime.length >= 5 ? item.reminderTime.substring(0, 5).replaceAll(':', ' giờ ') : item.reminderTime} phút"),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit,
                                      color: Colors.green),
                                  onPressed: () async {
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => AddReminderPage(
                                          user: widget.user,
                                          reminderToUpdate: item,
                                        ),
                                      ),
                                    );
                                    if (result == true) {
                                      _fetchReminders();
                                    }
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () => _deleteReminder(item.id),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        child: const Icon(Icons.add, color: Colors.black, size: 30),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddReminderPage(
                user: widget.user,
                reminderToUpdate: null,
              ),
            ),
          );
          if (result == true) {
            _fetchReminders();
          }
        },
      ),
    );
  }
}
