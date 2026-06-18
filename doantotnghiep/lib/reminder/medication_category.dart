import 'package:doantotnghiep/graph/user_model.dart';
import 'package:flutter/material.dart';
// 🟢 BƯỚC 1: IMPORT 2 MAN HÌNH MỚI CỦA BÁC VÀO ĐÂY (Thay đổi đường dẫn cho đúng cấu trúc thư mục)
import 'injection_medication_page.dart'; 
import 'oral_medication_page.dart';

class MedicationCategoryPage extends StatelessWidget {
  final UserModel user;
  const MedicationCategoryPage({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.cyan[400], // Đồng bộ màu nền lam sáng
      appBar: AppBar(
        backgroundColor: Colors.cyan[400],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Nhập thuốc đang sử dụng',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
        child: Column(
          children: [
            // Bấm Thuốc tiêm -> Truyền type là "TIEM"
            _buildCategoryButton(
              context: context,
              label: "Thuốc tiêm",
              typeKey: "TIEM",
            ),
            const SizedBox(height: 20),
            // Bấm Thuốc uống -> Truyền type là "UONG"
            _buildCategoryButton(
              context: context,
              label: "Thuốc uống",
              typeKey: "UONG",
            ),
          ],
        ),
      ),
    );
  }

  // 🟢 BƯỚC 2: CẬP NHẬT LOGIC ĐIỀU HƯỚNG DỰA TRÊN TYPEKEY
  Widget _buildCategoryButton(
      {required BuildContext context,
      required String label,
      required String typeKey}) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: () async {
          // 💡 Kiểm tra giá trị typeKey để rẽ nhánh điều hướng linh hoạt
          Widget targetPage;
          
          if (typeKey == "TIEM") {
            targetPage = InjectionMedicationPage(user: user);
          } else {
            targetPage = OralMedicationPage(user: user);
          }

          // Tiến hành chuyển màn hình và hứng lấy Object thuốc trả về (nếu có)
          final selectedMedication = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => targetPage,
            ),
          );

          // Nếu màn hình con (uống/tiêm) chọn thuốc xong và trả data ngược về,
          // chúng ta tiếp tục chuyển data đó về lại cho trang AddReminderPage gốc.
          if (selectedMedication != null && context.mounted) {
            Navigator.pop(context, selectedMedication);
          }
        },
        child: Text(label,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }
}