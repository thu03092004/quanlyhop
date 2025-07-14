//  dio interceptor được sử dụng nhiều lần nên tách ra
//  có một vài file service chưa sửa cho đồng nhất do sợ bug =))
// ignore_for_file: file_names

import 'package:dio/dio.dart';
import 'package:quanlyhop/core/constants/app_constants.dart';
import 'package:quanlyhop/data/services/auth_manager.dart';

class DioClient {
  // hàm private không cho phép tạo instance từ bên ngoài - lưu trữ instance duy nhất của class
  static final DioClient _instance = DioClient._internal();

  // Tạo một factory constructor để trả về instance duy nhất của lớp
  factory DioClient() => _instance;

  final Dio dio;

  DioClient._internal()
    : dio = Dio(
        BaseOptions(
          baseUrl: AppConstants.baseUrl,
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        ),
      ) {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = AuthManager.instance.token;
          if (token != null && !AuthManager.instance.isTokenExpired()) {
            options.headers['Authorization'] = 'Bearer $token';
          } else if (token != null && AuthManager.instance.isTokenExpired()) {
            await AuthManager.instance.clearAuthData();
            throw DioException(
              requestOptions: options,
              type: DioExceptionType.unknown,
              error: 'Token expired',
            );
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
    // in ra thông tin khi gửi request
    // dio.interceptors.add(
    //   LogInterceptor(
    //     request: true,
    //     requestBody: true,
    //     responseHeader: false,
    //     responseBody: true,
    //     error: true,
    //     logPrint: (object) => debugPrint(object.toString()),
    //   ),
    // );
  }
}
