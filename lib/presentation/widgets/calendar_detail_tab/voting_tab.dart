import 'package:flutter/material.dart';
import 'package:quanlyhop/data/models/calendar_detail_model.dart';

class VotingTab extends StatelessWidget {
  final MeetingData meetingData;

  const VotingTab({super.key, required this.meetingData});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        Text('Nội dung: Thông qua kế hoạch tháng 7'),
        Text('Kết quả: 10/12 tán thành (83%)'),
      ],
    );
  }
}
