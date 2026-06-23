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

      // 🟢 KIỂM TRA AN TOÀN: Nếu nhắc nhở cũ có gắn với thuốc (> 0) thì mới khởi tạo thuốc
      if (oldData.medicationDictionaryId != null &&
          oldData.medicationDictionaryId! > 0) {
        _selectedMedication = Medication(
          id: oldData
              .medicationDictionaryId!, // Thêm dấu "!" vì ta đã chắc chắn nó không null sau cú check ở trên
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
    // 🟢 BỎ HOÀN TOÀN ĐOẠN CHẶN IF-EMPTY CŨ ĐỂ KHÔNG BẮT BUỘC NHẬP ĐẦY ĐỦ

    // Xử lý định dạng giờ (Nếu không chọn giờ thì mặc định là 00:00:00)
    String timeStr = "00:00:00";
    if (_selectedTime != null) {
      timeStr =
          "${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}:00";
    }

    // Tự động tối ưu tiêu đề nhắc nhở nếu người dùng để trống ô nhập
    String finalTitle = _titleController.text.trim();
    if (finalTitle.isEmpty) {
      finalTitle = _selectedMedication == null
          ? "Nhắc nhở đo đường huyết" // Mặc định nếu không chọn cả thuốc lẫn chữ
          : _selectedMedication!
              .medicationName; // Lấy luôn tên thuốc làm tiêu đề nếu có chọn thuốc
    }

    // Đóng gói JSON Payload gửi lên Python Server
    // Thay đổi dòng medication_dictionary_id:
    final bodyData = {
      "user_id": widget.user.id,
      "medication_dictionary_id": _selectedMedication
          ?.id, // 🟢 Bỏ hẳn "?? 0" đi, để nó tự ra null nếu không chọn thuốc
      "title": finalTitle,
      "dosage": _dosageController.text.trim().isEmpty
          ? "Thực hiện đúng giờ"
          : _dosageController.text.trim(),
      "reminder_time": timeStr,
      "is_active": true,
      "sound_file": "chuong_bao_thuc.wav"
    };

    try {
      http.Response response;
      bool isSuccess = false;

      if (widget.reminderToUpdate == null) {
        // --- LUỒNG 1: THÊM MỚI (POST) ---
        response = await http.post(
          Uri.parse("$baseUrl/reminders/create"),
          headers: {"Content-Type": "application/json"},
          body: json.encode(bodyData),
        );

        print("Đang thêm mới - StatusCode: ${response.statusCode}");

        if (response.statusCode == 201 || response.statusCode == 200) {
          final resData = json.decode(response.body);
          if (resData['success'] == true) {
            final serverData = resData['data'];
            isSuccess = true;

            // Chỉ đặt lịch thông báo cục bộ nếu người dùng THỰC SỰ có chọn giờ
            if (!kIsWeb && _selectedTime != null && serverData != null) {
              await NotificationService().scheduleDailyNotification(
                id: serverData['reminder_id'] ?? 0,
                title: serverData['title'] ?? bodyData['title'],
                body: serverData['body'] ?? bodyData['dosage'],
                hour: serverData['hour'] ?? _selectedTime!.hour,
                minute: serverData['minute'] ?? _selectedTime!.minute,
                sound: 'chuong_bao_thuc',
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

        print("Đang cập nhật - StatusCode: ${response.statusCode}");

        if (response.statusCode == 200 || response.statusCode == 204) {
          final resData = json.decode(response.body);

          if (resData['success'] == true || resData['data'] != null) {
            isSuccess = true;
            final serverData = resData['data'];

            if (!kIsWeb) {
              await NotificationService()
                  .cancelNotification(widget.reminderToUpdate!.id);

              // Chỉ kích hoạt lại lịch báo thức khi có giờ giấc hợp lệ
              if (serverData != null &&
                  serverData['is_active'] == true &&
                  _selectedTime != null) {
                await NotificationService().scheduleDailyNotification(
                  id: serverData['reminder_id'] ?? widget.reminderToUpdate!.id,
                  title: serverData['title'] ?? bodyData['title'],
                  body: serverData['body'] ?? bodyData['dosage'],
                  hour: serverData['hour'] ?? _selectedTime!.hour,
                  minute: serverData['minute'] ?? _selectedTime!.minute,
                  sound: 'chuong_bao_thuc',
                );
              }
            }
          }
        }
      }

      if (isSuccess && mounted) {
        print("Điều hướng thành công về ReminderListPage!");
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => ReminderListPage(user: widget.user),
          ),
          (route) => route.isFirst,
        );
      }
    } catch (e) {
      print("Lỗi hệ thống: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã xảy ra lỗi kết nối: $e')),
        );
      }
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
