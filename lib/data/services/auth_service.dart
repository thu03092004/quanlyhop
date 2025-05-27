import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:quanlyhop/core/constants/app_constants.dart';
import 'package:quanlyhop/data/models/user_model.dart';

import 'package:quanlyhop/data/services/auth_manager.dart';

class AuthService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  AuthService() {
    // Thêm interceptor để tự động attach token vào headers
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = AuthManager.instance.token;
          if (token != null) {
            // Kiểm tra token có hết hạn không trước khi sử dụng
            if (!AuthManager.instance.isTokenExpired()) {
              options.headers['Authorization'] = 'Bearer $token';
            } else {
              // Token hết hạn, xóa và redirect về login
              await AuthManager.instance.clearAuthData();
              throw DioException(
                requestOptions: options,
                type: DioExceptionType.unknown,
                error: 'Token expired',
              );
            }
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          // Nếu token hết hạn hoặc không hợp lệ (401, 403)
          if (error.response?.statusCode == 401 || 
              error.response?.statusCode == 403) {
            await AuthManager.instance.clearAuthData();
          }
          handler.next(error);
        },
      ),
    );

    // Thêm logging interceptor (chỉ trong development)
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (object) => debugPrint(object.toString()),
      ),
    );
  }

  Future<UserModel> login(String user, String password) async {
    try {
      final response = await _dio.post(
        AppConstants.loginEndpoint,
        data: {'usr': user, 'pw': password},
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final userModel = UserModel.fromJson(response.data);
        
        // Kiểm tra login có thành công không
        if (userModel.state && userModel.token.isNotEmpty) {
          // Lưu thông tin đăng nhập vào secure storage
          await AuthManager.instance.saveAuthData(userModel);
          return userModel;
        } else {
          throw Exception('Đăng nhập thất bại: Thông tin không hợp lệ');
        }
      } else {
        throw Exception(
          'Đăng nhập thất bại: ${response.statusCode} ${response.data}',
        );
      }
    } on DioException catch (dioError) {
      String errorMessage = 'Đăng nhập thất bại';
      
      if (dioError.response != null) {
        final statusCode = dioError.response!.statusCode;
        switch (statusCode) {
          case 401:
            errorMessage = 'Tài khoản hoặc mật khẩu không chính xác';
            break;
          case 403:
            errorMessage = 'Tài khoản bị khóa hoặc không có quyền truy cập';
            break;
          case 500:
            errorMessage = 'Lỗi server, vui lòng thử lại sau';
            break;
          default:
            errorMessage = 'Lỗi kết nối: ${dioError.response?.data}';
        }
      } else {
        switch (dioError.type) {
          case DioExceptionType.connectionTimeout:
          case DioExceptionType.receiveTimeout:
            errorMessage = 'Kết nối quá chậm, vui lòng thử lại';
            break;
          case DioExceptionType.unknown:
            errorMessage = 'Không có kết nối internet';
            break;
          default:
            errorMessage = 'Lỗi kết nối: ${dioError.message}';
        }
      }
      
      throw Exception(errorMessage);
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Lỗi không xác định: $e');
    }
  }

  Future<void> logout() async {
    try {
      // Có thể gọi API logout nếu server hỗ trợ
      // await _dio.post('/api/logout');
      
      await AuthManager.instance.clearAuthData();
    } catch (e) {
      // Vẫn clear local data dù API logout lỗi
      await AuthManager.instance.clearAuthData();
      debugPrint('Logout error: $e');
    }
  }

  // Kiểm tra token có còn hợp lệ không
  Future<bool> validateToken() async {
    try {
      if (!AuthManager.instance.isLoggedIn) return false;
      
      // Gọi API để kiểm tra token (nếu có endpoint)
      final response = await _dio.get('/api/validate-token');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}