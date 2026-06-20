import 'package:doantotnghiep/PDF/api_services.dart';
import 'package:doantotnghiep/graph/user_model.dart';
import 'package:flutter/material.dart';

class ReportScreen extends StatefulWidget {
  final UserModel user;

  const ReportScreen({super.key, required this.user});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  bool _isLoading = false;
  bool _hasCalculated = false; 
  String? _errorMessage;

  double _rate = 0.0;
  int _totalScheduled = 0;
  int _totalTaken = 0;
  int _totalMissed = 0;
  
  // 🟢 THÊM: Biến lưu trữ mảng chi tiết từng ngày từ Backend gửi về
  List<dynamic> _daysDetails = [];

  void _checkAdherenceRateOnly() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final now = DateTime.now();
    final thirtyDaysLater = now.add(const Duration(days: 30));

    String formatDate(DateTime date) {
      String year = date.year.toString();
      String month = date.month.toString().padLeft(2, '0');
      String day = date.day.toString().padLeft(2, '0');
      return "$year-$month-$day";
    }

    final String startDateStr = formatDate(now);             
    final String endDateStr = formatDate(thirtyDaysLater);   
    
    print("⏳ Đang quét tỉ lệ tuân thủ từ ngày $startDateStr đến ngày $endDateStr...");

    final response = await ApiService.calculateAdherence(
      userId: widget.user.id,
      startDate: startDateStr,
      endDate: endDateStr,
    );

