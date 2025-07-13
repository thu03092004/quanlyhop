import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:quanlyhop/data/models/calendar_detail_model.dart';
import 'package:quanlyhop/data/services/meeting_management_service.dart';
import 'package:quanlyhop/data/services/permission_service.dart';

class MeetingManagementScreen extends StatefulWidget {
  const MeetingManagementScreen({super.key});

  @override
  State<MeetingManagementScreen> createState() =>
      _MeetingManagementScreenState();
}

class _MeetingManagementScreenState extends State<MeetingManagementScreen> {
  final PermissionService _permissionService = PermissionService();
  final MeetingManagementService _meetingService = MeetingManagementService();
  bool _hasPermission = false; // trạng thái quyền
  String? _errorMessage;
  bool _isLocaleInitialized = false;

  DateTime selectedDate = DateTime.now();
  late List<Map<String, dynamic>> weeks;

  // Đang cập nhật - Đã duyệt - Đã xóa
  List<MeetingData> pendingMeetings = [];
  List<MeetingData> approvedMeetings = [];
  List<MeetingData> deletedMeetings = [];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeLocale();
    weeks = getWeeksInYear(selectedDate.year);
    _checkPermissions();
    _fetchMeetings();
  }

  Future<void> _initializeLocale() async {
    try {
      await initializeDateFormatting('vi_VN', null);
      setState(() {
        _isLocaleInitialized = true;
      });
      _fetchMeetings();
    } catch (e) {
      debugPrint('Lỗi khởi tạo locale: $e');
      setState(() {
        _isLocaleInitialized =
            true; // Vẫn cho phép tiếp tục với locale mặc định
      });
      _fetchMeetings();
    }
  }

  Future<void> _checkPermissions() async {
    try {
      final hasPermission = await _permissionService.hasSchedulePermission();

      if (mounted) {
        setState(() {
          _hasPermission = hasPermission;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
        });
      }
    }
  }

  Future<void> _fetchMeetings() async {
    if (!_hasPermission || !_isLocaleInitialized) return;

    setState(() {
      _isLoading = true;
    });

    try {
      List<DateTime> weekDays = getCurrentWeekDays();
      DateTime startDate = weekDays.first;
      DateTime endDate = weekDays.last;

      final pending = await _meetingService.getPendingMeetings(
        dateFrom: startDate,
        dateTo: endDate,
      );

      final approved = await _meetingService.getApprovedMeetings(
        dateFrom: startDate,
        dateTo: endDate,
      );
      final deleted = await _meetingService.getDeletedMeetings(
        dateFrom: startDate,
        dateTo: endDate,
      );

      if (mounted) {
        setState(() {
          pendingMeetings = _sortMeetingsByDate(pending);
          approvedMeetings = _sortMeetingsByDate(approved);
          deletedMeetings = _sortMeetingsByDate(deleted);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Lỗi khi tải dữ liệu lịch: $e';
          _isLoading = false;
        });
      }
    }
  }

  // Hàm sắp xếp lịch từ cũ nhất đến mới nhất
  List<MeetingData> _sortMeetingsByDate(List<MeetingData> meetings) {
    meetings.sort((a, b) {
      try {
        DateTime dateA = DateTime.parse(a.startTime);
        DateTime dateB = DateTime.parse(b.startTime);
        return dateA.compareTo(dateB);
      } catch (e) {
        return 0;
      }
    });
    return meetings;
  }

  // chọn tuần từ dropdown ở title
  void selectWeek(DateTime startDate) {
    setState(() {
      selectedDate = startDate;
      _fetchMeetings();
    });
  }

  // danh sách các tuần trong năm
  List<Map<String, dynamic>> getWeeksInYear(int year) {
    List<Map<String, dynamic>> weeks = [];

    // tìm thứ 2 đầu tiên trước hoặc bằng ngày 01/01 của năm
    DateTime jan1 = DateTime(year, 1, 1);
    DateTime startOfWeek = jan1.subtract(Duration(days: jan1.weekday - 1));

    // Duyệt từng tuần cho đến khi tuần bắt đầu > 31/12 của năm
    while (startOfWeek.isBefore(DateTime(year + 1, 1, 1))) {
      DateTime endOfWeek = startOfWeek.add(Duration(days: 6));

      int weekNumber = weeks.length + 1;

      weeks.add({
        'weekNumber': weekNumber,
        'startDate': startOfWeek,
        'endDate': endOfWeek,
        'label':
            'Tuần ${weekNumber.toString().padLeft(2, '0')} (${DateFormat('dd/MM/yyyy').format(startOfWeek)} - ${DateFormat('dd/MM/yyyy').format(endOfWeek)})',
      });

      startOfWeek = startOfWeek.add(Duration(days: 7));
    }
    return weeks;
  }

  // danh sách các ngày trong tuần hiện tại
  List<DateTime> getCurrentWeekDays() {
    DateTime now = selectedDate;
    int weekday = now.weekday;
    DateTime startOfWeek = now.subtract(Duration(days: weekday - 1));
    return List.generate(7, (index) => startOfWeek.add(Duration(days: index)));
  }

  // tính số tuần trong năm
  int getWeekNumber(DateTime date) {
    DateTime firstDayOfYear = DateTime(date.year, 1, 1);
    int daysSinceFirstDay = date.difference(firstDayOfYear).inDays;
    return (daysSinceFirstDay / 7).ceil() + 1;
  }

  // lấy thông tin tuần hiện tại
  String getCurrentWeekInfo() {
    List<DateTime> weekDays = getCurrentWeekDays();
    DateTime startDate = weekDays.first;
    DateTime endDate = weekDays.last;

    return 'Tuần ${getWeekNumber(startDate)} (${DateFormat('dd/MM/yyyy').format(startDate).substring(0, 5)} - ${DateFormat('dd/MM/yyyy').format(endDate).substring(0, 5)})';
  }

  // chuyển đến tuần trước
  void goToPreviousWeek() {
    setState(() {
      selectedDate = selectedDate.subtract(const Duration(days: 7));
      _fetchMeetings();
    });
  }

  // trở về tuần hiện tại
  void goToCurrentWeek() {
    setState(() {
      selectedDate = DateTime.now();
      _fetchMeetings();
    });
  }

  // chuyển sang tuần sau
  void goToNextWeek() {
    setState(() {
      selectedDate = selectedDate.add(const Duration(days: 7));
      _fetchMeetings();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.teal,
          elevation: 0,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // tiêu đề
              Flexible(
                flex: 1, // ưu tiên không gian cho tiêu đề
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'Quản lý lịch',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize:
                          Theme.of(context).textTheme.titleLarge?.fontSize ??
                          20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        body: Center(
          child: Text(
            'Đã xảy ra lỗi: $_errorMessage',
            style: const TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (!_hasPermission) {
      return Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          backgroundColor: Colors.teal,
          elevation: 0,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // tiêu đề
              Flexible(
                flex: 1, // ưu tiên không gian cho tiêu đề
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'Quản lý lịch',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize:
                          Theme.of(context).textTheme.titleLarge?.fontSize ??
                          20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        body: FutureBuilder(
          future: Future.delayed(const Duration(milliseconds: 200)),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return Center(
                child: Container(
                  padding: const EdgeInsets.all(32),
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withAlpha((255 * 0.2).round()),
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
                          color: Colors.yellow[50],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.warning_amber,
                          size: 48,
                          color: Colors.yellow[400],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Bạn không có quyền thực hiện chức năng này',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Text(
                      //   'Blabla',
                      //   style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                      // ),
                    ],
                  ),
                ),
              );
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      );
    }

    if (!_isLocaleInitialized) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.teal,
          elevation: 0,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // tiêu đề
              Flexible(
                flex: 1, // ưu tiên không gian cho tiêu đề
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'Quản lý lịch',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize:
                          Theme.of(context).textTheme.titleLarge?.fontSize ??
                          20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        elevation: 0, // không đổ bóng
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // tiêu đề
            Flexible(
              flex: 1, // ưu tiên không gian cho tiêu đề
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'Quản lý lịch',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize:
                        Theme.of(context).textTheme.titleLarge?.fontSize ?? 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            const Spacer(),

            Flexible(
              flex: 1,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Color.fromARGB(255, 13, 108, 73)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: PopupMenuButton<Map<String, dynamic>>(
                  color: Colors.white,
                  onSelected: (Map<String, dynamic> week) {
                    selectWeek(week['startDate']);
                  },
                  itemBuilder: (BuildContext context) {
                    return weeks.map((week) {
                      return PopupMenuItem<Map<String, dynamic>>(
                        value: week,
                        child: Text(week['label']),
                      );
                    }).toList();
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          getCurrentWeekInfo(),
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),

                      const SizedBox(width: 8),

                      Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.grey[600],
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // thanh điều hướng tuần
            Center(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Nút tuần trước
                    InkWell(
                      onTap: goToPreviousWeek,
                      splashColor: Colors.grey.withAlpha((0.3 * 255).toInt()),
                      highlightColor: Colors.grey.withAlpha(
                        (0.1 * 255).toInt(),
                      ),
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 6,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.chevron_left,
                              color: Colors.grey[600],
                              size: 20,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Tuần trước',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(width: 16),

                    // nút tuần hiện tại
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Color(0xFF139364),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: GestureDetector(
                        onTap: goToCurrentWeek,
                        child: Row(
                          children: [
                            Icon(
                              Icons.date_range,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Tuần hiện tại',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(width: 16),

                    // Nút tuần sau
                    InkWell(
                      onTap: goToNextWeek,
                      splashColor: Colors.grey.withAlpha((0.3 * 255).toInt()),
                      highlightColor: Colors.grey.withAlpha(
                        (0.1 * 255).toInt(),
                      ),
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 6,
                        ),
                        child: Row(
                          children: [
                            Text(
                              'Tuần sau',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.chevron_right,
                              color: Colors.grey[600],
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Danh sách lịch
            Expanded(
              child:
                  _isLoading
                      ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text('Đang tải dữ liệu...'),
                          ],
                        ),
                      )
                      : RefreshIndicator(
                        onRefresh: _fetchMeetings,
                        child: ListView(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          children: [
                            const SizedBox(height: 10),
                            // Lịch đang cập nhật
                            _buildMeetingSection(
                              title: 'Đang cập nhật',
                              meetings: pendingMeetings,
                              color: Colors.orange,
                              icon: Icons.update,
                            ),
                            const SizedBox(height: 20),

                            // Lịch đã duyệt
                            _buildMeetingSection(
                              title: 'Đã duyệt',
                              meetings: approvedMeetings,
                              color: Colors.green,
                              icon: Icons.check_circle,
                            ),
                            const SizedBox(height: 20),

                            // Lịch đã xóa
                            _buildMeetingSection(
                              title: 'Đã xóa',
                              meetings: deletedMeetings,
                              color: Colors.red,
                              icon: Icons.delete,
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildMeetingSection({
  required String title,
  required List<MeetingData> meetings,
  required Color color,
  required IconData icon,
}) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withAlpha((0.08 * 255).round()),
          blurRadius: 16,
          offset: Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header với thiết kế tối giản
        Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withAlpha((0.1 * 255).round()),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: color.withAlpha((0.1 * 255).round()),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${meetings.length}',
                  style: TextStyle(
                    color: color,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Divider mỏng
        Container(
          height: 1,
          margin: const EdgeInsets.symmetric(horizontal: 20),
          color: Colors.grey[100],
        ),

        // Content
        Padding(
          padding: const EdgeInsets.all(20),
          child:
              meetings.isEmpty
                  ? Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Icon(
                              Icons.event_note_outlined,
                              size: 32,
                              color: Colors.grey[400],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Chưa có cuộc họp nào',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Các cuộc họp sẽ hiển thị tại đây',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  : Column(
                    children:
                        meetings.map((meeting) {
                          return _buildMeetingCard(meeting, color);
                        }).toList(),
                  ),
        ),
      ],
    ),
  );
}

Widget _buildMeetingCard(MeetingData meeting, Color color) {
  DateTime? meetingDate;
  try {
    meetingDate = DateTime.parse(meeting.startTime);
  } catch (e) {
    meetingDate = DateTime.now();
  }

  String dayOfWeek;
  try {
    dayOfWeek = DateFormat('EEEE', 'vi_VN').format(meetingDate);
  } catch (e) {
    dayOfWeek = DateFormat('EEEE').format(meetingDate);
  }

  String formattedDate = DateFormat('dd/MM/yyyy').format(meetingDate);
  String shortDate = DateFormat('dd/MM').format(meetingDate); // Ngày ngắn gọn
  String startTime = DateFormat('HH:mm').format(meetingDate);
  String leaderName = meeting.userChairMan.tenDayDu ?? 'Chưa xác định';

  return Container(
    margin: const EdgeInsets.only(bottom: 16),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey[200]!, width: 1),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withAlpha((0.02 * 255).round()),
          blurRadius: 4,
          offset: Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header với thời gian - Responsive layout
        LayoutBuilder(
          builder: (context, constraints) {
            // Nếu màn hình quá nhỏ, hiển thị theo chiều dọc
            if (constraints.maxWidth < 250) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Thời gian
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: color.withAlpha((0.1 * 255).round()),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.access_time, size: 14, color: color),
                        const SizedBox(width: 6),
                        Text(
                          startTime,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: color,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Ngày tháng
                  Text(
                    '$dayOfWeek, $shortDate',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              );
            } else {
              // Layout ngang bình thường
              return Row(
                children: [
                  // Thời gian - Không co giãn
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: color.withAlpha((0.1 * 255).round()),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.access_time, size: 14, color: color),
                        const SizedBox(width: 6),
                        Text(
                          startTime,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: color,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Ngày tháng - Có thể co giãn
                  Flexible(
                    child: Text(
                      constraints.maxWidth < 300
                          ? '$dayOfWeek, $shortDate' // Hiển thị ngắn gọn
                          : '$dayOfWeek, $formattedDate', // Hiển thị đầy đủ
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              );
            }
          },
        ),

        const SizedBox(height: 12),

        // Nội dung cuộc họp
        Text(
          meeting.title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
        ),

        if (meeting.content.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            meeting.content,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.4,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],

        const SizedBox(height: 12),

        // Thông tin lãnh đạo
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                Icons.person_outline,
                size: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                leaderName,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
