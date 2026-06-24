import 'dart:convert';
import 'package:doantotnghiep/constant.dart';
import 'package:doantotnghiep/onboarding/conditions_screen.dart';
import 'package:doantotnghiep/onboarding/onboarding_payload.dart';
import 'package:doantotnghiep/onboarding/symptoms_type_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:doantotnghiep/graph/user_model.dart';

class UpdateHealthScreen extends StatefulWidget {
  final UserModel currentUser;
  final dynamic dateOfBirth;

  const UpdateHealthScreen(
      {Key? key, required this.currentUser, this.dateOfBirth})
      : super(key: key);

  @override
  State<UpdateHealthScreen> createState() => _UpdateHealthScreenState();
}

class _UpdateHealthScreenState extends State<UpdateHealthScreen> {
  late TextEditingController _weightController;
  late TextEditingController _allergyController;

  List<String> selectedConditions = [];
  List<String> selectedSymptoms = [];
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();

    _weightController = TextEditingController(
      text: widget.currentUser.weight != null
          ? widget.currentUser.weight!.toInt().toString()
          : "",
    );

    _allergyController = TextEditingController(
      text: (widget.currentUser.allergies == null ||
              widget.currentUser.allergies!.isEmpty)
          ? "Không có"
          : widget.currentUser.allergies,
    );

    // Tách chuỗi Bệnh nền từ UserModel thành mảng để xử lý append
    if (widget.currentUser.medicalHistory != null &&
        widget.currentUser.medicalHistory != 'Không có' &&
        widget.currentUser.medicalHistory!.trim().isNotEmpty) {
      selectedConditions = widget.currentUser.medicalHistory!
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }

