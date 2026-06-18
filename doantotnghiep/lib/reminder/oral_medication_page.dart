import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:doantotnghiep/graph/user_model.dart';
import 'package:doantotnghiep/reminder/reminder_models.dart'; // Chứa class Medication của bác

class OralMedicationPage extends StatefulWidget {
  final UserModel user;
  const OralMedicationPage({Key? key, required this.user}) : super(key: key);

  @override
  _OralMedicationPageState createState() => _OralMedicationPageState();
}

class _OralMedicationPageState extends State<OralMedicationPage> {
  final String apiUrl = "http://localhost:8000/api/diabetes-medications/all";
  List<Medication> _oralMedications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchOralMedications();
  }

  Future<void> _fetchOralMedications() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final resData = json.decode(response.body);
        if (resData['success'] == true) {
          final List<dynamic> dataList = resData['data'];

          setState(() {
            _oralMedications =
                dataList.map((json) => Medication.fromJson(json)).where((med) {
              if (med.medicationCategory == null) return false;

              // Chuyển hết về chữ thường và xóa khoảng trắng để so sánh chính xác
              final cat = med.medicationCategory!.toLowerCase().trim();

              // Kiểm tra xem có chứa từ khóa liên quan đến thuốc uống không
              return cat.contains("vien") || cat.contains("viên");
            }).toList();
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print("Lỗi tải danh sách thuốc uống: $e");
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
        title: const Text('Danh sách thuốc uống',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : _oralMedications.isEmpty
              ? const Center(
                  child: Text("Không có dữ liệu thuốc uống",
                      style: TextStyle(color: Colors.white)))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _oralMedications.length,
                  itemBuilder: (context, index) {
                    final medication = _oralMedications[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: const Icon(Icons.medical_services,
                            color: Colors.green),
                        title: Text(medication.medicationName,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: const Text("Thuốc uống viên / siro"),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          // 🔥 ĐÓNG MÀN HÌNH VÀ BẮN TRẢ OBJECT THUỐC VỀ
                          Navigator.pop(context, medication);
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
