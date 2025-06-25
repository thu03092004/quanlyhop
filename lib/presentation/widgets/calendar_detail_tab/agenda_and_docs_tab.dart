import 'package:flutter/material.dart';

class AgendaAndDocsTab extends StatelessWidget {
  const AgendaAndDocsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        Text('1. Báo cáo công việc tuần trước'),
        Text('2. Triển khai kế hoạch tuần tới'),
        SizedBox(height: 16),
        Text('Tài liệu đính kèm:'),
        Text('- BaoCaoTuanTruoc.pdf'),
        Text('- KeHoachTuanToi.docx'),
      ],
    );
  }
}
