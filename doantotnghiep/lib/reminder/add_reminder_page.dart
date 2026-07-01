import 'dart:convert';
import 'package:doantotnghiep/constant.dart';
import 'package:doantotnghiep/graph/user_model.dart';
import 'package:doantotnghiep/reminder/medication_category.dart';
import 'package:doantotnghiep/reminder/notification_services.dart';
import 'package:doantotnghiep/reminder/reminder_list_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:doantotnghiep/reminder/reminder_models.dart';
import 'package:flutter/foundation.dart';

class AddReminderPage extends StatefulWidget {
  final UserModel user;
  final ReminderItem? reminderToUpdate;

  const AddReminderPage({Key? key, required this.user, this.reminderToUpdate})
      : super(key: key);

  @override
  _AddReminderPageState createState() => _AddReminderPageState();
}

class _AddReminderPageState extends State<AddReminderPage> {
  final String baseUrl = AppConstant.address + "/api/diabetes-medications";

  final _titleController = TextEditingController();
  final _dosageController = TextEditingController();

  Medication? _selectedMedication;
  TimeOfDay? _selectedTime;

  @override
  void initState() {
    super.initState();
    if (widget.reminderToUpdate != null) {
      final oldData = widget.reminderToUpdate!;
      _titleController.text = oldData.title;
      _dosageController.text = oldData.dosage;

      if (oldData.reminderTime.isNotEmpty) {
        final parts = oldData.reminderTime.split(':');
        _selectedTime =
            TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
      }

      if (oldData.medicationDictionaryId != null &&
          oldData.medicationDictionaryId! > 0) {
        _selectedMedication = Medication(
          id: oldData.medicationDictionaryId!,
          medicationName: oldData.title,
          medicationCategory: "",
        );
      } else {
        _selectedMedication = null;
      }
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _submitData() async {
    String timeStr = "00:00:00";
    if (_selectedTime != null) {
      timeStr =
          "${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}:00";
    }

    String finalTitle = _titleController.text.trim();
    if (finalTitle.isEmpty) {
      finalTitle = _selectedMedication == null
          ? "Nhắc nhở đo đường huyết"
          : _selectedMedication!.medicationName;
    }

    final bodyData = {
      "user_id": widget.user.id,
      "medication_dictionary_id": _selectedMedication?.id,
      "title": finalTitle,
      "dosage": _dosageController.text.trim().isEmpty
          ? "Thực hiện đúng giờ"
          : _dosageController.text.trim(),
      "reminder_time": timeStr,
      "is_active": true,
      "sound_file": "chuong_bao_thuc.wav"
    };

    // Tạo sẵn biến để lưu trạng thái phản hồi từ API gốc
    bool apiCallWorked = false;

    try {
      http.Response response;

      if (widget.reminderToUpdate == null) {
        // --- LUỒNG 1: THÊM MỚI (POST) ---
        response = await http.post(
          Uri.parse("$baseUrl/reminders/create"),
          headers: {"Content-Type": "application/json"},
          body: json.encode(bodyData),
        );

        if (response.statusCode == 201 || response.statusCode == 200) {
          final resData = json.decode(response.body);
          if (resData['success'] == true) {
            apiCallWorked = true;
            final serverData = resData['data'];

            // 📱 Cấu hình cho Mobile (Android/iOS)
            // 📱 Cấu hình cho Mobile (Android/iOS)
            if (!kIsWeb && _selectedTime != null) {
              try {
                // Nếu server không trả về reminder_id, tự tạo một ID int ngẫu nhiên để không bị crash
                final int mobileId =
                    (serverData != null ? serverData['reminder_id'] : null) ??
                        (DateTime.now().millisecondsSinceEpoch & 0x7FFFFFFF);

                await NotificationService().scheduleDailyNotification(
                  id: mobileId,
                  title: (serverData != null ? serverData['title'] : null) ??
                      finalTitle,
                  body: (serverData != null ? serverData['body'] : null) ??
                      bodyData['dosage'].toString(),
                  hour: _selectedTime!.hour,
                  minute: _selectedTime!.minute,
                );
              } catch (soundError) {
                print("🚨 Lỗi nạp thông báo Android: $soundError");
              }
            }

            // 🌐 Cấu hình cho WEB
            if (kIsWeb && _selectedTime != null) {
              final int rId =
                  (serverData != null ? serverData['reminder_id'] : null) ??
                      DateTime.now().millisecondsSinceEpoch ~/ 1000;
              NotificationService.addWebReminder(
                id: rId,
                title: finalTitle,
                body: bodyData['dosage'].toString(),
                hour: _selectedTime!.hour,
                minute: _selectedTime!.minute,
              );
            }
          }
        }
      } else {
        // --- LUỒNG 2: CẬP NHẬT (PUT) ---
        response = await http.put(
          Uri.parse("$baseUrl/reminders/update/${widget.reminderToUpdate!.id}"),
          headers: {"Content-Type": "application/json"},
          body: json.encode(bodyData),
        );

        if (response.statusCode == 200 || response.statusCode == 204) {
          final resData = json.decode(response.body);
          if (resData['success'] == true || resData['data'] != null) {
            apiCallWorked = true;
            final serverData = resData['data'];

            // 📱 Cấu hình cho Mobile (Android/iOS)
            // 📱 Cấu hình cho Mobile (Android/iOS)
            if (!kIsWeb && _selectedTime != null) {
              try {
                await NotificationService()
                    .cancelNotification(widget.reminderToUpdate!.id);

                await NotificationService().scheduleDailyNotification(
                  id: widget.reminderToUpdate!.id,
                  title: finalTitle,
                  body: bodyData['dosage'].toString(),
                  hour: _selectedTime!.hour,
                  minute: _selectedTime!.minute,
                );
              } catch (soundError) {
                print("🚨 Lỗi cập nhật thông báo Android: $soundError");
              }
            }

            // 🌐 Cấu hình cho WEB khi sửa
            if (kIsWeb && _selectedTime != null) {
              NotificationService.webRemindersList.removeWhere(
                  (element) => element['id'] == widget.reminderToUpdate!.id);

              NotificationService.addWebReminder(
                id: widget.reminderToUpdate!.id,
                title: finalTitle,
                body: bodyData['dosage'].toString(),
                hour: _selectedTime!.hour,
                minute: _selectedTime!.minute,
              );
            }
          }
        }
      }
    } catch (e) {
      print("Lỗi kết nối API hoặc hệ thống: $e");
      // Mẹo nhỏ: Đặt apiCallWorked = true ở đây nếu bạn muốn bất chấp API lỗi kết nối vẫn chuyển trang
      apiCallWorked = true;
    }

    // 🟢 LUÔN LUÔN CHUYỂN TRANG: Chuyển khối lệnh điều hướng ra rìa ngoài cùng,
    // Chỉ cần bấm nút và chạy xong xử lý là tự động quay về danh sách.
    if (mounted) {
      print("🔄 Ép buộc điều hướng thành công về ReminderListPage!");
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => ReminderListPage(user: widget.user),
        ),
        (route) => route.isFirst,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isUpdate = widget.reminderToUpdate != null;

    return Scaffold(
      backgroundColor: Colors.cyan[400],
      appBar: AppBar(
        backgroundColor: Colors.cyan[400],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(isUpdate ? 'Cập nhật nhắc nhở' : 'Nhắc nhở',
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            _buildInputField(
              label: "Nội dung nhắc nhở",
              child: TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: "Ví dụ: Đến giờ đo đường huyết, Tập thể dục..."),
              ),
            ),
            const SizedBox(height: 16),
            _buildInputField(
              label: "Tên thuốc uống / chích (Không bắt buộc)",
              child: InkWell(
                onTap: () async {
                  final Medication? result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          MedicationCategoryPage(user: widget.user),
                    ),
                  );

                  if (result != null) {
                    setState(() {
                      _selectedMedication = result;
                    });
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          _selectedMedication == null
                              ? "Không chọn (Nhắc nhở đo đường huyết/tự do...)"
                              : _selectedMedication!.medicationName,
                          style: TextStyle(
                            fontSize: 16,
                            color: _selectedMedication == null
                                ? Colors.black54
                                : Colors.black,
                            fontWeight: _selectedMedication == null
                                ? FontWeight.normal
                                : FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios,
                          size: 16, color: Colors.grey),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildInputField(
              label: "Liều lượng (Không bắt buộc)",
              child: TextField(
                controller: _dosageController,
                decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: "Ví dụ: 500mg, Tiêm 1 lần..."),
              ),
            ),
            const SizedBox(height: 16),
            _buildInputField(
              label: "Khung giờ",
              child: InkWell(
                onTap: () => _selectTime(context),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedTime == null
                            ? "Bấm để thiết lập giờ"
                            : "${_selectedTime!.hour.toString().padLeft(2, '0')} giờ ${_selectedTime!.minute.toString().padLeft(2, '0')} phút",
                        style: const TextStyle(fontSize: 16),
                      ),
                      const Icon(Icons.access_time, color: Colors.grey),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _submitData,
              style: ElevatedButton.styleFrom(
                backgroundColor: isUpdate ? Colors.orange : Colors.green,
                padding:
                    const EdgeInsets.symmetric(horizontal: 48, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
              ),
              child: Text(isUpdate ? 'Cập nhật' : 'Xác nhận',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({required String label, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16)),
          child,
        ],
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _dosageController.dispose();
    super.dispose();
  }
}
