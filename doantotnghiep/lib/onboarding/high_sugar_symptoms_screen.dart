// high_sugar_symptoms_screen.dart
import 'package:doantotnghiep/onboarding/onboarding_button.dart';
import 'package:doantotnghiep/onboarding/selection_title.dart';
import 'package:flutter/material.dart';
import 'onboarding_payload.dart';
import 'conditions_screen.dart';
import 'onboarding_api_services.dart';

class HighSugarSymptomsScreen extends StatefulWidget {
  final int userId;
  final OnboardingPayload payload;
  const HighSugarSymptomsScreen(
      {super.key, required this.payload, required this.userId});

  @override
  State<HighSugarSymptomsScreen> createState() =>
      _HighSugarSymptomsScreenState();
}

class _HighSugarSymptomsScreenState extends State<HighSugarSymptomsScreen> {
  final OnboardingApiService _apiService = OnboardingApiService();

  List<Map<String, dynamic>> _filteredSymptoms = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchSymptomsFromServer();
  }

  void _fetchSymptomsFromServer() async {
    try {
      final List<dynamic> rawSymptoms = await _apiService.getSymptoms();

      setState(() {
        _filteredSymptoms =
            rawSymptoms.map((e) => e as Map<String, dynamic>).where((symptom) {
          final id = symptom['id'] as int;
          return id >= 11 && id <= 18; // Lọc dải ID của Tăng đường huyết
        }).toList();

        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const mainCyanColor = Color(0xFF00BCEB);

    return Scaffold(
      backgroundColor: mainCyanColor,
      appBar: AppBar(
        title: const Text(
          'Tăng đường huyết',
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
                title: 'Triệu chứng tăng đường huyết',
                subtitle:
                    'Vui lòng chọn các dấu hiệu bạn thường gặp phải khi đường huyết lên cao.',
              ),

              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.white))
                    : _errorMessage != null
                        ? Center(
                            child: Text(
                              '❌ $_errorMessage',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 15),
                            ),
                          )
                        : ListView.builder(
                            itemCount: _filteredSymptoms.length,
                            itemBuilder: (context, index) {
                              final symptom = _filteredSymptoms[index];
                              final int symptomId = symptom['id'];

                              // 🌟 FIX LỖI CRASH NULL: Tự động quét tìm đúng cột tên trong DB của bạn
                              final String symptomName = symptom['name'] ??
                                  symptom['symptom_name'] ??
                                  symptom['symptomName'] ??
                                  'Triệu chứng không rõ tên';

                              final isSelected =
                                  widget.payload.symptomIds.contains(symptomId);

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
                                      symptomName,
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
                                          widget.payload.symptomIds
                                              .add(symptomId);
                                        } else {
                                          widget.payload.symptomIds
                                              .remove(symptomId);
                                        }
                                      });
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
              ),

              // high_sugar_symptoms_screen.dart
              Align(
                alignment: Alignment.center,
                child: OnboardingButton(
                  text: 'Kế tiếp',
                  onPressed: () {
                    final hasHighSugarSymptom = widget.payload.symptomIds
                        .any((id) => id >= 11 && id <= 18);

                    if (!hasHighSugarSymptom) {
                      // Nếu chưa chọn cái nào thuộc dải ID này, lập tức quăng cảnh báo đỏ và chặn lại
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              'Vui lòng chọn ít nhất một triệu chứng tăng đường huyết!'),
                          backgroundColor: Colors.red,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      return; // 🛑 Dừng luồng xử lý, không cho chuyển màn hình
                    }
                    // 🌟 Đóng gói lại payload bằng copyWith để ép duy trì userId chuẩn chỉnh
                    final updatedPayload = widget.payload.copyWith(
                      symptomIds: widget.payload.symptomIds,
                    );

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        // Truyền updatedPayload thay vì widget.payload cũ
                        builder: (context) => ConditionsScreen(
                          payload: updatedPayload,
                          userId: widget.userId,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
