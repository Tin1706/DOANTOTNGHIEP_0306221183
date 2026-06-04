// auth_service.dart
import 'package:dio/dio.dart';
import 'package:doantotnghiep/health_metrics/health_metrics_payload.dart';

class AuthService {
  // Biến cấu hình Dio chuẩn cho toàn bộ class
  final Dio _dio = Dio(BaseOptions(
    baseUrl:
        'http://localhost:8000/api/auth', // Sử dụng localhost đồng bộ với Flutter Web
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  ));

  // 1. Đăng ký (UserRegister)
  Future<Response> register({
    required String fullName,
    required String email,
    required String dob,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      final response = await _dio.post('/register', data: {
        'full_name': fullName,
        'email': email,
        'dob': dob,
        'password': password,
        'confirm_password': confirmPassword,
      });
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // 2. Đăng nhập (UserLogin)
  Future<Response> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post('/login', data: {
        'email': email,
        'password': password,
      });
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // 3. Quên mật khẩu (ForgotPasswordRequest)
  Future<Response> forgotPassword(String email) async {
    try {
      final response = await _dio.post('/forgot-password', data: {
        'email': email,
      });
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // 4. Xác thực OTP (VerifyOTPRequest)
  Future<Response> verifyOtp({
    required String email,
    required String otpCode,
  }) async {
    try {
      final response = await _dio.post('/verify-otp', data: {
        'email': email,
        'otp_code': otpCode,
      });
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // 5. Đặt lại mật khẩu (ResetPasswordRequest)
  Future<Response> resetPassword({
    required String email,
    required String otpCode,
    required String newPassword,
    required String confirmNewPassword,
  }) async {
    try {
      final response = await _dio.post('/reset-password', data: {
        'email': email,
        'otp_code': otpCode,
        'new_password': newPassword,
        'confirm_new_password': confirmNewPassword,
      });
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // 6. Hàm lấy mã OTP tự động từ Database phục vụ việc Test/Debug
  Future<String> getOtpFromDatabase({required String email}) async {
    try {
      final response = await _dio.get(
        '/get-otp',
        queryParameters: {'email': email},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map && data['otp'] != null) {
          return data['otp'].toString();
        }
      }
      return "";
    } catch (e) {
      print("Lỗi lấy OTP tự động (Bỏ qua nếu chưa bấm Quên mật khẩu): $e");
      return "";
    }
  }

  // 🌟 ĐÃ ĐƯA VÀO TRONG CLASS VÀ KHẮC PHỤC SAI LỆCH URL
  // auth_service.dart
  Future<Response> submitHealthMetrics(HealthMetricsPayload payload) async {
    try {
      // 🌟 SỬA TẠI ĐÂY: Truyền thẳng URL tuyệt đối vào tham số đầu tiên,
      // đồng thời xóa bỏ cục 'options: Options(baseUrl: ...)' bị lỗi đi.
      final response = await _dio.post(
        'http://localhost:8000/api/health-metrics/submit',
        data: payload.toMap(),
      );

      return response;
    } on DioException catch (e) {
      if (e.response != null) {
        final detail = e.response?.data['detail'];
        throw Exception(
            detail is String ? detail : 'Lỗi xử lý dữ liệu từ server.');
      } else {
        throw Exception(
            'Không thể kết nối đến server. Vui lòng kiểm tra mạng!');
      }
    } catch (e) {
      throw Exception('Đã xảy ra lỗi không xác định: $e');
    }
  }

  // Hàm bóc tách xử lý thông báo lỗi từ FastAPI nhả về
  String _handleError(DioException error) {
    if (error.response != null) {
      final data = error.response?.data;
      if (data is Map && data.containsKey('detail')) {
        if (data['detail'] is String) return data['detail'];
        if (data['detail'] is List) {
          try {
            return data['detail'][0]['msg'] ?? 'Dữ liệu không hợp lệ';
          } catch (_) {}
        }
      }
      return 'Lỗi hệ thống (${error.response?.statusCode})';
    }
    return 'Không thể kết nối đến máy chủ. Vui lòng kiểm tra internet.';
  }
} // Dấu đóng ngoặc kết thúc Class nằm trọn vẹn ở cuối cùng
