import 'package:doantotnghiep/constant.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class FoodListScreen extends StatefulWidget {
  const FoodListScreen({Key? key}) : super(key: key);

  @override
  _FoodListScreenState createState() => _FoodListScreenState();
}

class _FoodListScreenState extends State<FoodListScreen> {
  final Dio _dio = Dio();
  List<dynamic> _foods = [];
  bool _isLoading = true;

  // Danh sách lưu trữ các món ăn đang được chọn (Tối đa 4 món)
  final List<dynamic> _selectedFoods = [];
  int _totalCalories = 0;

  @override
  void initState() {
    super.initState();
    _fetchFoods();
  }

  // Gọi API lấy TOÀN BỘ danh sách món ăn (không truyền meal_type nữa)
  Future<void> _fetchFoods() async {
    setState(() {
      _isLoading = true;
    });
    try {
      // Gọi endpoint gốc, Backend sẽ nhảy vào khối else và trả ra hết các món
      final response = await _dio.get("${AppConstant.address}api/foods");

      if (response.statusCode == 200 && response.data != null) {
        setState(() {
          final responseData = response.data['data'];
          if (responseData != null && responseData['foods'] is List) {
            _foods = responseData['foods'];
          } else {
            _foods = [];
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Lỗi tải thực đơn: $e"), backgroundColor: Colors.red),
      );
    }
  }

  // Logic xử lý khi nhấn chọn hoặc bỏ chọn món ăn (Tối đa 4 món)
  void _toggleSelectFood(dynamic food) {
    final int foodId = food['id'];
    final int calories = (food['calories'] as num).toInt();

    final int existingIndex =
        _selectedFoods.indexWhere((element) => element['id'] == foodId);

    setState(() {
      if (existingIndex >= 0) {
        // Nếu món đã được chọn trước đó -> BỎ CHỌN và TRỪ CALO
        _selectedFoods.removeAt(existingIndex);
        _totalCalories -= calories;
      } else {
        // Nếu chưa chọn -> Kiểm tra xem đã đạt giới hạn 4 món chưa
        if (_selectedFoods.length >= 4) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Bạn chỉ được chọn tối đa 4 món ăn cho 1 bữa ăn!"),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 2),
            ),
          );
          return;
        }
        // Nếu dưới 4 món -> THÊM VÀO DANH SÁCH và CỘNG CALO
        _selectedFoods.add(food);
        _totalCalories += calories;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF00BCD4); // Màu nền xanh Cyan chủ đạo

    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 22),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          "Danh sách các khẩu phần ăn",
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Hiển thị số lượng món đã chọn ngay trên đầu cho thoáng
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 14.0),
            child: Text(
              "Đã chọn: ${_selectedFoods.length}/4 món cho 1 bữa ăn",
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
          ),

          // LƯỚI TOÀN BỘ MÓN ĂN TRONG DATABASE
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.white))
                : _foods.isEmpty
                    ? const Center(
                        child: Text(
                          "Không có dữ liệu món ăn",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500),
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3, // Hiển thị 3 cột chuẩn bài
                          crossAxisSpacing: 10, // Khoảng cách ngang
                          mainAxisSpacing: 12, // Khoảng cách dọc
                          childAspectRatio:
                              0.85, // Tỷ lệ co giãn khung ảnh ôm khít tên
                        ),
                        itemCount: _foods.length,
                        itemBuilder: (context, index) {
                          final food = _foods[index];
                          final bool isSelected = _selectedFoods
                              .any((element) => element['id'] == food['id']);

                          return GestureDetector(
                            onTap: () => _toggleSelectFood(food),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.red
                                      : Colors.transparent, // Viền đỏ khi chọn
                                  width: isSelected ? 2.5 : 0.0,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    spreadRadius: 1,
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Stack(
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      // Ảnh món ăn
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(5.0),
                                          child: ClipRRect(
                                            borderRadius:
                                                const BorderRadius.vertical(
                                                    top: Radius.circular(8)),
                                            child: Image.network(
                                              food['img_url'] ?? '',
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error,
                                                      stackTrace) =>
                                                  const Icon(Icons.restaurant,
                                                      color: primaryColor,
                                                      size: 32),
                                            ),
                                          ),
                                        ),
                                      ),
                                      // Tên món ăn
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            bottom: 8.0,
                                            left: 4.0,
                                            right: 4.0,
                                            top: 2.0),
                                        child: Text(
                                          food['meal_name'] ?? '',
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  // Dấu tích đỏ ở góc khi món được chọn
                                  if (isSelected)
                                    Positioned(
                                      top: 6,
                                      right: 6,
                                      child: Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: const BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.check,
                                            color: Colors.white, size: 14),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),

          // BANNER TỔNG CALO CỘNG DỒN DƯỚI ĐÁY
          Container(
            width: double.infinity,
            color: const Color(0xFF4CAF50),
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              "Tổng calo đã chọn: $_totalCalories (kcal)",
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
