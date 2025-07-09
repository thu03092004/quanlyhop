import 'package:flutter/material.dart';
import 'package:quanlyhop/data/models/calendar_detail_model.dart';
import 'package:quanlyhop/data/services/calendar_service.dart';
import 'package:quanlyhop/presentation/widgets/calendar_detail_tab/xem_va_tai_file.dart';

class ConslusionTab extends StatefulWidget {
  final MeetingData meetingData;

  const ConslusionTab({super.key, required this.meetingData});
  @override
  State<ConslusionTab> createState() => _ConslusionTabState();
}

class _ConslusionTabState extends State<ConslusionTab> {
  final CalendarService _calendarService = CalendarService();

  @override
  Widget build(BuildContext context) {
    // Lọc danh sách kết luận theo trạng thái isDeleted
    final activeConclusions =
        widget.meetingData.meetingConslusion
            ?.where((conclusion) => conclusion.isDeleted == false)
            .toList();
    final deletedConclusions =
        widget.meetingData.meetingConslusion
            ?.where((conclusion) => conclusion.isDeleted == true)
            .toList();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withAlpha((0.1 * 255).round()),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TabBar(
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.grey.shade700,
                    labelStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    indicator: BoxDecoration(
                      color: Colors.teal.shade500,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicatorPadding: const EdgeInsets.all(2),
                    indicatorWeight: 0,
                    dividerHeight: 0,
                    splashFactory: NoSplash.splashFactory,
                    overlayColor: WidgetStateProperty.all(Colors.transparent),
                    tabs: const [
                      Tab(text: 'Danh sách'),
                      Tab(text: 'Danh sách đã xóa'),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        body: TabBarView(
          children: [
            // Tab Danh sách
            _buildConclusionList(context, activeConclusions),
            // Tab Danh sách đã xóa
            _buildConclusionList(context, deletedConclusions),
          ],
        ),
      ),
    );
  }

  Widget _buildConclusionList(
    BuildContext context,
    List<MeetingConslusion>? conclusions,
  ) {
    if (conclusions == null || conclusions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.assignment_outlined,
              size: 48,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Chưa có kết luận nào',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: conclusions.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final conclusion = conclusions[index];
        final isPdf = conclusion.type == 'application/pdf';
        final hasFile =
            conclusion.url?.isNotEmpty == true &&
            conclusion.originalName?.isNotEmpty == true;

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade200,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tiêu đề
                Text(
                  conclusion.title ?? 'Không có tiêu đề',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 12),

                // Nội dung
                Text(
                  conclusion.content?.replaceAll(RegExp(r'<[^>]+>'), '') ??
                      'Không có nội dung',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                    height: 1.4,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),

                if (hasFile) ...[
                  const SizedBox(height: 16),

                  // Thông tin file tối giản
                  Row(
                    children: [
                      Icon(
                        isPdf ? Icons.picture_as_pdf : Icons.attach_file,
                        size: 16,
                        color: Colors.blue.shade600,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          conclusion.originalName ?? 'Tệp đính kèm',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.blue.shade600,
                          ),
                          // maxLines: 1,
                          // overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Nút thao tác cho web
                  Wrap(
                    spacing: 8,
                    children: [
                      if (isPdf)
                        TextButton.icon(
                          onPressed: () {
                            viewPdfInConsulsion(
                              context,
                              conclusion,
                              _calendarService,
                            );
                          },
                          icon: const Icon(Icons.visibility, size: 16),
                          label: const Text('Xem file'),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.teal,
                            side: const BorderSide(color: Colors.teal),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ),

                      TextButton.icon(
                        onPressed: () {
                          downloadFileInConsulsion(
                            context,
                            conclusion,
                            _calendarService,
                          );
                        },
                        icon: const Icon(Icons.download, size: 16),
                        label: const Text('Tải xuống'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.teal,
                          side: const BorderSide(color: Colors.teal),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
