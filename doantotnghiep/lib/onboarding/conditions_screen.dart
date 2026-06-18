// conditions_screen.dart
import 'package:doantotnghiep/graph/user_model.dart';
import 'package:doantotnghiep/main_menu/main_menu_screen.dart';
import 'package:doantotnghiep/onboarding/onboarding_button.dart';
import 'package:doantotnghiep/onboarding/selection_title.dart';
import 'package:flutter/material.dart';
import 'onboarding_payload.dart';
import 'onboarding_api_services.dart';

class ConditionsScreen extends StatefulWidget {
  final UserModel user;
  final OnboardingPayload payload;
  final bool isFromUpdate;
  const ConditionsScreen(
      {super.key,
      required this.payload,
      required this.user,
      this.isFromUpdate = false});

  @override
  State<ConditionsScreen> createState() => _ConditionsScreenState();
}

class _ConditionsScreenState extends State<ConditionsScreen> {
  final OnboardingApiService _apiService = OnboardingApiService();

  // 🌟 Dữ liệu bây giờ sẽ là danh sách động lấy từ Database chứ không hardcode nữa
  List<Map<String, dynamic>> _conditionsList = [];
  bool _isPageLoading = true; // Loading khi tải danh sách từ DB
  bool _isSubmitting = false; // Loading khi bấm nút Hoàn thành
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchConditionsFromServer();
  }

  // Hàm đồng bộ dữ liệu từ MySQL thông qua FastAPI
  void _fetchConditionsFromServer() async {
    try {
      final data = await _apiService.getConditions();
      setState(() {
        _conditionsList = data;
        _isPageLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isPageLoading = false;
      });
    }
  }

  // Hàm xử lý gửi dữ liệu lên Backend (Chỉ dành cho Luồng Đăng ký gốc)
  void _submitData() async {
    if (widget.payload.conditionIds == null ||
        widget.payload.conditionIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Vui lòng chọn ít nhất một bệnh nền trước khi hoàn thành!'),
          backgroundColor: Colors.red, // Hiện màu đỏ cho nổi bật cảnh báo
          behavior: SnackBarBehavior.floating,
        ),
      );
      return; // 🛑 Dừng luôn tại đây, không chạy các lệnh gửi API phía dưới nữa
    }
    print("🚀 Payload chuẩn bị gửi lên FastAPI: ${widget.payload.toMap()}");
    if (widget.payload.userId <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Lỗi: ID người dùng không hợp lệ (user_id phải lớn hơn 0). Vui lòng đăng nhập lại.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final result = await _apiService.submitOnboarding(widget.payload.toMap());

      if (!mounted) return;

      final profileId = result['data']['patient_profile_id'];
      final bmi = result['data']['bmi'];

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Khởi tạo hồ sơ số #$profileId thành công! BMI: $bmi 🎉'),
          backgroundColor: const Color(0xFF00E676),
        ),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (context) => MainMenuScreen(
                  user: widget.user,
                )),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const mainCyanColor = Color(0xFF00BCEB);

    return Scaffold(
      backgroundColor: mainCyanColor,
      appBar: AppBar(
        title: const Text(
          'Chọn bệnh nền',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: mainCyanColor,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SelectionTitle(
                title: 'Bệnh nền của bạn',
                subtitle:
                    'Vui lòng chọn loại bệnh lý hoặc biến chứng được chẩn đoán để cá nhân hóa chỉ số đo.',
              ),

              // Xử lý các trạng thái hiển thị của danh sách cuộn
              Expanded(
                child: _isPageLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.white))
                    : _errorMessage != null
                        ? Center(
                            child: Text(
                              '❌ $_errorMessage\nHãy kiểm tra xem Backend FastAPI đã bật chưa nhé!',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 15),
                            ),
                          )
                        : ListView.builder(
                            itemCount: _conditionsList.length,
                            itemBuilder: (context, index) {
                              final condition = _conditionsList[index];
                              // Giả sử cấu trúc mỗi item từ backend là: {"id": 1, "name": "Tiểu đường loại 1"}
                              final int conditionId = condition['id'];
                              final String conditionName = condition['name'] ??
                                  condition['condition_name'] ??
                                  condition['conditionName'] ??
                                  'Bệnh nền không rõ tên';

                              // Trạng thái Checked: Nếu id nằm trong mảng payload truyền sang, ô sẽ tự động chọn sẵn!
                              final isSelected = widget.payload.conditionIds
                                  .contains(conditionId);

                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4.0),
                                child: Card(
                                  color: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: CheckboxListTile(
                                    title: Text(
                                      conditionName,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black,
                                      ),
                                    ),
                                    value: isSelected,
                                    activeColor: const Color(0xFF00E676),
                                    checkColor: Colors.white,
                                    controlAffinity:
                                        ListTileControlAffinity.trailing,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    onChanged: (bool? value) {
                                      setState(() {
                                        if (value == true) {
                                          widget.payload.conditionIds
                                              .add(conditionId);
                                        } else {
                                          widget.payload.conditionIds
                                              .remove(conditionId);
                                        }
                                      });
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
              ),

              // Cụm xử lý nút bấm Hoàn thành ở dưới cùng
              Align(
                alignment: Alignment.center,
                child: _isSubmitting
                    ? const Padding(
                        padding: EdgeInsets.only(top: 16.0),
                        child: SizedBox(
                          width: 45,
                          height: 45,
                          child: CircularProgressIndicator(color: Colors.white),
                        ),
                      )
                    : widget.isFromUpdate
                        ? OnboardingButton(
                            text: 'Xác nhận chọn bệnh', // 🌟 Đổi tên nút khi ở luồng Update
                            onPressed: () {
                              // Chặn cảnh báo đỏ nếu người dùng bỏ tích chọn toàn bộ item ở luồng Update
                              if (widget.payload.conditionIds.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Vui lòng chọn ít nhất một bệnh nền trước khi xác nhận!'),
                                    backgroundColor: Colors.red,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                                return;
                              }

                              // Thu thập danh sách tên bệnh nền đã được tích chọn Checkbox
                              List<String> selectedNames = [];
                              for (var condition in _conditionsList) {
                                final int conditionId = condition['id'];
                                if (widget.payload.conditionIds
                                    .contains(conditionId)) {
                                  selectedNames.add(condition['name'] ??
                                      condition['condition_name'] ??
                                      'Bệnh nền');
                                }
                              }
                              // POP VÀ TRẢ MẢNG STRING VỀ CHO UPDATE_HEALTH_SCREEN
                              Navigator.pop(context, selectedNames);
                            },
                          )
                        : OnboardingButton(
                            text: 'Hoàn thành', // Giữ nguyên nút luồng Register cũ
                            onPressed: _submitData,
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}