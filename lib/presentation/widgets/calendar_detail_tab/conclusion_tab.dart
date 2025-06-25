import 'package:flutter/material.dart';

class ConclusionTab extends StatelessWidget {
  const ConclusionTab({super.key});

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
