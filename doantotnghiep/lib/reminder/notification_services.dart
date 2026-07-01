import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:audioplayers/audioplayers.dart';
import 'package:doantotnghiep/main.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class NotificationService {
  static final List<Map<String, dynamic>> webRemindersList = [];
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static final AudioPlayer _globalAudioPlayer = AudioPlayer();
  static bool _isAlarmPlaying = false;

  static void addWebReminder({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) {
    webRemindersList.add({
      'id': id,
      'title': title,
      'body': body,
      'hour': hour,
      'minute': minute,
    });
    print("📥 [Service] Đã đồng bộ nhắc nhở mới: $hour:$minute - $title");
  }

  Future<void> initNotification() async {
    if (kIsWeb) {
      print("🌐 [Service] Đang chạy trên nền tảng Web, bỏ qua khởi tạo thông báo gốc Mobile.");
      return;
    }

    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Ho_Chi_Minh'));

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await flutterLocalNotificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        _handleNotificationClick(response.payload);
      },
    );
  }

  static void playGlobalAlarm() async {
    if (_isAlarmPlaying) return;
    _isAlarmPlaying = true;

    try {
      await _globalAudioPlayer.setReleaseMode(ReleaseMode.loop);
      await _globalAudioPlayer.play(AssetSource('chuong_bao_thuc.wav'));
      print("🎵 [Global] Chuông báo thức tĩnh đang reo liên tục...");
    } catch (e) {
      print("🚨 Lỗi kích hoạt âm thanh: $e");
    }
  }

  static void stopGlobalAlarm() async {
    try {
      await _globalAudioPlayer.stop();
      _isAlarmPlaying = false;
      print("🛑 [Global] Đã dập tắt chuông thành công.");
    } catch (e) {
      print("🚨 Lỗi khi dừng chuông: $e");
    }
  }

  void _handleNotificationClick(String? payload) {
    // Kích hoạt chuông ngay lập tức bất kể app đang ở trạng thái nào
    playGlobalAlarm();

    final context = navigatorKey.currentContext;
    if (context == null) {
      print("⚠️ [Warning] Context null. App đang chạy ngầm hoặc đã bị đóng hoàn toàn.");
      print("🎵 Chuông vẫn reo. Người dùng cần mở app lên để tắt.");
      return;
    }

    int notificationId = 0;
    String title = "ĐẾN GIỜ UỐNG THUỐC!";
    String body = "Hệ thống phát hiện đã đến lịch hẹn y tế. Vui lòng sử dụng thuốc đúng liều lượng:";

    if (payload != null && payload.contains('|')) {
      final parts = payload.split('|');
      if (parts.length >= 3) {
        notificationId = int.tryParse(parts[0]) ?? 0;
        title = parts[1];
        body = parts[2];
      }
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Color(0xFFFF5252),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
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
            child: Text(
              body,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ),
          actions: [
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF26C6DA),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () async {
                      stopGlobalAlarm();
                      await cancelNotification(notificationId); 
                      if (context.mounted) {
                        Navigator.of(context).pop();
                      }
                    },
                    child: const Text(
                      "Xác nhận đã thực hiện",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> requestPermissions() async {
    final androidImplementation =
        flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidImplementation != null) {
      await androidImplementation.requestNotificationsPermission();
      await androidImplementation.requestExactAlarmsPermission();
    }
  }

  Future<void> scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'medical_alarm_channel_v6',
      'Báo thức y tế khẩn cấp',
      channelDescription: 'Kênh đổ chuông liên tục cho đến khi người dùng tắt',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('chuong_bao_thuc'),
      audioAttributesUsage: AudioAttributesUsage.alarm,
      category: AndroidNotificationCategory.alarm,
      ongoing: true,
      fullScreenIntent: true, // Kích hoạt hiển thị đè màn hình khóa nếu được cấp quyền
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: 'chuong_bao_thuc.wav',
      ),
    );

    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    print("📅 Đã lên lịch báo thức [$title] lúc: ${scheduledDate.toString()}");

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: scheduledDate,
      notificationDetails: notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle, // Đảm bảo chạy đúng giây kể cả khi máy ngủ sâu
      matchDateTimeComponents: DateTimeComponents.time,
      payload: "$id|$title|$body",
    );
  }

  Future<void> cancelNotification(int id) async {
    try {
      // ✅ ĐÃ SỬA CHUẨN CÚ PHÁP: Truyền số nguyên trực tiếp vào hàm theo quy định của thư viện
      await flutterLocalNotificationsPlugin.cancel(id: id); 
      print("🛑 Đã xóa thông báo hệ thống cho ID: $id");
    } catch (e) {
      print("🚨 Lỗi khi xóa thông báo: $e");
    }
  }
}
