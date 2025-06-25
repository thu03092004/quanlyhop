import 'package:flutter/material.dart';
import 'package:quanlyhop/presentation/widgets/calendar_detail_tab/agenda_and_docs_tab.dart';
import 'package:quanlyhop/presentation/widgets/calendar_detail_tab/calendar_info_tab.dart';
import 'package:quanlyhop/presentation/widgets/calendar_detail_tab/conclusion_tab.dart';
import 'package:quanlyhop/presentation/widgets/calendar_detail_tab/participants_tab.dart';
import 'package:quanlyhop/presentation/widgets/calendar_detail_tab/voting_tab.dart';

class CalendarDetailScreen extends StatelessWidget {
  final String meetingId;
  const CalendarDetailScreen({super.key, required this.meetingId});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Chi tiết lịch họp'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Thông tin lịch'),
              Tab(text: 'Chương trình - Tài liệu họp'),
              Tab(text: 'Thành phần tham gia'),
              Tab(text: 'Biểu quyết'),
              Tab(text: 'Kết luận'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            CalendarInfoTab(),
            AgendaAndDocsTab(),
            ParticipantsTab(),
            VotingTab(),
            ConclusionTab(),
          ],
        ),
      ),
    );
  }
}
