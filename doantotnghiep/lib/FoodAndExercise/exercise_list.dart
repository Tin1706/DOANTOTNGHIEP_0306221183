import 'package:doantotnghiep/constant.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class ExerciseListScreen extends StatefulWidget {
  const ExerciseListScreen({Key? key}) : super(key: key);

  @override
  _ExerciseListScreenState createState() => _ExerciseListScreenState();
}

class _ExerciseListScreenState extends State<ExerciseListScreen> {
  final Dio _dio = Dio();
  List<dynamic> _exercises = [];
  bool _isLoading = true;

  // Lưu ID của bài tập đang được chọn
  int? _selectedExerciseId;
  int _burnedCalories =
      0; // Chuyển thành kiểu int khớp chuẩn với database cột calories_30_minutes

  @override
  void initState() {
    super.initState();
    _fetchExercises();
  }

  // Gọi API lấy danh sách bài tập từ FastAPI backend
  Future<void> _fetchExercises() async {
    setState(() {
      _isLoading = true;
      _exercises = []; // Xóa danh sách cũ để làm sạch giao diện
    });

    try {
      // ĐỔI THÀNH SỐ ÍT: /api/exercise (bỏ chữ 's') để dứt điểm lỗi 404
      final response = await _dio.get("${AppConstant.address}api/exercise");

      if (response.statusCode == 200 && response.data != null) {
        setState(() {
          // Bóc tách đúng key ['exercises'] bên trong ['data']
          final responseData = response.data['data'];
          if (responseData != null && responseData['exercises'] is List) {
            _exercises = responseData['exercises'] as List<dynamic>;
          } else {
            _exercises = [];
          }

          _isLoading = false;

          // Gán mặc định chọn bài tập đầu tiên và lấy calo đốt cháy
          if (_exercises.isNotEmpty) {
            _selectedExerciseId = _exercises[0]['id'];
            _burnedCalories =
                (_exercises[0]['calories_30_minutes'] as num).toInt();
          } else {
            _selectedExerciseId = null;
            _burnedCalories = 0;
          }
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Lỗi tải danh sách bài tập: $e"),
            backgroundColor: Colors.red),
      );
    }
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
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          "Danh sách các bài thể dục tập trong 30 phút",
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : Column(
              children: [
                // Lưới hiển thị danh sách bài tập (4 cột tương thích Figma)
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16.0),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount:
                          4, // Chia lưới làm 4 cột ngang giống hệt thiết kế
                      crossAxisSpacing: 10, // Khoảng cách ngang giữa các card
                      mainAxisSpacing: 12, // Khoảng cách dọc giữa các dòng
                      childAspectRatio:
                          0.85, // Tỷ lệ khung hình của ô card bài tập
                    ),
                    itemCount: _exercises.length,
                    itemBuilder: (context, index) {
                      final item = _exercises[index];
                      final bool isSelected = item['id'] == _selectedExerciseId;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedExerciseId = item['id'];
                            _burnedCalories =
                                (item['calories_30_minutes'] as num).toInt();
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected
                                  ? Colors.red
                                  : Colors.grey.shade300,
                              width: isSelected ? 2.5 : 1.0,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // 🟢 ĐÃ ĐỔI THÀNH IMAGE.NETWORK + THAY THÀNH NULL: Tải link ảnh mạng trực tiếp
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(6.0),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: Image.network(
                                      item['img_url'] ?? '',
                                      fit: BoxFit.cover,
                                      // Nhảy thẳng vào đây hiển thị icon tạ tay nếu link rỗng hoặc lỗi
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return const Icon(Icons.fitness_center,
                                            color: primaryColor, size: 30);
                                      },
                                      // Hiệu ứng vòng xoay tải ảnh mạng mượt mà
                                      loadingBuilder:
                                          (context, child, loadingProgress) {
                                        if (loadingProgress == null)
                                          return child;
                                        return Center(
                                          child: CircularProgressIndicator(
                                            value: loadingProgress
                                                        .expectedTotalBytes !=
                                                    null
                                                ? loadingProgress
                                                        .cumulativeBytesLoaded /
                                                    loadingProgress
                                                        .expectedTotalBytes!
                                                : null,
                                            color: primaryColor,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),
                              // Tên của bài tập thể thao
                              Padding(
                                padding: const EdgeInsets.only(
                                    bottom: 6.0, left: 2, right: 2),
                                child: Text(
                                  item['exercise_name'] ?? '',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Banner xanh lá hiển thị lượng Calo tiêu hao dưới đáy màn hình
                Container(
                  width: double.infinity,
                  color:
                      const Color(0xFF4CAF50), // Màu xanh lá cây đồng bộ layout
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Text(
                    "Số calo đã đốt cháy: $_burnedCalories (kcal)",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