    // Tách chuỗi Triệu chứng từ UserModel thành mảng để xử lý append
    if (widget.currentUser.symptoms != null &&
        widget.currentUser.symptoms != 'Không có' &&
        widget.currentUser.symptoms!.trim().isNotEmpty) {
      selectedSymptoms = widget.currentUser.symptoms!
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }
  }

  @override
  void dispose() {
    _weightController.dispose();
    _allergyController.dispose();
    super.dispose();
  }

  // 🔥 HÀM ĐÃ FIX: Kết nối API lên FastAPI (Chạy mượt cho cả máy ảo Android bằng 10.0.2.2)
  // =========================================================================
  // 🔥 HÀM ĐÃ ĐỒNG BỘ: Kết nối API cập nhật dạng chuỗi chữ chuẩn DB
  // =========================================================================
  Future<void> _updateDataToServer() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);

    // 🚀 ĐƯỜNG DẪN API CẬP NHẬT (Giữ nguyên host của bác)
    final url = Uri.parse(AppConstant.address + 'api/user-health/update');

    final bodyData = {
      "user_id": widget.currentUser.id,
      "weight": double.tryParse(_weightController.text) ?? 60.0,
      // Gửi mảng chữ chuẩn xuống cho Backend giống luồng Onboarding
      "pre_existing_conditions": selectedConditions,
      "symptoms": selectedSymptoms,
      "allergies": _allergyController.text.trim().isEmpty
          ? "Không có"
          : _allergyController.text.trim(),
    };

    try {
      print("🚀 [PAYLOAD CẬP NHẬT HEALTH]: ${jsonEncode(bodyData)}");

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json; charset=UTF-8"},
        body: jsonEncode(bodyData),
      );

      if (response.statusCode == 200) {
        final resJson = jsonDecode(utf8.decode(response.bodyBytes));

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Cập nhật thông tin sức khỏe thành công!")),
        );

        // Trả kết quả map mới nhất về màn hình hiển thị để cập nhật UI lập tức
        Navigator.pop(context, resJson['results'] ?? resJson['data']);
      } else {
        final errorData = jsonDecode(utf8.decode(response.bodyBytes));
        throw Exception(errorData['detail'] ?? "Lỗi từ Server");
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                "Cập nhật thất bại: ${e.toString().replaceAll('Exception: ', '')}")),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F3),
      body: Center(
        child: Container(
          width: 400,
          height: 400,
          color: Colors.cyan,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // --- Title ---
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios,
                        color: Colors.white, size: 18),
                    onPressed: () => Navigator.maybePop(context),
                  ),
                  const Expanded(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.only(right: 40.0),
                        child: Text(
                          "Cập nhật BMI (Bio-mass Index)",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // --- 1. Ô Nhập Cân Nặng ---
              _buildWhiteBoxContainer(
                child: Row(
                  children: [
                    const Text("Cân nặng: ",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15)),
                    Expanded(
                      child: TextField(
                        controller: _weightController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          hintText: "Nhập số cân",
                          border: InputBorder.none,
                          suffixText: "kg",
                        ),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),

              // --- 2. Ô Chọn Bệnh Nền ---
              // --- 2. Ô Chọn Bệnh Nền ---
              _buildWhiteBoxContainer(
                child: InkWell(
                  onTap: () async {
                    final dummyPayload = OnboardingPayload(userId: widget.currentUser.id, dateOfBirth: "2000-01-01");
                    dummyPayload.conditionIds.clear();

                    final List<String>? resultsFromScreen = await Navigator.push<List<String>>(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ConditionsScreen(
                          payload: dummyPayload,
                          user: widget.currentUser,
                          isFromUpdate: true, 
                        ),
                      ),
                    );

                    // 🌟 Thay vì add cộng dồn, ta gán mới thẳng để đồng bộ chữ chuẩn xác
                    if (resultsFromScreen != null) {
                      setState(() {
                        selectedConditions = List<String>.from(resultsFromScreen);
                      });
                    }
                  },
                  child: Row(
                    children: [
                      const Text("Bệnh nền: ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      Expanded(
                        child: Text(
                          selectedConditions.isEmpty ? "Không có" : selectedConditions.join(", "),
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
                    ],
                  ),
                ),
              ),

              // --- 3. Ô Chọn Triệu Chứng ---
              _buildWhiteBoxContainer(
                child: InkWell(
                  onTap: () async {
                    final dummySymptomsPayload = OnboardingPayload(userId: widget.currentUser.id, dateOfBirth: "2000-01-01");
                    dummySymptomsPayload.symptomIds.clear();

                    final List<String>? resultsFromScreen = await Navigator.push<List<String>>(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SymptomsTypeScreen(
                          user: widget.currentUser,
                          payload: dummySymptomsPayload, 
                          isFromUpdate: true, 
                        ),
                      ),
                    );

                    // 🌟 Gán mới thẳng để đồng bộ triệu chứng chữ chuẩn xác
                    if (resultsFromScreen != null) {
                      setState(() {
                        selectedSymptoms = List<String>.from(resultsFromScreen);
                      });
                    }
                  },
                  child: Row(
                    children: [
                      const Text("Triệu chứng: ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      Expanded(
                        child: Text(
                          selectedSymptoms.isEmpty ? "Không có" : selectedSymptoms.join(", "),
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
                    ],
                  ),
                ),
              ),
              // --- 4. Ô Nhập Dị Ứng ---
              _buildWhiteBoxContainer(
                child: Row(
                  children: [
                    const Text("Dị ứng: ",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15)),
                    Expanded(
                      child: TextField(
                        controller: _allergyController,
                        decoration: const InputDecoration(
                            hintText: "Nhập tình trạng dị ứng",
                            border: InputBorder.none),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),

              // --- Nút Cập Nhật ---
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2ECC71),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0)),
                ),
                onPressed: _isSubmitting ? null : _updateDataToServer,
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : const Text(
                        "Cập nhật",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWhiteBoxContainer({required Widget child}) {
    return Container(
      width: double.infinity,
      height: 55,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(10.0)),
      child: Center(child: child),
    );
  }
}
