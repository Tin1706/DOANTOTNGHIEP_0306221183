import 'dart:convert';
import 'package:doantotnghiep/constant.dart';
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
  final String baseUrl = AppConstant.address + "/api/diabetes-medications";
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

          // Khung giờ đáng lẽ phải uống thuốc của ngày hôm nay
          final scheduledToday = DateTime(now.year, now.month, now.day, hour, minute, 0);

          // Khung giờ đó đã trôi qua trong hôm nay (trước hiện tại ít nhất 1 phút)
          if (scheduledToday.isBefore(now.subtract(const Duration(minutes: 1)))) {
            final String todayStr = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
            
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
              // Bắn trạng thái tự động "missed" lên hệ thống
              await _sendMedicationLog(item.id, status: "missed", isAuto: true);
            }
          }
        } catch (e) {
          print("Lỗi khi quét lịch bỏ lỡ của ${item.title}: $e");
        }
      }
    }
  }

  // ⏳ LÊN LỊCH TƯƠNG LAI: KÍCH HOẠT HỆ THỐNG ĐẾM NGƯỢC BÁO THỨC TRÊN APP
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

          var scheduledDate = DateTime(now.year, now.month, now.day, hour, minute, 0);

          if (hour == now.hour && minute == now.minute) {
            print("⏰ [Báo thức] Khung giờ trùng hiện tại. Kích hoạt hiển thị!");
            Timer(const Duration(milliseconds: 500), () {
              _showAlarmDialog(item);
            });
            scheduledDate = scheduledDate.add(const Duration(days: 1));
          } else if (scheduledDate.isBefore(now)) {
            scheduledDate = scheduledDate.add(const Duration(days: 1));
          }

          final duration = scheduledDate.difference(now);
          print("⏳ Nhắc nhở [${item.title}] đã được lên lịch. Sẽ nổ sau: ${duration.inMinutes} phút");

          final timer = Timer(duration, () {
            _showAlarmDialog(item);
            _startWebAlarmSystem(reminders);
          });

          _reminderTimers.add(timer);
        } catch (e) {
          print("Lỗi định dạng thời gian của nhắc nhở ${item.title}: $e");
        }
      }
    }
  }

  // 🎯 GỬI NHẬT KÝ UỐNG THUỐC (HỖ TRỢ CẢ 'TAKEN' VÀ 'MISSED' - IN CONSOLE TRỰC QUAN)
  Future<void> _sendMedicationLog(int reminderId, {required String status, bool isAuto = false}) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/logs/log-intake"),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "user_id": widget.user.id,
          "reminder_id": reminderId,
          "status": status, // 'taken' hoặc 'missed'
          "notes": isAuto 
              ? "Hệ thống tự động ghi nhận Bỏ lỡ (missed) do người dùng không bật app đúng giờ" 
              : "Người dùng chủ động xác nhận Đã thực hiện (taken) từ màn hình App"
        }),
      );

      if (response.statusCode == 201) {
        final Map<String, dynamic> resData = json.decode(utf8.decode(response.bodyBytes));
        if (resData['success'] == true) {
          // 💻 ĐOẠN IN RA CONSOLE THEO YÊU CẦU CỦA BẠN
          if (status == "taken") {
            print("🎯 [CONSOLE LOG] Cập nhật trạng thái thành công: [TAKEN] cho reminder_id: $reminderId");
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('🎉 Hệ thống đã ghi nhận lịch sử uống thuốc thực tế!'))
              );
            }
          } else if (status == "missed") {
            print("🔴 [CONSOLE LOG] Cập nhật trạng thái thành công: [MISSED] cho reminder_id: $reminderId");
          }
        }
      } else {
        print("❌ API phản hồi code lỗi: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ LỖI HỆ THỐNG KHI GỬI LOG ($status): $e");
    }
  }

  // 🖥️ GIAO DIỆN POP-UP BÁO THỨC ĐẾN GIỜ NỔ CHUÔNG
  void _showAlarmDialog(ReminderItem item) async {
    if (!mounted) return;

    try {
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer.play(AssetSource('chuong_bao_thuc.wav'));
    } catch (e) {
      print("Không thể phát chuông báo thức: $e");
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 12,
          titlePadding: const EdgeInsets.all(0),
          title: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            decoration: const BoxDecoration(
              color: Colors.redAccent,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: const Row(
              children: [
                Icon(Icons.alarm_on, color: Colors.white, size: 28),
                SizedBox(width: 12),
                Text(
                  'ĐẾN GIỜ UỐNG THUỐC!',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ],
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Hệ thống phát hiện đã đến lịch hẹn y tế. Vui lòng sử dụng thuốc đúng liều lượng:",
                style: TextStyle(color: Colors.grey, fontSize: 13, height: 1.4),
              ),
              const SizedBox(height: 18),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.medication, color: Colors.blueGrey, size: 24),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      item.title,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  const Icon(Icons.assignment_turned_in, color: Colors.blueGrey, size: 24),
                  const SizedBox(width: 10),
                  Text("Liều lượng: ", style: TextStyle(fontSize: 15, color: Colors.grey[700])),
                  Text(item.dosage, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.cyan)),
                ],
              ),
            ],
          ),
          actionsPadding: const EdgeInsets.only(bottom: 20, right: 16, left: 16),
          actions: [
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.cyan[400],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                ),
                onPressed: () async {
                  await _audioPlayer.stop();
                  if (mounted) Navigator.of(ctx).pop();
                  
                  // Gửi log thủ công trạng thái 'taken'
                  await _sendMedicationLog(item.id, status: "taken");
                },
                child: const Text('Xác nhận đã thực hiện', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
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
      final response = await http.get(Uri.parse("$baseUrl/reminders/user/${widget.user.id}"));
      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedData = json.decode(utf8.decode(response.bodyBytes));
        if (decodedData['success'] == true) {
          final List<dynamic> listData = decodedData['data'];
          if (mounted) {
            setState(() {
              _reminders = listData.map((item) => ReminderItem.fromJson(item)).toList();
              _isLoading = false;
            });

            // 1. Quét quá khứ tìm lịch bỏ lỡ (In console: MISSED)
            _checkAndLogMissedReminders(_reminders);

            // 2. Lên lịch tương lai kích hoạt Timer
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
      final response = await http.delete(Uri.parse("$baseUrl/reminders/delete/$reminderId"));
      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã hủy bỏ lịch nhắc nhở thành công!')));
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
        title: const Text('Nhắc nhở', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : _reminders.isEmpty
              ? const Center(child: Text("Chưa có lịch nhắc nhở nào", style: TextStyle(color: Colors.white, fontSize: 16)))
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: _reminders.length,
                  itemBuilder: (context, index) {
                    final item = _reminders[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16.0),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Nội dung: ${item.title}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  const SizedBox(height: 4),
                                  Text("Tên thuốc: ${item.title}"),
                                  const SizedBox(height: 4),
                                  Text("Liều lượng: ${item.dosage}"),
                                  const SizedBox(height: 4),
                                  Text("Khung giờ: ${item.reminderTime.substring(0, 5).replaceAll(':', ' giờ ')} phút"),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.green),
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
                                  icon: const Icon(Icons.delete, color: Colors.red),
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