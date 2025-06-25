import 'package:flutter/material.dart';

class CalendarInfoTab extends StatelessWidget {
  const CalendarInfoTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        Text('Tiêu đề: Họp giao ban tuần', style: TextStyle(fontSize: 16)),
        SizedBox(height: 8),
        Text('Thời gian: 08:00 - 10:00, 01/07/2025'),
        Text('Địa điểm: Phòng họp 301, Trụ sở chính'),
        Text('Chủ trì: Nguyễn Văn A'),
        Text('Mô tả: Cuộc họp định kỳ để cập nhật tình hình công việc.'),
      ],
    );
  }
}
