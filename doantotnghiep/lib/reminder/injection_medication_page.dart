import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:doantotnghiep/graph/user_model.dart';
import 'package:doantotnghiep/reminder/reminder_models.dart'; // Chứa class Medication của bác

class InjectionMedicationPage extends StatefulWidget {
  final UserModel user;
  const InjectionMedicationPage({Key? key, required this.user})
      : super(key: key);

  @override
  _InjectionMedicationPageState createState() =>
      _InjectionMedicationPageState();
}

class _InjectionMedicationPageState extends State<InjectionMedicationPage> {
  // Giữ nguyên localhost theo môi trường chạy của bác
  final String baseUrl = "http://192.168.0.236:8000/api/diabetes-medications/all";
  List<Medication> _injectionMedications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchInjectionMedications();
  }

  Future<void> _fetchInjectionMedications() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));
      if (response.statusCode == 200) {
        final resData = json.decode(response.body);
        if (resData['success'] == true) {
          final List<dynamic> dataList = resData['data'];

          setState(() {
            // Lọc danh sách thuốc tiêm một cách an toàn (Null Safety) giống hệt trang oral
            _injectionMedications =
                dataList.map((json) => Medication.fromJson(json)).where((med) {
              if (med.medicationCategory == null) return false;

              final categoryLower = med.medicationCategory!.toLowerCase();
              return categoryLower.contains("tiem") ||
                  categoryLower.contains("tiêm") || categoryLower.contains("Vaccine") 
                  || categoryLower.contains("vaccine");
            }).toList();
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print("Lỗi tải danh sách thuốc tiêm: $e");
      setState(() => _isLoading = false);
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
        title: const Text(
          'Danh sách thuốc tiêm',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : _injectionMedications.isEmpty
              ? const Center(
                  child: Text(
                    "Không có dữ liệu thuốc tiêm",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _injectionMedications.length,
                  itemBuilder: (context, index) {
                    final medication = _injectionMedications[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: const Icon(Icons.colorize,
                            color:
                                Colors.orange), // Icon cây kim tiêm đặc trưng
                        title: Text(
                          medication.medicationName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: const Text("Bút tiêm / Lọ dung dịch Insulin"),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          // 🔥 ĐỒNG BỘ CHUẨN LUỒNG: Bắn trả ngược dữ liệu thuốc về cho trang cha gán vào form
                          Navigator.pop(context, medication);
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
