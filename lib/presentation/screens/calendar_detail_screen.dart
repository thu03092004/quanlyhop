import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:quanlyhop/data/models/calendar_detail_model.dart';
import 'package:quanlyhop/data/services/calendar_service.dart';
import 'package:quanlyhop/presentation/widgets/calendar_detail_tab/agenda_tab.dart';
import 'package:quanlyhop/presentation/widgets/calendar_detail_tab/calendar_info_tab.dart';
import 'package:quanlyhop/presentation/widgets/calendar_detail_tab/conclusion_tab.dart';
import 'package:quanlyhop/presentation/widgets/calendar_detail_tab/docs_tab.dart';
import 'package:quanlyhop/presentation/widgets/calendar_detail_tab/participants_tab.dart';
import 'package:quanlyhop/presentation/widgets/calendar_detail_tab/voting_tab.dart';

class CalendarDetailScreen extends StatelessWidget {
  final String meetingId;
  const CalendarDetailScreen({super.key, required this.meetingId});

  @override
  Widget build(BuildContext context) {
    final calendarService = CalendarService();

    return FutureBuilder<CalendarDetailModel>(
      future: calendarService.getCalendarDetail(meetingId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          // hết hạn đăng nhập thì trở về màn hình đăng nhập
          String errorMessage = 'Lỗi ở detail screen: ${snapshot.error}';
          if (snapshot.error is DioException &&
              (snapshot.error as DioException).error.toString().contains(
                'Token expired',
              )) {
            errorMessage = 'Phiên đăng nhập hết hạn. Vui lòng đăng nhập lại.';
            // điều hướng về màn hình đăng nhập
            Navigator.pushReplacementNamed(context, '/login');
          }

          return Scaffold(
            appBar: AppBar(title: const Text('Chi tiết lịch họp')),
            body: Center(child: Text(errorMessage)),
          );
        } else if (snapshot.hasData) {
          final meetingData = snapshot.data!.data;

          // Kiểm tra các trường bắt buộc
          if (meetingData.id.isEmpty || meetingData.title.isEmpty) {
            return Scaffold(
              appBar: AppBar(title: const Text('Chi tiết lịch họp')),
              body: const Center(child: Text('Dữ liệu lịch họp không hợp lệ')),
            );
          }

          return DefaultTabController(
            length: 6,
            child: Scaffold(
              appBar: AppBar(
                title: const Text('Chi tiết lịch họp'),
                bottom: const TabBar(
                  isScrollable: true,
                  labelColor: Colors.green, // Màu tab đang chọn
                  unselectedLabelColor: Colors.black54, // Màu tab chưa chọn
                  indicatorColor: Colors.green, // Gạch dưới màu xanh lá
                  tabs: [
                    Tab(text: 'Thông tin'),
                    Tab(text: 'Chương trình'),
                    Tab(text: 'Tài liệu họp'),
                    Tab(text: 'Thành phần tham gia'),
                    Tab(text: 'Biểu quyết'),
                    Tab(text: 'Kết luận'),
                  ],
                ),
              ),
              body: TabBarView(
                children: [
                  CalendarInfoTab(meetingData: meetingData),
                  AgendaTab(meetingData: meetingData),
                  DocsTab(meetingData: meetingData),
                  ParticipantsTab(meetingData: meetingData),
                  VotingTab(meetingData: meetingData),
                  ConclusionTab(meetingData: meetingData),
                ],
              ),
            ),
          );
        } else {
          return const Scaffold(body: Center(child: Text('Không có dữ liệu')));
        }
      },
    );
  }
}
