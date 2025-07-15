import 'package:flutter/material.dart';
import 'package:quanlyhop/data/models/calendar_detail_model.dart';
import 'package:intl/intl.dart';
import 'package:quanlyhop/data/services/calendar_service.dart';
import 'package:quanlyhop/presentation/widgets/calendar_detail_tab/xem_va_tai_file.dart';

class AgendaTab extends StatefulWidget {
  final String meetingId;
  final MeetingData meetingData;

  const AgendaTab({
    super.key,
    required this.meetingData,
    required this.meetingId,
  });

  @override
  State<AgendaTab> createState() => _AgendaTab();
}

class _AgendaTab extends State<AgendaTab> {
  final CalendarService _calendarService = CalendarService();

  // Hàm chuyển đổi chuỗi thời gian thành DateTime
  DateTime? _parseTime(String? time) {
    if (time == null || time.isEmpty) return null;
    try {
      return DateTime.parse(time);
    } catch (e) {
      try {
        final format = DateFormat('HH:mm');
        return format.parse(time);
      } catch (e) {
        debugPrint('Lỗi định dạng thời gian: $time');
        return null;
      }
    }
  }

  // Hàm định dạng thời gian thành HH:mm
  String _formatTime(String? time) {
    if (time == null || time.isEmpty) return '--:--';
    try {
      final parsedTime = _parseTime(time);
      if (parsedTime == null) {
        return time;
      }
      return DateFormat('HH:mm').format(parsedTime);
    } catch (e) {
      return time;
    }
  }

  // Hàm tính thời lượng giữa hai thời điểm
  String _calculateDuration(String? startTime, String? endTime) {
    final start = _parseTime(startTime);
    final end = _parseTime(endTime);

    if (start == null || end == null) return '';

    final duration = end.difference(start);
    if (duration.inMinutes > 0) {
      final hours = duration.inHours;
      final minutes = duration.inMinutes % 60;

      if (hours > 0) {
        return '(${hours}h ${minutes}p)';
      } else {
        return '(${minutes}p)';
      }
    }
    return '';
  }

  // hàm xử lý khoảng trắng trong nội dung
  String _cleanNoidung(String? noidung) {
    if (noidung == null || noidung.isEmpty) return '';
    // loại bỏ khoảng trắng đầu cuối và khoảng trắng ở giữa
    return noidung.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  @override
  Widget build(BuildContext context) {
    final List<MeetingContent>? contentList = widget.meetingData.meetingContent;

    // lấy id những tài liệu của Chương trình họp
    // final tailieuIds =
    //     contentList
    //         ?.where((content) => content.tailieu != null)
    //         .map((content) => content.tailieu?.id)
    //         .toList() ??
    //     [];

    // Sắp xếp chương trình họp theo thời gian
    List<MeetingContent> sortedContentList = [];
    if (contentList != null && contentList.isNotEmpty) {
      sortedContentList = List.from(contentList)
        ..removeWhere((content) => content.isDeleted == true);
      sortedContentList.sort((a, b) {
        final timeA = _parseTime(a.startTime);
        final timeB = _parseTime(b.startTime);

        if (timeA == null && timeB == null) return 0;
        if (timeA == null) return 1;
        if (timeB == null) return -1;

        return timeA.compareTo(timeB);
      });
    }

    return Container(
      color: Colors.grey[50],
      child: Column(
        children: [
          // Header - Không cố định
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.teal.shade100, Colors.teal.shade50],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              children: [
                // Icon và tiêu đề bên trái - cho phép co giãn
                Flexible(
                  flex: 1,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.schedule, color: Colors.black, size: 24),
                      const SizedBox(width: 12),
                      Flexible(
                        child: Text(
                          'Chương trình họp',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),

                // Khoảng cách giữa tiêu đề và badge
                const SizedBox(width: 12),

                // Số lượng nội dung bên phải - nổi bật hơn
                if (sortedContentList.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.transparent, // Nền trong suốt
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.blueGrey),
                    ),
                    child: Text(
                      '${sortedContentList.length} nội dung',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.blueGrey,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Nội dung chính
          Expanded(
            child:
                sortedContentList.isNotEmpty
                    ? ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: sortedContentList.length,
                      itemBuilder: (context, index) {
                        final content = sortedContentList[index];
                        final isLast = index == sortedContentList.length - 1;

                        return _buildAgendaItem(
                          content: content,
                          index: index,
                          isLast: isLast,
                        );
                      },
                    )
                    : _buildEmptyState(),
          ),
        ],
      ),
    );
  }

  Widget _buildAgendaItem({
    required MeetingContent content,
    required int index,
    required bool isLast,
  }) {
    final startTime = _formatTime(content.startTime);
    final endTime = _formatTime(content.endTime);
    final duration = _calculateDuration(content.startTime, content.endTime);
    final document = content.tailieu;
    final isPdf =
        document != null &&
        document.type == 'application/pdf' &&
        document.scheduleId != null &&
        document.originalName != null;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline bên trái
          Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.teal[400],
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.teal.withAlpha((255 * 0.1).round()),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 60,
                  color: Colors.teal[100],
                  margin: const EdgeInsets.symmetric(vertical: 8),
                ),
            ],
          ),

          const SizedBox(width: 16),

          // Nội dung chính
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withAlpha((255 * 0.1).round()),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
                border: Border.all(color: Colors.grey[200]!, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Thời gian
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.blue[200]!, width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 16,
                          color: Colors.blue[700],
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '$startTime - $endTime',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue[700],
                          ),
                        ),
                        if (duration.isNotEmpty) ...[
                          const SizedBox(width: 4),
                          Text(
                            duration,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue[600],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Tiêu đề/Chủ trì
                  if (content.title != null && content.title!.isNotEmpty) ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.person, size: 18, color: Colors.grey[600]),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Chủ trì, thực hiện',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                content.title!,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Nội dung
                  if (content.content != null &&
                      content.content!.isNotEmpty) ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.description,
                          size: 18,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Nội dung',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _cleanNoidung(content.content!),
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black87,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],

                  // Tài liệu
                  if (document != null) ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Icon loại file
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: getFileColor(
                              document.type,
                            ).withAlpha((255 * 0.1).round()),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            getFileIcon(document.type),
                            color: getFileColor(document.type),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Thông tin tài liệu
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tài liệu',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _cleanNoidung(document.title),
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),

                              const SizedBox(height: 6),

                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: getFileColor(
                                    document.type,
                                  ).withAlpha((255 * 0.1).round()),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  getFileType(
                                    document.type ?? 'Không xác định',
                                  ).toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: getFileColor(document.type),
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
                                margin: const EdgeInsets.only(bottom: 4),
                                decoration: BoxDecoration(
                                  color: Colors.teal.withAlpha(
                                    (255 * 0.1).round(),
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: IconButton(
                                  onPressed:
                                      () => viewPdf(
                                        context,
                                        document,
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
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: IconButton(
                                onPressed:
                                    () => downloadFile(
                                      context,
                                      document,
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
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.event_note, size: 40, color: Colors.grey[400]),
            ),
            const SizedBox(height: 16),
            Text(
              'Chưa có chương trình họp',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Chương trình họp sẽ được cập nhật sau',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
