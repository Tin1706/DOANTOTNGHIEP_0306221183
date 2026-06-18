import 'dart:convert';
import 'package:doantotnghiep/graph/user_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'reminder_models.dart';
import 'add_reminder_page.dart';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart'; // 🟢 1. THÊM THƯ VIỆN ĐỂ PHÁT CHUÔNG

class ReminderListPage extends StatefulWidget {
  final UserModel user;

  const ReminderListPage({Key? key, required this.user}) : super(key: key);

  @override
  _ReminderListPageState createState() => _ReminderListPageState();
}

class _ReminderListPageState extends State<ReminderListPage> {
  final String baseUrl = "http://localhost:8000/api/diabetes-medications";
  List<ReminderItem> _reminders = [];
  bool _isLoading = true;
  final List<Timer> _reminderTimers = [];

  // 🟢 2. KHỞI TẠO PLAYER ĐỂ ĐIỀU KHIỂN ÂM THANH
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _fetchReminders();
  }

  @override
  void dispose() {
    for (var timer in _reminderTimers) {
      timer.cancel();
    }
    _audioPlayer
        .dispose(); // 🟢 3. GIẢI PHÓNG BỘ NHỚ CỦA PLAYER KHI THOÁT TRANG
    super.dispose();
  }

  // 🟢 Hàm quét danh sách nhắc nhở và lên lịch đếm ngược
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
                "⏰ [Báo thức] Phát hiện nhắc nhở [${item.title}] trùng giờ phút hiện tại. Kích hoạt hiển thị!");

            Timer(const Duration(milliseconds: 500), () {
              _showAlarmDialog(item.title, item.dosage);
            });

            scheduledDate = scheduledDate.add(const Duration(days: 1));
          } else if (scheduledDate.isBefore(now)) {
            scheduledDate = scheduledDate.add(const Duration(days: 1));
          }

          final duration = scheduledDate.difference(now);
          print(
              "⏳ Nhắc nhở [${item.title}] đã được lên lịch. Sẽ nổ tiếp theo sau: ${duration.inMinutes} minutes (${duration.inSeconds} seconds)");

          final timer = Timer(duration, () {
            _showAlarmDialog(item.title, item.dosage);
            _startWebAlarmSystem(reminders);
          });

          _reminderTimers.add(timer);
        } catch (e) {
          print("Lỗi định dạng thời gian của nhắc nhở ${item.title}: $e");
        }
      }
    }
  }

  // 🖥️ Hàm hiển thị AlertDialog báo thức ngay tại màn hình danh sách
  void _showAlarmDialog(String title, String dosage) async {
    if (!mounted) return;

    // 🟢 4. KHI NỔ POP-UP: PHÁT LẶP ĐI LẶP LẠI FILE CHUÔNG BÁO THỨC TRONG ASSETS
    try {
      await _audioPlayer.setReleaseMode(
          ReleaseMode.loop); // Đặt chế độ lặp vô hạn cho đến khi tắt
      await _audioPlayer.play(AssetSource('chuong_bao_thuc.mp3'));
    } catch (e) {
      print("Không thể phát chuông báo thức: $e");
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext ctx) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.alarm, color: Colors.cyan, size: 30),
              SizedBox(width: 10),
              Text('⏰ GIỜ BÁO THỨC!',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87)),
              const SizedBox(height: 8),
              Text("Liều lượng: $dosage",
                  style: const TextStyle(fontSize: 16, color: Colors.blueGrey)),
            ],
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.cyan[400],
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () async {
                await _audioPlayer
                    .stop(); // 🟢 5. KHI BỆNH NHÂN BẤM NÚT "ĐÃ UỐNG": TẮT CHUÔNG NGAY
                if (mounted) Navigator.of(ctx).pop();
              },
              child: const Text('Đã thực hiện',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
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
                                  Text(
                                      "Tên thuốc: ${item.title}"),
                                  const SizedBox(height: 4),
                                  Text("Liều lượng: ${item.dosage}"),
                                  const SizedBox(height: 4),
                                  Text(
                                      "Khung giờ: ${item.reminderTime.substring(0, 5).replaceAll(':', ' giờ ')} phút"),
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
