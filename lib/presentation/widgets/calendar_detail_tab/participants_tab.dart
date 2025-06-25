import 'package:flutter/material.dart';

class ParticipantsTab extends StatelessWidget {
  const ParticipantsTab({super.key});

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
