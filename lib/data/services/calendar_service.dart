import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:quanlyhop/core/constants/app_constants.dart';
import 'package:quanlyhop/data/models/calendar_detail_model.dart';
import 'package:quanlyhop/data/models/calendar_model.dart';
import 'package:quanlyhop/data/models/user_info_model.dart';
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

          // debugPrint('➡️ [Dio] Request: ${options.method} ${options.uri}');
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

  // lấy thong_tin_nguoi_dung
  Future<UserInfo> _getUserInfo() async {
    try {
      final response = await _dio.get(AppConstants.thongTinNguoiDung);
      if (response.statusCode == 200) {
        return UserInfo.fromJson(response.data);
      } else {
        throw Exception(
          'Lỗi khi lấy thông tin người dùng: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Lỗi khi gọi API: $e');
    }
  }

  Future<List<Meeting>> getMeetings({
    required String type,
    required DateTime dateFrom,
    required DateTime dateTo,
  }) async {
    try {
      final userID = AuthManager.instance.currentUser?.data.id.toString();
      // debugPrint(userID);

      final userInfo = await _getUserInfo();
      final String aliasUnit = userInfo.thongTinDonVi?.bidanh ?? 'bonnvmt';
      // debugPrint('Alias: $aliasUnit');

      String endpoint;
      switch (type) {
        case 'ministry':
          endpoint =
              '/meeting/MeetingSchedule/GetByUserIdFilterMonre?page=1&alias=bonnvmt&pageSize=999999&create=$userID&search=&dateFrom=${_formatDate(dateFrom)}&dateTo=${_formatDate(dateTo)}&status=23&start=false&isdeleted=false&iscancel=false';
          break;
        case 'unit':
          endpoint =
              '/meeting/MeetingSchedule/GetByUserIdFilterMonre?page=1&alias=$aliasUnit&pageSize=999999&create=$userID&search=&dateFrom=${_formatDate(dateFrom)}&dateTo=${_formatDate(dateTo)}&status=23&start=false&isdeleted=false&iscancel=false';
          break;
        case 'personal':
          endpoint =
              '/meeting/MeetingSchedule/GetByUserIdFilter?page=1&pageSize=999999&create=$userID&search=&dateFrom=${_formatDate(dateFrom)}&dateTo=${_formatDate(dateTo)}&status=23&start=false&isdeleted=false&iscancel=false';
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

  // lấy chi tiết lịch họp theo meeting id bao gồm:
  // Thông tin
  // Chương trình
  // Thành phần tham gia
  // Biểu quyết
  // Kết luận
  Future<CalendarDetailModel> getCalendarDetail(String meetingId) async {
    try {
      final endpoint = '${AppConstants.calendarDetail}?id=$meetingId';
      final response = await _dio.get(endpoint);

      if (response.statusCode == 200) {
        // debugPrint('JSON response: ${response.data}');

        return CalendarDetailModel.fromJson(response.data);
      } else {
        throw DioException(
          requestOptions: RequestOptions(path: endpoint),
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Không thể lấy thông tin lịch họp: ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('Error in getCalendarInfo: $e');
      if (e is DioException) {
        rethrow;
      }
      throw Exception('Lỗi khi lấy thông tin lịch họp: $e');
    }
  }

  // lấy tài liệu họp
  Future<List<MeetingDocument>> getDocs(String meetingId) async {
    try {
      final endpoint = '${AppConstants.docsTab}?id=$meetingId';
      final response = await _dio.get(endpoint);

      if (response.statusCode == 200) {
        final data = response.data['data'] as List<dynamic>;
        return data.map((json) => MeetingDocument.fromJson(json)).toList();
      } else {
        throw DioException(
          requestOptions: RequestOptions(path: endpoint),
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Không thể lấy tài liệu họp: ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('Error in getDocs: $e');
      if (e is DioException) {
        rethrow;
      }
      throw Exception('Lỗi khi lấy tài liệu họp: $e');
    }
  }

  // tải dữ liệu PDF dưới dạng file để tiến hành xem file trực tiếp
  Future<Uint8List?> openPdfBytes({
    required MeetingDocument meetingDocument,
  }) async {
    // if (type != 'application/pdf') {
    //   debugPrint('Không phải file PDF');
    //   return null;
    // }

    try {
      final objectKey =
          'tailieu/${meetingDocument.scheduleId}/${meetingDocument.originalName}';
      final fileName = meetingDocument.originalName ?? '';

      final endpoint =
          '${AppConstants.viewDoc}?objectKey=$objectKey&fileName=$fileName';

      debugPrint('Endpoint đọc file: $endpoint');

      final response = await _dio.get(
        endpoint,
        options: Options(responseType: ResponseType.bytes),
      );
      // debugPrint('Response là: $response');

      if (response.statusCode == 200) {
        // debugPrint('Dữ liệu hàm gửi đi: ${response.data}');
        return response.data as Uint8List; // trả về dữ liệu dạng bytes
      } else {
        throw DioException(
          requestOptions: RequestOptions(path: endpoint),
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Không thể tải file PDF: ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('Error in downloadPdfBytes: $e');
      if (e is DioException) {
        rethrow;
      }
      throw Exception('Lỗi khi tải file PDF: $e');
    }
  }
}
