import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:quanlyhop/core/constants/app_constants.dart';
import 'package:quanlyhop/data/models/meeting_model.dart';

class MeetingService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  Future<Map<String, dynamic>> createMeeting(MeetingModel meeting) async {
    try {
      // In ra dữ liệu sẽ gửi lên API
      final requestData = meeting.toJson();
      debugPrint('=== SENDING DATA TO API ===');
      debugPrint(
        'URL: ${AppConstants.baseUrl}${AppConstants.meetingInsertEndpoint}',
      );
      debugPrint('Method: POST');
      debugPrint('Headers: {');
      debugPrint('  Content-Type: application/json');
      debugPrint('  Authorization: Bearer ${meeting.token}');
      debugPrint('}');
      debugPrint('Body (JSON):');
      debugPrint(const JsonEncoder.withIndent('  ').convert(requestData));
      debugPrint('=== END REQUEST DATA ===\n');

      final response = await _dio.post(
        AppConstants.meetingInsertEndpoint,
        data: meeting.toJson(),
        options: Options(headers: {'Authorization': 'Bearer ${meeting.token}'}),
      );

      // In ra response để debug
      debugPrint('Response data: ${response.data}');
      debugPrint('Status code: ${response.statusCode}');

      return {
        'success': response.statusCode == 200,
        'statusCode': response.statusCode,
        'message':
            response.statusCode == 200
                ? 'Tạo phòng họp "${meeting.title}" thành công!'
                : 'Lỗi khi tạo phòng họp:\n${response.data['message']}',
      };
    } on DioException catch (e) {
      String errorMessage = 'Lỗi khi tạo phòng họp: ${e.message}';
      if (e.response != null) {
        errorMessage = 'Lỗi khi tạo phòng họp: ${e.response?.statusCode}';
      }
      return {
        'success': false,
        'statusCode': e.response?.statusCode ?? 0,
        'message': errorMessage,
      };
    } catch (e) {
      return {
        'success': false,
        'statusCode': 0,
        'message': 'Lỗi không xác định: ${e.toString()}',
      };
    }
  }
}
