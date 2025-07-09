// Hiển thị loại file
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:quanlyhop/data/models/calendar_detail_model.dart';
import 'package:quanlyhop/data/services/calendar_service.dart';
import 'package:quanlyhop/presentation/widgets/calendar_detail_tab/pdf_viewer_screen.dart';

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

Future<bool> requestStoragePermission() async {
  if (Platform.isAndroid) {
    final status = await Permission.storage.request();
    return status.isGranted;
  }
  return true; // iOS không cần quyền này
}

// Thêm hàm tạo tên file với timestamp UTC
String generateFileNameWithTimestamp(String originalName) {
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

// Tab Tài liệu - xem trực tiếp PDF trên app
Future<void> viewPdf(
  BuildContext context,
  MeetingDocument doc,
  CalendarService calendarService,
) async {
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      return;
    }

    showLoadingSnackBar(context, 'Đang tải file PDF...');

    final fileBytes = await calendarService.openPdfBytes(meetingDocument: doc);

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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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

// Tab Tài liệu - hàm tải file
Future<void> downloadFile(
  BuildContext context,
  MeetingDocument doc,
  calendarService,
) async {
  try {
    // Kiểm tra quyền
    if (!await requestStoragePermission()) {
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      return;
    }

    if (!context.mounted) return;
    showLoadingSnackBar(context, 'Đang tải xuống file...');

    // lấy dữ liệu file
    final fileBytes = await calendarService.openPdfBytes(meetingDocument: doc);

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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      return;
    }

    // Tạo tên file với timestamp UTC
    final fileNameWithTimestamp = generateFileNameWithTimestamp(
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

// Tab Kết luận - xem trực tiếp PDF trên app
Future<void> viewPdfInConsulsion(
  BuildContext context,
  MeetingConslusion meetingConslusion,
  CalendarService calendarService,
) async {
  try {
    if (meetingConslusion.type != 'application/pdf') {
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      return;
    }

    showLoadingSnackBar(context, 'Đang tải file PDF...');

    final fileBytes = await calendarService.getFileBytes(
      meetingConslusion: meetingConslusion,
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
                title:
                    meetingConslusion.title ??
                    meetingConslusion.originalName ??
                    'Tài liệu PDF',
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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

// Tab Kết luận - hàm tải file
Future<void> downloadFileInConsulsion(
  BuildContext context,
  MeetingConslusion meetingConslusion,
  calendarService,
) async {
  try {
    // Kiểm tra quyền
    if (!await requestStoragePermission()) {
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      return;
    }

    // kiểm tra file hợp lệ
    if (meetingConslusion.scheduleId == null ||
        meetingConslusion.originalName == null) {
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      return;
    }

    if (!context.mounted) return;
    showLoadingSnackBar(context, 'Đang tải xuống file...');

    // lấy dữ liệu file
    final fileBytes = await calendarService.getFileBytes(
      meetingConslusion: meetingConslusion,
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      return;
    }

    // Tạo tên file với timestamp UTC
    final fileNameWithTimestamp = generateFileNameWithTimestamp(
      meetingConslusion.originalName!,
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
void showLoadingSnackBar(BuildContext context, String message) {
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
