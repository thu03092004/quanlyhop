//Kiểm tra xem có quyền Thêm lịch họp mới hay không
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:quanlyhop/core/constants/app_constants.dart';
import 'package:quanlyhop/data/models/permission_model.dart';
import 'package:quanlyhop/data/services/auth_manager.dart';

class PermissionService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  PermissionService() {
    // thêm interceptor để tự động attach token vào headers
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = AuthManager.instance.token;
          if (token != null) {
            if (!AuthManager.instance.isTokenExpired()) {
              options.headers['Authorization'] = 'Bearer $token';
            } else {
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
          if (error.response?.statusCode == 401 ||
              error.response?.statusCode == 403) {
            await AuthManager.instance.clearAuthData();
          }
          handler.next(error);
        },
      ),
    );
  }

  // hàm Future làm việc với các thao tác bất đồng bộ
  Future<List<PermissionModel>> getUserPermissions() async {
    try {
      final response = await _dio.get(
        AppConstants.permissionEndpoint,
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data as List<dynamic>;
        return data.map((json) => PermissionModel.fromJson(json)).toList();
      } else {
        throw Exception('Lỗi khi lấy quyền người dùng: ${response.statusCode}');
      }
    } on DioException catch (dioError) {
      String errorMessage = 'Lỗi khi lấy quyền người dùng';

      if (dioError.response != null) {
        final statusCode = dioError.response!.statusCode;
        switch (statusCode) {
          case 401:
            errorMessage = 'Phiên đăng nhập hết hạn';
            break;
          case 403:
            errorMessage = 'Không có quyền truy cập';
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
      debugPrint('Permission service error: $e');
      throw Exception('Lỗi không xác định khi lấy quyền người dùng');
    }
  }

  // Kiểm tra người dùng có quyền Thêm lịch mới hay không
  Future<bool> hasSchedulePermission() async {
    try {
      final permissions = await getUserPermissions();
      return permissions.any((permissions) => permissions.isSchedulePermission);
    } catch (e) {
      debugPrint('Error checking schedule permission: $e');
      return false; // Mặc định không có quyền nếu có lỗi
    }
  }

  // Lấy các quyền schedule để xử lý tiếp theo
  Future<List<PermissionModel>> getSchedulePermissions() async {
    try {
      final permission = await getUserPermissions();
      // lấy những quyền có liên quan đến Schedule
      return permission
          .where((permission) => permission.isSchedulePermission)
          .toList();
    } catch (e) {
      debugPrint('Error getting schedule permissions: $e');
      return [];
    }
  }
}
