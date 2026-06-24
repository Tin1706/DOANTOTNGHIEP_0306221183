// auth_service.dart
import 'package:dio/dio.dart';
import 'package:doantotnghiep/constant.dart';
import 'package:doantotnghiep/health_metrics/health_metrics_payload.dart';

class AuthService {
  // 🌟 ĐỒNG BỘ ĐƯỜNG DẪN: Đặt địa chỉ Server gốc ở đây để khi đổi IP chỉ cần sửa đúng 1 dòng này!

  // Biến cấu hình Dio chuẩn cho toàn bộ class
  final Dio _dio = Dio(BaseOptions(
    baseUrl: AppConstant.address + 'api/auth', 
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  ));

  // 1. Đăng ký (UserRegister) - TỰ ĐỘNG KÍCH HOẠT WHITELIST THEO EMAIL NGƯỜI DÙNG NHẬP
  Future<Response> register({
    required String fullName,
    required String email,
    required String dob,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      // 🚀 BƯỚC TỰ ĐỘNG: Âm thầm nạp email người dùng vừa nhập vào danh sách trắng trước
      try {
        print("⏳ Đang âm thầm tự nạp email $email vào Whitelist...");
        await whitelistEmail(email);
        print("✅ Tự động Whitelist email $email thành công!");
      } catch (whitelistError) {
        print("💡 Email đã được whitelist từ trước hoặc bỏ qua: $whitelistError");
      }

      // Sau khi đã whitelist xong, tiến hành gọi API đăng ký gốc chuẩn chỉnh
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

  // 3. Quên mật khẩu (ForgotPasswordRequest) - CHẠY THẬT (SERVER TỰ SINH OTP VÀO DB VÀ GỬI GMAIL)
  Future<Response> forgotPassword(String email) async {
    try {
      // Gọi lên Server để Server tự bắn mã OTP về Gmail thật.
      // Tuyệt đối không gọi thêm bất kỳ hàm lấy OTP tự động nào ở đây.
      final response = await _dio.post('/forgot-password', data: {
        'email': email,
      });
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // 4. Xác thực OTP khi Quên mật khẩu (VerifyOTPRequest) - SO KHỚP OTP TRONG DATABASE
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

  // 6. ADMIN NẠP EMAIL VÀO DANH SÁCH TRẮNG (WHITELIST-EMAIL)
  Future<Response> whitelistEmail(String email) async {
    try {
      final response = await _dio.post('/admin/whitelist-email', data: {
        'email': email,
      });
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // 🌟 ĐÃ XÓA BỎ HOÀN TOÀN: Hàm số 7 (getOtpFromDatabase) cũ đã bị loại bỏ 
  // để chặn đứng việc rò rỉ mã OTP tự động lên màn hình xác thực.

  // 7. HÀM XÁC THỰC OTP ĐĂNG KÝ - LUỒNG CHẠY THẬT (SO KHỚP OTP TRONG DATABASE)
  Future<Response> verifyRegisterOtp({
    required String email,
    required String fullName,
    required String dob,
    required String password,
    required String otpCode,
  }) async {
    try {
      final response = await _dio.post('/verify-register-otp', data: {
        'email': email,
        'full_name': fullName,
        'dob': dob,
        'password': password,
        'otp_code': otpCode,
      });
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // 8. Hàm đẩy dữ liệu chỉ số sức khỏe
  Future<Response> submitHealthMetrics(HealthMetricsPayload payload) async {
    try {
      final response = await _dio.post(
        AppConstant.address + '/api/health-metrics/submit',
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
} // Kết thúc Class