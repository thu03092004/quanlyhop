import 'package:flutter/material.dart';
import 'package:quanlyhop/data/models/calendar_detail_model.dart';

class ParticipantsTab extends StatelessWidget {
  final MeetingData meetingData;

  const ParticipantsTab({super.key, required this.meetingData});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        Text('1. Nguyễn Văn A (Chủ trì)'),
        Text('2. Trần Thị B (Thư ký)'),
        Text('3. Lê Văn C (Thành viên)'),
      ],
    );
  }
}
