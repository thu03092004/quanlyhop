import 'package:flutter/material.dart';
import 'package:quanlyhop/data/models/calendar_detail_model.dart';

class ConclusionTab extends StatelessWidget {
  final MeetingData meetingData;

  const ConclusionTab({super.key, required this.meetingData});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        Text('- Kết luận 1: Các phòng ban triển khai đúng hạn.'),
        Text('- Kết luận 2: Giao phòng KHTC kiểm tra ngân sách.'),
      ],
    );
  }
}
