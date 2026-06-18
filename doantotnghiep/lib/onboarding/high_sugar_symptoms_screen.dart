// high_sugar_symptoms_screen.dart
import 'package:doantotnghiep/graph/user_model.dart';
import 'package:doantotnghiep/onboarding/onboarding_button.dart';
import 'package:doantotnghiep/onboarding/selection_title.dart';
import 'package:flutter/material.dart';
import 'onboarding_payload.dart';
import 'conditions_screen.dart';
import 'onboarding_api_services.dart';

class HighSugarSymptomsScreen extends StatefulWidget {
  final UserModel user;
  final OnboardingPayload payload;
  final bool isFromUpdate;
  const HighSugarSymptomsScreen(
      {super.key, required this.payload, required this.user, this.isFromUpdate = false});

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
    
    // 🌟 TỰ ĐỘNG ĐỒNG BỘ TRIỆU CHỨNG CŨ NẾU LÀ LUỒNG UPDATE MÀ PAYLOAD ĐANG TRỐNG
    if (widget.isFromUpdate && widget.payload.symptomIds.isEmpty) {
      try {
        // Kiểm tra thuộc tính chứa danh sách triệu chứng trong UserModel của bác.
        // Giả sử tên thuộc tính là `symptoms`. Nếu cấu trúc của bác khác (ví dụ: user.patientProfile.symptoms), hãy chỉnh lại nhé!
        final dynamic userSymptoms = (widget.user as dynamic).symptoms;
        if (userSymptoms != null && userSymptoms is List) {
          for (var item in userSymptoms) {
            if (item is Map) {
              final id = item['id'];
              // Chỉ nạp các ID thuộc dải Tăng đường huyết (11 đến 18) vào màn hình này
              if (id != null && id >= 11 && id <= 18) {
                widget.payload.symptomIds.add(id as int);
              }
            } else {
              final id = (item as dynamic).id;
              if (id != null && id >= 11 && id <= 18) {
                widget.payload.symptomIds.add(id as int);
              }
            }
          }
        }
      } catch (e) {
        print("Không thể tự động trích xuất ID triệu chứng cũ: $e");
      }
    }

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

                              final String symptomName = symptom['name'] ??
                                  symptom['symptom_name'] ??
                                  symptom['symptomName'] ??
                                  'Triệu chứng không rõ tên';

                              // Trạng thái hiển thị Checkbox dựa vào danh sách ID trong payload
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

              // Nút bấm đã được tích hợp cả 2 luồng độc lập
              Align(
                alignment: Alignment.center,
                child: OnboardingButton(
                  text: widget.isFromUpdate ? 'Xác nhận chọn' : 'Kế tiếp',
                  onPressed: () {
                    final hasHighSugarSymptom = widget.payload.symptomIds
                        .any((id) => id >= 11 && id <= 18);

                    if (!hasHighSugarSymptom) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              'Vui lòng chọn ít nhất một triệu chứng tăng đường huyết!'),
                          backgroundColor: Colors.red,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      return; 
                    }

                    if (widget.isFromUpdate) {
                      // 1. LUỒNG CẬP NHẬT: Duyệt mảng lấy ra danh sách TÊN triệu chứng đã tích chọn
                      List<String> selectedNames = [];
                      for (var symptom in _filteredSymptoms) {
                        final int symptomId = symptom['id'];
                        if (widget.payload.symptomIds.contains(symptomId)) {
                          final String symptomName = symptom['name'] ??
                              symptom['symptom_name'] ??
                              symptom['symptomName'] ??
                              'Triệu chứng';
                          selectedNames.add(symptomName);
                        }
                      }
                      // Pop mảng String về cho menu trung gian gánh tiếp về UpdateHealthScreen
                      Navigator.pop(context, selectedNames);
                    } else {
                      // 2. LUỒNG ONBOARDING GỐC
                      final updatedPayload = widget.payload.copyWith(
                        symptomIds: widget.payload.symptomIds,
                      );

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ConditionsScreen(
                            payload: updatedPayload,
                            user: widget.user,
                          ),
                        ),
                      );
                    }
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