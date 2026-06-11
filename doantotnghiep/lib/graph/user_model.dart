class UserModel {
  final int id;
  final String name;
  final String email;
  final int? age;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.age,
  });

  // Hàm ép kiểu và chuyển đổi an toàn từ JSON của FastAPI sang Object Flutter
  factory UserModel.fromJson(Map<String, dynamic> json) {
    // 🟢 Tối ưu bóc tách trường tuổi: lấy ra giá trị nào không null trước (Age hoặc age)
    final rawAge = json['Age'] ?? json['age'];

    return UserModel(
      id: int.tryParse(json['id'].toString()) ?? 0,

      // Khớp chính xác với cột 'full_name' trong database
      name: json['full_name'] ?? json['name'] ?? '',

      email: json['email'] ?? '',

      // 🟢 Ép kiểu một lần duy nhất, nếu cả 2 đều null hoặc parse lỗi thì trả về null
      age: rawAge != null ? int.tryParse(rawAge.toString()) : null,
    );
  }
}