    if (response != null && response['success'] == true) {
      var nestedData = response['data'];

      if (nestedData != null) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _hasCalculated = true; 
            _rate = (nestedData['adherence_rate'] ?? 0).toDouble();
            _totalScheduled = nestedData['total_scheduled'] ?? 0;
            _totalTaken = nestedData['total_taken'] ?? 0;
            
            // 🟢 THÊM: Hứng dữ liệu danh sách ngày chi tiết
            _daysDetails = nestedData['days_details'] ?? [];
            
            _totalMissed = _totalScheduled - _totalTaken;
            if (_totalMissed < 0) _totalMissed = 0;
          });
        }

        print("==================================================");
        print("🎯 THÔNG SỐ BÁO CÁO CỦA USER ${widget.user.id}: ${widget.user.name}");
        print("⏰ Khoảng thời gian: $startDateStr -> $endDateStr");
        print("📊 Tổng số lịch nhắc hẹn (Ngày): $_totalScheduled ngày");
        print("✅ Số ngày ĐÃ UỐNG ĐỦ: $_totalTaken ngày");
        print("❌ Số ngày CHƯA ĐẠT CHUẨN: $_totalMissed ngày");
        print("🎯 TỈ LỆ TUÂN THỦ THEO NGÀY: $_rate%");
        print("==================================================");

      } else {
        _showError("Không tìm thấy thuộc tính 'data' trong phản hồi!");
      }
    } else {
      String errMsg = response != null
          ? (response['message'] ?? response['detail'] ?? "Lỗi không xác định từ Backend.")
          : "Không nhận được dữ liệu từ Backend.";
      print("❌ Lỗi: $errMsg");
      _showError(errMsg);
    }
  }

  void _showError(String message) {
    if (mounted) {
      setState(() {
        _isLoading = false;
        _hasCalculated = false;
        _errorMessage = message;
        _daysDetails = []; // Xóa trắng dữ liệu cũ nếu lỗi
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Báo Cáo Tuân Thủ", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.cyan[400],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- THÔNG TIN USER ---
            Text(
              "Đang xem báo cáo của: ${widget.user.name}",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            Text("Mã bệnh nhân (User ID): #${widget.user.id}", style: const TextStyle(fontSize: 13, color: Colors.grey)),
            const SizedBox(height: 24),

            // --- NÚT BẤM KÍCH HOẠT VÀ TÍNH TOÁN ---
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.cyan[400],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 1,
                ),
                onPressed: _isLoading ? null : _checkAdherenceRateOnly,
                child: _isLoading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text("Tính toán & Xuất báo cáo 30 Ngày", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 24),

            // --- KHU VỰC HIỂN THỊ LỖI NẾU CÓ ---
            if (_errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                width: double.infinity,
                decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(8)),
                child: Text(_errorMessage!, style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w500)),
              ),
              const SizedBox(height: 24),
            ],

            // --- TRẠNG THÁI CHỜ HƯỚNG DẪN NGƯỜI DÙNG ---
            if (!_isLoading && !_hasCalculated && _errorMessage == null)
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 40),
                  child: Text(
                    "💡 Bấm nút phía trên để hệ thống quét dữ liệu y tế.",
                    style: TextStyle(color: Colors.grey[600], fontSize: 14, fontStyle: FontStyle.italic),
                  ),
                ),
              ),

            // --- KHU VỰC HIỂN THỊ KẾT QUẢ TRỰC QUAN ---
            if (!_isLoading && _hasCalculated && _errorMessage == null) ...[
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Tỷ lệ tuân thủ đạt", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.grey)),
                          Text("${_rate.toStringAsFixed(1)}%", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.cyan[700])),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: _rate / 100,
                          minHeight: 10,
                          backgroundColor: Colors.grey[200],
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.cyan[400]!),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 1,
                child: ListView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    ListTile(
                      leading: CircleAvatar(backgroundColor: Colors.blue[50], child: const Icon(Icons.calendar_today, color: Colors.blue, size: 20)),
                      title: const Text("Tổng thời gian quét"),
                      trailing: Text("$_totalScheduled ngày", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: CircleAvatar(backgroundColor: Colors.green[50], child: const Icon(Icons.check_circle, color: Colors.green, size: 20)),
                      title: const Text("Số ngày uống thuốc đầy đủ"),
                      trailing: Text("$_totalTaken ngày", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.green)),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: CircleAvatar(backgroundColor: Colors.red[50], child: const Icon(Icons.cancel, color: Colors.redAccent, size: 20)),
                      title: const Text("Số ngày quên / thiếu cử"),
                      trailing: Text("$_totalMissed ngày", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.redAccent)),
                    ),
                  ],
                ),
              ),
              
              // 🟢 THÊM: TIÊU ĐỀ CHO DANH SÁCH CHI TIẾT
              const SizedBox(height: 24),
              const Text(
                "🗓️ Nhật ký tiến độ chi tiết từng ngày",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 12),

              // 🟢 THÊM: DANH SÁCH CHI TIẾT TỪNG NGÀY THEO Ý BẠN
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(), // Tránh xung đột cuộn với SingleChildScrollView bên ngoài
                itemCount: _daysDetails.length,
                itemBuilder: (context, index) {
                  var day = _daysDetails[index];
                  bool isCompleted = day['is_completed'] ?? false;
                  int taken = day['taken_count'] ?? 0;
                  int required = day['required_count'] ?? 0;
                  String dateStr = day['date'] ?? '';

                  return Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    // Nền màu cam nhạt nếu chưa hoàn thành để làm nổi bật những ngày bị thiếu cử
                    color: isCompleted ? Colors.white : Colors.orange.withOpacity(0.06),
                    child: ListTile(
                      title: Text(
                        "Ngày: $dateStr", 
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)
                      ),
                      subtitle: Text(
                        "Tiến độ: $taken/$required cử",
                        style: TextStyle(color: isCompleted ? Colors.green[700] : Colors.orange[800]),
                      ),
                      
                      // 🎯 BIỂU TƯỢNG ĐỔI THEO ĐÚNG Ý ĐỒ CỦA BẠN:
                      trailing: isCompleted 
                        ? const Icon(Icons.check_circle, color: Colors.green, size: 28) // Tích xanh khi xong hoàn toàn
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "$taken/$required", 
                                style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)
                              ),
                              const SizedBox(width: 6),
                              const Icon(Icons.pending, color: Colors.orange), // Dấu chờ (màu cam) khi thiếu cử
                            ],
                          ),
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}