import 'package:flutter/material.dart';
import 'package:quanlyhop/data/models/calendar_detail_model.dart';
import 'package:quanlyhop/data/services/calendar_service.dart';
import 'package:quanlyhop/presentation/widgets/calendar_detail_tab/xem_va_tai_file.dart';

class DocsTab extends StatefulWidget {
  final String meetingId;
  final MeetingData meetingData;

  const DocsTab({
    super.key,
    required this.meetingId,
    required this.meetingData,
  });

  @override
  State<DocsTab> createState() => _DocsTabState();
}

class _DocsTabState extends State<DocsTab> {
  final CalendarService _calendarService = CalendarService();

  // hàm xử lý khoảng trắng trong Tên tài liệu
  String _cleanTentailieu(String? noidung) {
    if (noidung == null || noidung.isEmpty) return 'Không có tiêu đề';
    // loại bỏ khoảng trắng đầu cuối và khoảng trắng ở giữa
    return noidung.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  @override
  Widget build(BuildContext context) {
    // lấy danh sách id trong meetingDocument để lọc tài liệu
    // tránh lấy nhầm tài liệu
    // vì getDocs lấy cả tài liệu trong Chương trình họp + Tài liệu
    final meetingDocumentIds =
        widget.meetingData.meetingDocument?.map((doc) => doc.id).toList() ?? [];

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.grey[50]!, Colors.grey[100]!],
        ),
      ),
      child: FutureBuilder<List<MeetingDocument>>(
        future: _calendarService.getDocs(widget.meetingId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
                    strokeWidth: 3,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Đang tải tài liệu...',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.teal,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Container(
                padding: const EdgeInsets.all(24),
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline, size: 48, color: Colors.red[400]),
                    const SizedBox(height: 16),
                    Text(
                      'Lỗi khi tải tài liệu',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.red[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${snapshot.error}',
                      style: TextStyle(fontSize: 14, color: Colors.red[600]),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          } else if (snapshot.hasData) {
            // lọc lại những tài liệu của Tài liệu
            final documentList =
                snapshot.data!
                    .where((doc) => meetingDocumentIds.contains(doc.id))
                    .where((doc) => doc.isDeleted != true)
                    .toList();
            if (documentList.isEmpty) {
              return Center(
                child: Container(
                  padding: const EdgeInsets.all(32),
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withAlpha((255 * 0.1).round()),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.teal[50],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.folder_open,
                          size: 48,
                          color: Colors.teal[400],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Chưa có tài liệu họp',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tài liệu sẽ được hiển thị ở đây khi có',
                        style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ),
              );
            }

            // Nhóm tài liệu theo documentType.id, tài liệu không có documentType vào nhóm "Tài liệu khác"
            final groupedDocs = <String?, List<MeetingDocument>>{};
            for (var doc in documentList) {
              final typeId = doc.documentType?.id ?? 'other';
              groupedDocs[typeId] ??= [];
              groupedDocs[typeId]!.add(doc);
            }

            // Sắp xếp các documentType theo thuTu, nhóm "Tài liệu khác" ở cuối
            final sortedTypeIds =
                groupedDocs.keys.toList()..sort((a, b) {
                  if (a == 'other') return 1;
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
                    // Header của từng loại tài liệu
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.shade300,
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Icon(
                              Icons.folder,
                              color: Colors.teal.shade600,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              docTypeName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.teal.shade50,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${docs.length}',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.teal.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Danh sách tài liệu
                    ...docs.map((doc) {
                      final isPdf =
                          doc.type == 'application/pdf' &&
                          doc.scheduleId != null &&
                          doc.originalName != null;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withAlpha((255 * 0.1).round()),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                          border: Border.all(color: Colors.grey[100]!),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap:
                                  isPdf
                                      ? () => viewPdf(
                                        context,
                                        doc,
                                        _calendarService,
                                      )
                                      : null,
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    // Icon loại file
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: getFileColor(
                                          doc.type,
                                        ).withAlpha((255 * 0.1).round()),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        getFileIcon(doc.type),
                                        color: getFileColor(doc.type),
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 16),

                                    // Thông tin tài liệu
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _cleanTentailieu(doc.title),
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black87,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 6),

                                          if (doc.organ != null &&
                                              doc.organ!.isNotEmpty)
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                bottom: 4,
                                              ),
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons.account_balance,
                                                    size: 14,
                                                    color: Colors.grey[600],
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Expanded(
                                                    child: Text(
                                                      doc.organ!,
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.grey[600],
                                                      ),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),

                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: getFileColor(
                                                doc.type,
                                              ).withAlpha((255 * 0.1).round()),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              getFileType(
                                                doc.type ?? 'Không xác định',
                                              ).toUpperCase(),
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: getFileColor(doc.type),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Buttons
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (isPdf)
                                          Container(
                                            margin: const EdgeInsets.only(
                                              bottom: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.teal.withAlpha(
                                                (255 * 0.1).round(),
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: IconButton(
                                              onPressed:
                                                  () => viewPdf(
                                                    context,
                                                    doc,
                                                    _calendarService,
                                                  ),
                                              icon: const Icon(
                                                Icons.visibility,
                                                color: Colors.teal,
                                                size: 20,
                                              ),
                                              tooltip: 'Xem',
                                              padding: const EdgeInsets.all(8),
                                              constraints: const BoxConstraints(
                                                minWidth: 36,
                                                minHeight: 36,
                                              ),
                                            ),
                                          ),

                                        Container(
                                          decoration: BoxDecoration(
                                            color: Colors.blue.withAlpha(
                                              (255 * 0.1).round(),
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: IconButton(
                                            onPressed:
                                                () => downloadFile(
                                                  context,
                                                  doc,
                                                  _calendarService,
                                                ),
                                            icon: const Icon(
                                              Icons.download,
                                              color: Colors.blue,
                                              size: 20,
                                            ),
                                            tooltip: 'Tải xuống',
                                            padding: const EdgeInsets.all(8),
                                            constraints: const BoxConstraints(
                                              minWidth: 36,
                                              minHeight: 36,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),

                    const SizedBox(height: 8),
                  ],
                );
              },
            );
          } else {
            return Center(
              child: Container(
                padding: const EdgeInsets.all(24),
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withAlpha((255 * 0.1).round()),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.inbox, size: 48, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'Không có dữ liệu',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
