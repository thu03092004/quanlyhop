import 'package:dio/dio.dart';
import 'package:quanlyhop/core/constants/app_constants.dart';
import 'package:quanlyhop/data/models/user_model.dart';

class AuthService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  Future<UserModel> login(String user, String password) async {
    try {
      final response = await _dio.post(
        AppConstants.loginEndpoint,
        data: {'usr': user, 'pw': password},
      );

      if (response.statusCode == 200) {
        return UserModel.fromJson(response.data);
      } else {
        // Có thể response.statusMessage là null nên thay bằng statusCode + data
        throw Exception(
          'Login failed: ${response.statusCode} ${response.data}',
        );
      }
    } on DioException catch (dioError) {
      if (dioError.response != null) {
        throw Exception(
          'Server error: ${dioError.response?.statusCode} ${dioError.response?.data}',
        );
      } else {
        throw Exception('Network error: ${dioError.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
}
