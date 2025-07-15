import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:quanlyhop/core/constants/app_constants.dart';
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

  // duyệt lịch họp: status 0 -> 2
  Future<void> approveMeetingSchedule(String meetingId) async {
    try {
      final endpoint = '${AppConstants.meetingScheduleStatus}?id=$meetingId';
      final response = await _dio.post(
        endpoint,
        data: {"status": 2},
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (response.statusCode == 200) {
        // Parse response body
        final responseBody = response.data as Map<String, dynamic>;

        // Kiểm tra trường "status" trong body
        if (responseBody['status'] == 200) {
          debugPrint('Duyệt lịch họp: ${responseBody['message']}');
          return;
        } else {
          throw Exception(
            'Unexpected status in response body: ${responseBody['status']}',
          );
        }
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to update meeting status: ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('Error in approveMeetingSchedule: $e');
      if (e is DioException) {
        rethrow;
      }
      throw Exception('Lỗi khi duyệt lịch họp: $e');
    }
  }

  // hủy duyệt lịch họp: status 2 -> 0
  Future<void> unapproveMeetingSchedule(String meetingId) async {
    try {
      final endpoint = '${AppConstants.meetingScheduleStatus}?id=$meetingId';
      final response = await _dio.post(
        endpoint,
        data: {"status": 0},
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (response.statusCode == 200) {
        // Parse response body
        final responseBody = response.data as Map<String, dynamic>;

        // Kiểm tra trường "status" trong body
        if (responseBody['status'] == 200) {
          debugPrint('Hủy duyệt lịch họp: ${responseBody['message']}');
          return;
        } else {
          throw Exception(
            'Unexpected status in response body: ${responseBody['status']}',
          );
        }
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to update meeting status: ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('Error in unapproveMeetingSchedule: $e');
      if (e is DioException) {
        rethrow;
      }
      throw Exception('Lỗi khi hủy duyệt lịch họp: $e');
    }
  }

  // hàm thay đổi status
  Future<void> changeStatus(String meetingId, int newStatus) async {
    try {
      final endpoint = '${AppConstants.meetingScheduleStatus}?id=$meetingId';
      final response = await _dio.post(
        endpoint,
        data: {"status": newStatus},
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (response.statusCode == 200) {
        // parse response body
        final responseBody = response.data as Map<String, dynamic>;

        // kiểm tra trường status trong body
        if (responseBody['status'] == 200) {
          debugPrint('Status QLL: ${responseBody['message']}');
          return;
        } else {
          throw Exception(
            'Unexpected status in response body: ${responseBody['status']}',
          );
        }
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to change status: ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('Error in changeStatus: $e');
      if (e is DioException) {
        rethrow;
      }
      throw Exception('Lỗi khi thay đổi status lịch họp: $e');
    }
  }

  // bắt đầu lịch họp - Lịch đã duyệt: start false -> true và status 3 -> 2
  Future<void> startMeeting(String meetingId) async {
    try {
      final endpoint = '${AppConstants.meetingScheduleStart}?id=$meetingId';
      // debugPrint('Endpoint gọi startMeeting: $endpoint');

      final response = await _dio.post(
        endpoint,
        data: {"start": true},
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (response.statusCode == 200) {
        // Parse response body
        final responseBody = response.data as Map<String, dynamic>;

        // Kiểm tra trường "status" trong body
        if (responseBody['status'] == 200) {
          debugPrint('Bắt đầu lịch họp: ${responseBody['message']}');
          return;
        } else {
          throw Exception(
            'Unexpected status in response body: ${responseBody['status']}',
          );
        }
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to update meeting start: ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('Error in startMeeting: $e');
      if (e is DioException) {
        debugPrint(
          'DioException details: ${e.message}, Response: ${e.response?.data}, Status: ${e.response?.statusCode}',
        );
        rethrow;
      }
      throw Exception('Lỗi khi bắt đầu lịch họp - service: $e');
    }
  }

  // kết thúc lịch họp - Lịch đã duyệt: start true -> false và status 2 -> 3
  Future<void> endMeeting(String meetingId) async {
    try {
      final endpoint = '${AppConstants.meetingScheduleStart}?id=$meetingId';

      final response = await _dio.post(
        endpoint,
        data: {"start": false},
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (response.statusCode == 200) {
        // Parse response body
        final responseBody = response.data as Map<String, dynamic>;

        // Kiểm tra trường "status" trong body
        if (responseBody['status'] == 200) {
          debugPrint('Kết thúc lịch họp: ${responseBody['message']}');
          return;
        } else {
          throw Exception(
            'Unexpected status in response body: ${responseBody['status']}',
          );
        }
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to update meeting start: ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('Error in endMeeting: $e');
      if (e is DioException) {
        rethrow;
      }
      throw Exception('Lỗi khi kết thúc lịch họp: $e');
    }
  }
}
