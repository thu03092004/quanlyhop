import 'package:dio/dio.dart';
import 'package:quanlyhop/core/constants/app_constants.dart';
import 'package:quanlyhop/data/models/calendar_model.dart';
import 'package:quanlyhop/data/services/auth_manager.dart';

class CalendarService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );

  CalendarService() {
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

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Future<List<Meeting>> getMeetings({
    required String type,
    required DateTime dateFrom,
    required DateTime dateTo,
  }) async {
    try {
      String endpoint;
      switch (type) {
        case 'ministry':
          endpoint =
              '/meeting/MeetingSchedule/GetByUserIdFilterMonre?page=1&alias=bonnvmt&pageSize=999999&create=1010&search=&dateFrom=${_formatDate(dateFrom)}&dateTo=${_formatDate(dateTo)}&status=23&start=false&isdeleted=false&iscancel=false';
          break;
        case 'unit':
          endpoint =
              '/meeting/MeetingSchedule/GetByUserIdFilterMonre?page=1&alias=tthts&pageSize=999999&create=1010&search=&dateFrom=${_formatDate(dateFrom)}&dateTo=${_formatDate(dateTo)}&status=23&start=false&isdeleted=false&iscancel=false';
          break;
        case 'personal':
          endpoint =
              '/meeting/MeetingSchedule/GetByUserIdFilter?page=1&pageSize=999999&create=1010&search=&dateFrom=${_formatDate(dateFrom)}&dateTo=${_formatDate(dateTo)}&status=23&start=false&isdeleted=false&iscancel=false';
          break;
        default:
          throw Exception('Invalid meeting type');
      }

      final response = await _dio.get(endpoint);

      if (response.statusCode == 200) {
        final calendarResponse = CalendarResponse.fromJson(response.data);
        return calendarResponse.data;
      } else {
        throw DioException(
          requestOptions: RequestOptions(path: endpoint),
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to fetch meeting: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is DioException) {
        rethrow;
      }
      throw Exception('Error fetching meeting: $e');
    }
  }
}
