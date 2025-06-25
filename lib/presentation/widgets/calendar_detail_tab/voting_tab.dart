import 'package:flutter/material.dart';

class VotingTab extends StatelessWidget {
  const VotingTab({super.key});

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
