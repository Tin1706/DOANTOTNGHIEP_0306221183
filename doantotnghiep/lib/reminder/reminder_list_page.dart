import 'dart:convert';
import 'package:doantotnghiep/graph/user_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'reminder_models.dart';
import 'add_reminder_page.dart';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';

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
    _audioPlayer.dispose();
    super.dispose();
  }

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
              _showAlarmDialog(item); // 🟢 Sửa: Truyền cả object item vào dialog
            });

            scheduledDate = scheduledDate.add(const Duration(days: 1));
          } else if (scheduledDate.isBefore(now)) {
            scheduledDate = scheduledDate.add(const Duration(days: 1));
          }

          final duration = scheduledDate.difference(now);
          print(
              "⏳ Nhắc nhở [${item.title}] đã được lên lịch. Sẽ nổ tiếp theo sau: ${duration.inMinutes} minutes (${duration.inSeconds} seconds)");

          final timer = Timer(duration, () {
            _showAlarmDialog(item); // 🟢 Sửa: Truyền cả object item vào dialog
            _startWebAlarmSystem(reminders);
          });

          _reminderTimers.add(timer);
        } catch (e) {
          print("Lỗi định dạng thời gian của nhắc nhở ${item.title}: $e");
        }
      }
    }
  }

  // 🟢 THÊM HÀM GỌI API GHI NHẬT KÝ VÀO BẢNG MEDICATION_LOGS
  Future<void> _sendMedicationLog(int reminderId) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/logs/log-intake"),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "user_id": widget.user.id,
          "reminder_id": reminderId,
          "status": "taken", // Trạng thái 'taken' giúp backend tính điểm tuân thủ
          "notes": "Người dùng xác nhận hành động từ pop-up thông báo trên App"
        }),
      );

      if (response.statusCode == 201) {
        final Map<String, dynamic> resData = json.decode(utf8.decode(response.bodyBytes));
        if (resData['success'] == true) {
          print("🎯 THÀNH CÔNG: Đã lưu bản ghi lịch sử vào bảng medication_logs (Log ID: ${resData['data']['log_id']})");
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('🎉 Hệ thống đã ghi nhận lịch sử uống thuốc thực tế!'))
            );
          }
        }
      } else {
        print("❌ LỖI KẾT NỐI API: Mã lỗi ${response.statusCode}");
      }
    } catch (e) {
      print("❌ LỖI HỆ THỐNG KHI GỬI LOG: $e");
    }
  }

  // 🖥️ Hàm hiển thị AlertDialog báo thức ngay tại màn hình danh sách
  void _showAlarmDialog(ReminderItem item) async { // 🟢 Sửa tham số nhận vào cả Object ReminderItem
    if (!mounted) return;

    try {
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer.play(AssetSource('chuong_bao_thuc.mp3'));
    } catch (e) {
      print("Không thể phát chuông báo thức: $e");
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
              Text(item.title,
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87)),
              const SizedBox(height: 8),
              Text("Liều lượng: ${item.dosage}",
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
                // 1. Tắt chuông báo thức ngay lập tức
                await _audioPlayer.stop();
                
                // 2. Tắt màn hình thông báo Pop-up
                if (mounted) Navigator.of(ctx).pop();

                // 3. 🟢 KÍCH HOẠT: Gọi API bắn dữ liệu vào MySQL ngay sau khi nhấn nút
                await _sendMedicationLog(item.id);
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
                                  Text("Tên thuốc: ${item.title}"),
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