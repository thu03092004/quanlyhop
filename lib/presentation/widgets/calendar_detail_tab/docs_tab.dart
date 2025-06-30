import 'package:flutter/material.dart';
import 'package:quanlyhop/data/models/calendar_detail_model.dart';

class DocsTab extends StatelessWidget {
  final MeetingData meetingData;

  const DocsTab({super.key, required this.meetingData});

  @override
  Widget build(BuildContext context) {
    final List<MeetingDocument>? documentList = meetingData.meetingDocument;

    if (documentList == null || documentList.isEmpty) {
      return Center(
        child: Text(
          'Chưa có tài liệu họp',
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: documentList.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final doc = documentList[index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tên tài liệu
              Text(
                doc.title ?? '(Không có tiêu đề)',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 6),

              // Đơn vị chủ trì
              if (doc.organ != null && doc.organ!.isNotEmpty)
                Row(
                  children: [
                    Icon(
                      Icons.account_balance,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 6),
                    Text(
                      doc.organ!,
                      style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                    ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }
}
