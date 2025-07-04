import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:quanlyhop/data/models/calendar_detail_model.dart';
import 'package:quanlyhop/data/services/calendar_service.dart';

class DocsTab extends StatefulWidget {
  final String meetingId;

  const DocsTab({super.key, required this.meetingId});

  @override
  State<DocsTab> createState() => _DocsTabState();
}

class _DocsTabState extends State<DocsTab> {
  final CalendarService _calendarService = CalendarService();

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

  // Icon cho từng loại file
  IconData getFileIcon(String? type) {
    switch (type) {
      case 'application/msword':
      case 'application/vnd.openxmlformats-officedocument.wordprocessingml.document':
        return Icons.description;
      case 'text/plain':
        return Icons.text_snippet;
      case 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet':
      case 'application/vnd.ms-excel':
        return Icons.table_chart;
      case 'application/vnd.openxmlformats-officedocument.presentationml.presentation':
        return Icons.slideshow;
      case 'application/x-zip-compressed':
      case 'application/x-rar-compressed':
      case '':
        return Icons.archive;
      case 'application/pdf':
        return Icons.picture_as_pdf;
      default:
        return Icons.insert_drive_file;
    }
  }

  // Màu sắc cho từng loại file
  Color getFileColor(String? type) {
    switch (type) {
      case 'application/msword':
      case 'application/vnd.openxmlformats-officedocument.wordprocessingml.document':
        return Colors.blue;
      case 'text/plain':
        return Colors.grey;
      case 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet':
      case 'application/vnd.ms-excel':
        return Colors.green;
      case 'application/vnd.openxmlformats-officedocument.presentationml.presentation':
        return Colors.orange;
      case 'application/x-zip-compressed':
      case 'application/x-rar-compressed':
      case '':
        return Colors.purple;
      case 'application/pdf':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // hàm xử lý khoảng trắng trong Tên tài liệu
  String _cleanTentailieu(String? noidung) {
    if (noidung == null || noidung.isEmpty) return 'Không có tiêu đề';
    // loại bỏ khoảng trắng đầu cuối và khoảng trắng ở giữa
    return noidung.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  // xem trực tiếp PDF trên app
  Future<void> _viewPdf(BuildContext context, MeetingDocument doc) async {
    try {
      if (doc.type != 'application/pdf') {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.info, color: Colors.white),
                SizedBox(width: 8),
                Text('Chỉ file PDF được hỗ trợ xem trực tiếp'),
              ],
            ),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
        return;
      }

      if (!Platform.isAndroid && !Platform.isIOS) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.info, color: Colors.white),
                SizedBox(width: 8),
                Text('Hiện tại chưa hỗ trợ xem file PDF trên nền tảng này.'),
              ],
            ),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
        return;
      }

      _showLoadingSnackBar(context, 'Đang tải file PDF...');

      final fileBytes = await _calendarService.openPdfBytes(
        meetingDocument: doc,
      );

      if (!context.mounted) return;
      // Ẩn loading snackbar bằng cách hiển thị snackbar mới
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      if (!context.mounted) return;
      if (fileBytes != null) {
        if (!context.mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => PdfViewerScreen(
                  pdfBytes: fileBytes,
                  title: doc.title ?? doc.originalName ?? 'Tài liệu PDF',
                ),
          ),
        );
      } else {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.error, color: Colors.white),
                SizedBox(width: 8),
                Text('Chưa thể xem nội dung của file'),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    } catch (e) {
      // Ẩn loading snackbar khi có lỗi
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text('Lỗi khi tải file PDF: $e')),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  Future<bool> _requestStoragePermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.storage.request();
      return status.isGranted;
    }
    return true; // iOS không cần quyền này
  }

  // Thêm hàm tạo tên file với timestamp UTC
  String _generateFileNameWithTimestamp(String originalName) {
    final now = DateTime.now().toUtc();
    final timestamp = now.millisecondsSinceEpoch;

    final lastDotIndex = originalName.lastIndexOf('.');
    if (lastDotIndex != -1) {
      final nameWithoutExt = originalName.substring(0, lastDotIndex);
      final extension = originalName.substring(lastDotIndex);
      return '${timestamp}_$nameWithoutExt$extension';
    } else {
      return '${timestamp}_$originalName';
    }
  }

  // Sửa đổi hàm _downloadFile
  Future<void> _downloadFile(BuildContext context, MeetingDocument doc) async {
    try {
      // Kiểm tra quyền
      if (!await _requestStoragePermission()) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.error, color: Colors.white),
                SizedBox(width: 8),
                Text('Quyền lưu trữ bị từ chối'),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
        return;
      }

      // kiểm tra file hợp lệ
      if (doc.scheduleId == null || doc.originalName == null) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.error, color: Colors.white),
                SizedBox(width: 8),
                Text('File không hợp lệ'),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
        return;
      }

      if (!context.mounted) return;
      _showLoadingSnackBar(context, 'Đang tải xuống file...');

      // lấy dữ liệu file
      final fileBytes = await _calendarService.openPdfBytes(
        meetingDocument: doc,
      );

      if (!context.mounted) return;
      // Ẩn loading snackbar
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      if (fileBytes == null) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.error, color: Colors.white),
                SizedBox(width: 8),
                Text('Không thể tải file'),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
        return;
      }

      // Tạo tên file với timestamp UTC
      final fileNameWithTimestamp = _generateFileNameWithTimestamp(
        doc.originalName!,
      );

      // Lấy thư mục lưu trữ phù hợp cho từng platform
      Directory? directory;
      String filePath;
      String locationMessage = '';

      if (Platform.isAndroid) {
        try {
          // Trên Android, sử dụng thư mục Downloads công cộng
          directory = Directory('/storage/emulated/0/Download');

          // Kiểm tra và tạo thư mục nếu cần
          if (!await directory.exists()) {
            await directory.create(recursive: true);
          }

          filePath = '${directory.path}/$fileNameWithTimestamp';
          locationMessage = 'trong thư mục Downloads';
        } catch (e) {
          // Fallback: sử dụng external storage directory
          directory = await getExternalStorageDirectory();
          if (directory != null) {
            // Tạo thư mục Downloads trong external storage
            final downloadsDir = Directory(
              '${directory.parent.parent.parent.parent.path}/Download',
            );
            if (await downloadsDir.exists()) {
              directory = downloadsDir;
              filePath = '${directory.path}/$fileNameWithTimestamp';
              locationMessage = 'trong thư mục Downloads';
            } else {
              // Fallback cuối cùng
              directory = await getApplicationDocumentsDirectory();
              filePath = '${directory.path}/$fileNameWithTimestamp';
              locationMessage = 'trong thư mục ứng dụng';
            }
          } else {
            directory = await getApplicationDocumentsDirectory();
            filePath = '${directory.path}/$fileNameWithTimestamp';
            locationMessage = 'trong thư mục ứng dụng';
          }
        }
      } else if (Platform.isIOS) {
        // Trên iOS, sử dụng thư mục Documents (có thể truy cập qua Files app)
        directory = await getApplicationDocumentsDirectory();
        filePath = '${directory.path}/$fileNameWithTimestamp';
        locationMessage =
            'trong thư mục Documents (có thể xem qua ứng dụng Files)';
      } else {
        // Cho các platform khác
        directory = await getDownloadsDirectory();
        if (directory != null) {
          filePath = '${directory.path}/$fileNameWithTimestamp';
          locationMessage = 'trong thư mục Downloads';
        } else {
          directory = await getApplicationDocumentsDirectory();
          filePath = '${directory.path}/$fileNameWithTimestamp';
          locationMessage = 'trong thư mục Documents';
        }
      }

      // Tạo file và ghi dữ liệu
      final file = File(filePath);

      // Kiểm tra nếu file vẫn tồn tại (trường hợp hiếm gặp)
      if (await file.exists()) {
        await file.delete();
      }

      await file.writeAsBytes(fileBytes);

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Đã tải xuống file: $fileNameWithTimestamp tại $locationMessage',
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          action: SnackBarAction(
            label: 'Mở',
            textColor: Colors.white,
            onPressed: () async {
              final result = await OpenFile.open(filePath);
              if (!context.mounted) return;
              if (result.type != ResultType.done) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.error, color: Colors.white),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text('Không thể mở file: ${result.message}'),
                        ),
                      ],
                    ),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                );
              }
            },
          ),
        ),
      );
    } catch (e) {
      // Ẩn loading snackbar khi có lỗi
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text('Lỗi khi tải xuống file: $e')),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  // Hiển thị SnackBar loading
  void _showLoadingSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(minutes: 1), // Thời gian dài để không tự tắt
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
            final documentList = snapshot.data!;
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
              if (doc.isDeleted != true) {
                final typeId = doc.documentType?.id ?? 'other';
                groupedDocs[typeId] ??= [];
                groupedDocs[typeId]!.add(doc);
              }
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
                        vertical: 12,
                      ),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.teal, Colors.teal.shade300],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.teal.withAlpha((255 * 0.3).round()),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Icon(
                              Icons.folder,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              docTypeName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                height: 1.2,
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
                              color: Colors.white.withAlpha(
                                (255 * 0.2).round(),
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${docs.length}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
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
                                  isPdf ? () => _viewPdf(context, doc) : null,
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
                                                  () => _viewPdf(context, doc),
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
                                                () =>
                                                    _downloadFile(context, doc),
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
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.teal.withAlpha((255 * 0.4).round()),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white.withAlpha((255 * 0.05).round()),
              Colors.white,
            ],
          ),
        ),
        child: PDFView(
          pdfData: pdfBytes,
          enableSwipe: true,
          swipeHorizontal: false,
          autoSpacing: true,
          pageFling: true,
          backgroundColor: Colors.transparent,
          onError: (error) {
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.error, color: Colors.white),
                    const SizedBox(width: 8),
                    Expanded(child: Text('Lỗi khi hiển thị PDF: $error')),
                  ],
                ),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            );
          },
          onPageError: (page, error) {
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.error, color: Colors.white),
                    const SizedBox(width: 8),
                    Expanded(child: Text('Lỗi ở trang $page: $error')),
                  ],
                ),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
