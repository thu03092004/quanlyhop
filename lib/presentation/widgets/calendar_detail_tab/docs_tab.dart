import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:quanlyhop/data/models/calendar_detail_model.dart';
import 'package:quanlyhop/data/services/calendar_service.dart';

class DocsTab extends StatefulWidget {
  final String meetingId;

  const DocsTab({super.key, required this.meetingId});

  @override
  State<DocsTab> createState() => _DocsTabState();
}

// Hiển thị loại file
String getFileType(String? type) {
  switch (type) {
    case 'application/msword':
      return 'doc';
    case 'application/vnd.openxmlformats-officedocument.wordprocessingml.document':
      return 'docx';
    case 'text/plain':
      return 'txt';
    case 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet':
      return 'xlsx';
    case 'application/vnd.ms-excel':
      return 'xls';
    case 'application/vnd.openxmlformats-officedocument.presentationml.presentation':
      return 'pptx';
    case 'application/x-zip-compressed':
      return 'zip';
    case 'application/x-rar-compressed':
      return 'Tệp nén RAR';
    case 'application/pdf':
      return 'pdf';
    case '':
      return 'rar';
    default:
      return 'Không xác định';
  }
}

class _DocsTabState extends State<DocsTab> {
  final CalendarService _calendarService = CalendarService();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<MeetingDocument>>(
      future: _calendarService.getDocs(widget.meetingId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Lỗi khi tải tài liệu: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          final documentList = snapshot.data!;
          if (documentList.isEmpty) {
            return Center(
              child: Text(
                'Chưa có tài liệu họp',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            );
          }

          // Nhóm tài liệu theo documentType.id, tài liệu không có documentType vào nhóm "Tài liệu khác"
          final groupedDocs = <String?, List<MeetingDocument>>{};
          for (var doc in documentList) {
            if (doc.isDeleted != true) {
              final typeId =
                  doc.documentType?.id ??
                  'other'; // Nhóm "other" cho tài liệu không có documentType
              groupedDocs[typeId] ??= [];
              groupedDocs[typeId]!.add(doc);
            }
          }

          // Sắp xếp các documentType theo thuTu, nhóm "Tài liệu khác" ở cuối
          final sortedTypeIds =
              groupedDocs.keys.toList()..sort((a, b) {
                if (a == 'other') return 1; // Đẩy "other" xuống cuối
                if (b == 'other') return -1;
                final docA = documentList.firstWhere(
                  (doc) => doc.documentType?.id == a,
                  orElse: () => documentList.first,
                );
                final docB = documentList.firstWhere(
                  (doc) => doc.documentType?.id == b,
                  orElse: () => documentList.first,
                );
                final thuTuA = docA.documentType?.thuTu ?? 0;
                final thuTuB = docB.documentType?.thuTu ?? 0;
                return thuTuA.compareTo(thuTuB);
              });

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: sortedTypeIds.length,
            itemBuilder: (context, index) {
              final typeId = sortedTypeIds[index];
              final docs = groupedDocs[typeId]!;
              // Sắp xếp tài liệu trong mỗi documentType theo thuTu
              docs.sort((a, b) => (a.thuTu ?? 0).compareTo(b.thuTu ?? 0));

              // Lấy tên documentType, nếu là "other" thì dùng "Tài liệu khác"
              final docTypeName =
                  typeId == 'other'
                      ? 'Tài liệu khác'
                      : docs.first.documentType?.ten ?? 'Không xác định';

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      docTypeName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ),
                  ...docs.map((doc) {
                    final isPdf =
                        doc.type == 'application/pdf' &&
                        doc.scheduleId != null &&
                        doc.originalName != null;

                    return GestureDetector(
                      onTap:
                          isPdf
                              ? () async {
                                try {
                                  if (!Platform.isAndroid && !Platform.isIOS) {
                                    if (!context.mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Hiện tại chưa hỗ trợ xem file PDF trên nền tảng này.',
                                        ),
                                      ),
                                    );
                                    return;
                                  }

                                  final pdfBytes = await _calendarService
                                      .openPdfBytes(
                                        meetingDocument: doc,
                                        type: doc.type ?? '',
                                      );
                                  if (!context.mounted) return;
                                  if (pdfBytes != null) {
                                    if (!context.mounted) return;
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => PdfViewerScreen(
                                              pdfBytes: pdfBytes,
                                              title:
                                                  doc.title ??
                                                  doc.originalName ??
                                                  'Tài liệu PDF',
                                            ),
                                      ),
                                    );
                                  } else {
                                    if (!context.mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        // content: Text('File không phải PDF'),
                                        content: Text(
                                          'Chưa thể xem nội dung của file',
                                        ),
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Lỗi khi tải file PDF: $e'),
                                    ),
                                  );
                                }
                              }
                              : null,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withAlpha((255 * 0.1).round()),
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
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: isPdf ? Colors.black87 : Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 6),
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
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ],
                              ),
                            Text(
                              'Loại file: ${getFileType(doc.type ?? 'Không xác định')}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              );
            },
          );
        } else {
          return const Center(child: Text('Không có dữ liệu'));
        }
      },
    );
  }
}

class PdfViewerScreen extends StatelessWidget {
  final Uint8List pdfBytes;
  final String title;

  const PdfViewerScreen({
    super.key,
    required this.pdfBytes,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: PDFView(
        pdfData: pdfBytes,
        enableSwipe: true,
        swipeHorizontal: false,
        autoSpacing: true,
        pageFling: true,
        onError: (error) {
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi khi hiển thị PDF: $error')),
          );
        },
        onPageError: (page, error) {
          if (!context.mounted) return;
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Lỗi ở trang $page: $error')));
        },
      ),
    );
  }
}
