import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:quanlyhop/data/models/calendar_detail_model.dart';
import 'package:quanlyhop/data/services/auth_manager.dart';
import 'package:quanlyhop/data/services/dioClient.dart';

class MeetingManagementService {
  final Dio _dio = DioClient().dio;

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  // Quản lý lịch - Đang cập nhật
  Future<List<MeetingData>> getPendingMeetings({
    required DateTime dateFrom,
    required DateTime dateTo,
  }) async {
    try {
      final userID = AuthManager.instance.currentUser?.data.id.toString();

      String endpoint =
          '/meeting/MeetingSchedule/GetByUserIdFilter?page=1&pageSize=999999999&create=$userID&search=&dateFrom=${_formatDate(dateFrom)}&dateTo=${_formatDate(dateTo)}&status=10&start=false&isdeleted=false&iscancel=false';

      final response = await _dio.get(endpoint);

      if (response.statusCode == 200) {
        final data = response.data['data'] as List<dynamic>;
        return data.map((json) => MeetingData.fromJson(json)).toList();
      } else {
        throw DioException(
          requestOptions: RequestOptions(path: endpoint),
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Không thể lấy Lịch đang cập nhật: ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('Error in getPendingMeeting: $e');
      if (e is DioException) {
        rethrow;
      }
      throw Exception('Lỗi khi lấy Lịch đang cập nhật - Quản lý lịch: $e');
    }
  }

  // Quản lý lịch - Đã duyệt
  Future<List<MeetingData>> getApprovedMeetings({
    required DateTime dateFrom,
    required DateTime dateTo,
  }) async {
    try {
      final userID = AuthManager.instance.currentUser?.data.id.toString();

      String endpoint =
          '/meeting/MeetingSchedule/GetByUserIdFilter?page=1&pageSize=999999999&create=$userID&search=&dateFrom=${_formatDate(dateFrom)}&dateTo=${_formatDate(dateTo)}&status=23&start=false&isdeleted=false&iscancel=false';

      final response = await _dio.get(endpoint);

      if (response.statusCode == 200) {
        final data = response.data['data'] as List<dynamic>;
        return data.map((json) => MeetingData.fromJson(json)).toList();
      } else {
        throw DioException(
          requestOptions: RequestOptions(path: endpoint),
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Không thể lấy Lịch đã duyệt: ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('Error in getApprovedMeetings: $e');
      if (e is DioException) {
        rethrow;
      }
      throw Exception('Lỗi khi lấy Lịch đã duyệt - Quản lý lịch: $e');
    }
  }

  // Quản lý lịch - Đã xóa
  Future<List<MeetingData>> getDeletedMeetings({
    required DateTime dateFrom,
    required DateTime dateTo,
  }) async {
    try {
      final userID = AuthManager.instance.currentUser?.data.id.toString();

      String endpoint =
          '/meeting/MeetingSchedule/GetByUserIdFilter?page=1&pageSize=999999999&create=$userID&search=&dateFrom=${_formatDate(dateFrom)}&dateTo=${_formatDate(dateTo)}&status=23&start=false&isdeleted=true&iscancel=false';

      final response = await _dio.get(endpoint);

      if (response.statusCode == 200) {
        final data = response.data['data'] as List<dynamic>;
        return data.map((json) => MeetingData.fromJson(json)).toList();
      } else {
        throw DioException(
          requestOptions: RequestOptions(path: endpoint),
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Không thể lấy Lịch đã xóa: ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('Error in getDeletedMeetings: $e');
      if (e is DioException) {
        rethrow;
      }
      throw Exception('Lỗi khi lấy Lịch đã xóa - Quản lý lịch: $e');
    }
  }
}
