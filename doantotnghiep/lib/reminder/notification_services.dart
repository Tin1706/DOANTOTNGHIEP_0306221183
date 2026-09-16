import 'dart:convert';
import 'package:doantotnghiep/constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:http/http.dart' as http;

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print(
      "📩 [FCM Background] Nhận Push Notification ngầm: ${message.messageId}");
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static final AudioPlayer _globalAudioPlayer = AudioPlayer();
  static bool _isAlarmPlaying = false;

  static const String _channelId = "medication_alarm_channel";
  static const String _channelName = "Nhắc nhở uống thuốc";
  static const String _channelDesc =
      "Kênh thông báo báo thức uống thuốc quan trọng";

  static GlobalKey<NavigatorState>? navigatorKey;

  Future<void> initNotification() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      criticalAlert: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      print('⚠️ Người dùng đã từ chối quyền nhận Push Notification.');
      return;
    }

    if (!kIsWeb) {
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const InitializationSettings initializationSettings =
          InitializationSettings(android: initializationSettingsAndroid);

      // 🟢 ĐÃ SỬA: Dùng named parameter `settings:`
      await _localNotifications.initialize(
        settings: initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          playGlobalAlarm();
          _showAlarmDialog(
            id: response.id ?? 0,
            title: "💊 ĐẾN GIỜ UỐNG THUỐC!",
            body: response.payload ??
                "Vui lòng kiểm tra lịch dùng thuốc của bạn.",
          );
        },
      );

      await _createNotificationChannel();
    }

    String? token;
    if (kIsWeb) {
      token = await _firebaseMessaging.getToken(
        vapidKey:
            "BEKHdUnNEHHBSnVh7GAhui_m-A5pRW0CyU3z8-QgvGZV9k28wrI8kHdiybYs3qsGs0XOzBMYO2Vk1lkuKRS13eY",
      );
      print("🌐 [Service] Đã cấu hình FCM trên Web. Token: $token");
    } else {
      token = await _firebaseMessaging.getToken();
      print("🔑 [FCM Token Device]: $token");
    }

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("📩 [FCM Foreground] Nhận Push: ${message.notification?.title}");
      _handleForegroundPush(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("🔔 [FCM Open] Người dùng nhấn vào Push Notification");
      _handleNotificationPayload(message.data);
    });

    RemoteMessage? initialMessage =
        await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      print("🚀 [FCM Cold Start] App mở từ thông báo bị đóng");
      _handleNotificationPayload(initialMessage.data);
    }
  }

  static Future<void> _createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDesc,
      importance: Importance.max,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('chuong_bao_thuc'),
      enableVibration: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  /// 🔔 Hàm kích hoạt Báo thức Toàn cục (Có thể gọi từ bất kỳ đâu)
  static Future<void> showLocalAlarmNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    print("🚨 KÍCH HOẠT BÁO THỨC TOÀN CỤC: $title");

    // 1. Phát tiếng chuông
    playGlobalAlarm();

    // 2. Hiện Local Notification trên thanh thông báo
    if (!kIsWeb) {
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDesc,
        importance: Importance.max,
        priority: Priority.high,
        fullScreenIntent: true,
        sound: RawResourceAndroidNotificationSound('chuong_bao_thuc'),
        playSound: true,
        enableVibration: true,
      );

      const NotificationDetails platformDetails =
          NotificationDetails(android: androidDetails);

      // 🟢 ĐÃ SỬA: Dùng các named parameters chính xác cho hàm show()
      await _localNotifications.show(
        id: id,
        title: title,
        body: body,
        notificationDetails: platformDetails,
        payload: body,
      );
    }

    // 3. Hiện Hộp thoại (Dialog) đè lên màn hình hiện tại
    _instance._showAlarmDialog(id: id, title: title, body: body);
  }

  static Future<void> sendFcmTokenToServer(int userId, String baseUrl) async {
    try {
      String? token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        final response = await http.post(
          Uri.parse("$baseUrl/api/diabetes-medications/update-fcm-token"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "user_id": userId,
            "fcm_token": token,
          }),
        );

        if (response.statusCode == 200) {
          print("✅ [FCM Sync] Đã đồng bộ Token với Backend cho User $userId");
        }
      }
    } catch (e) {
      print("🚨 Lỗi khi gửi FCM Token: $e");
    }
  }

  void _handleForegroundPush(RemoteMessage message) {
    String title = message.notification?.title ??
        message.data['title'] ??
        "💊 ĐẾN GIỜ UỐNG THUỐC!";
    String body = message.notification?.body ??
        message.data['body'] ??
        "Vui lòng kiểm tra lịch dùng thuốc của bạn.";
    int id = int.tryParse(message.data['id']?.toString() ?? '0') ?? 0;

    showLocalAlarmNotification(id: id, title: title, body: body);
  }

  void _handleNotificationPayload(Map<String, dynamic> data) {
    int id = int.tryParse(data['id']?.toString() ?? '0') ?? 0;
    String title = data['title'] ?? "💊 ĐẾN GIỜ UỐNG THUỐC!";
    String body = data['body'] ?? "Vui lòng sử dụng thuốc đúng liều lượng.";

    showLocalAlarmNotification(id: id, title: title, body: body);
  }

  /// 🎵 Kích hoạt âm thanh báo thức
  static void playGlobalAlarm() async {
    if (_isAlarmPlaying) return;
    _isAlarmPlaying = true;

    try {
      await _globalAudioPlayer.stop();
      await _globalAudioPlayer.setReleaseMode(ReleaseMode.loop);

      await _globalAudioPlayer.play(AssetSource('sounds/chuong_bao_thuc.wav'));
      print("🎵 [Global] Chuông báo thức đang reo...");
    } catch (e) {
      print("🚨 Lỗi kích hoạt âm thanh: $e");
      try {
        await _globalAudioPlayer.play(AssetSource('chuong_bao_thuc.wav'));
      } catch (_) {}
    }
  }

  /// 🛑 Dừng âm thanh
  static void stopGlobalAlarm() async {
    try {
      await _globalAudioPlayer.stop();
      _isAlarmPlaying = false;
      print("🛑 [Global] Đã dập tắt chuông thành công.");
    } catch (e) {
      print("🚨 Lỗi khi dừng chuông: $e");
    }
  }

  void _showAlarmDialog(
      {required int id, required String title, required String body}) {
    final context =
        navigatorKey?.currentContext ?? AppConstant.navigatorKey.currentContext;
    if (context == null) {
      print("⚠️ Không tìm thấy navigatorKey context để hiển thị Dialog!");
      return;
    }

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
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.alarm, color: Colors.white, size: 28),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
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
                      stopGlobalAlarm();
                      if (context.mounted) {
                        Navigator.of(context).pop();
                      }
                    },
                    child: const Text(
                      "Xác nhận đã thực hiện",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
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
}
