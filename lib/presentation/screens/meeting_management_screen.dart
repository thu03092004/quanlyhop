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
    _initializeAndFetch();
    // _fetchMeetings();
    // _initializeLocale();
    weeks = getWeeksInYear(selectedDate.year);
    // _checkPermissions();
  }

  Future<void> _initializeAndFetch() async {
    // Chờ cả hai tác vụ hoàn tất
    await Future.wait([_initializeLocale(), _checkPermissions()]);
    // Sau khi hoàn tất, gọi _fetchMeetings
    await _fetchMeetings();
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
    if (!_hasPermission) {
      debugPrint('Không có quyền truy cập lịch');
      return;
    }
    if (!_isLocaleInitialized) {
      debugPrint('Locale chưa được khởi tạo');
      return;
    }

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
    });
    _fetchMeetings();
  }

  // chuyển sang tuần sau
  void goToNextWeek() {
    setState(() {
      selectedDate = selectedDate.add(const Duration(days: 7));
      _fetchMeetings();
    });
  }

  // snackBar
  void _showSuccessSnackBar(String message, {Color color = Colors.green}) {
    if (!mounted) return;

    final messenger = ScaffoldMessenger.of(context);

    // Ẩn snackbar cũ nếu có
    messenger.hideCurrentSnackBar();

    messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
        action: SnackBarAction(
          label: 'Đóng',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;

    final messenger = ScaffoldMessenger.of(context);

    // Ẩn snackbar cũ nếu có
    messenger.hideCurrentSnackBar();

    messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'Đóng',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  Future<void> _approveMeeting(String meetingId) async {
    try {
      setState(() {
        _isLoading = true;
      });

      await _meetingService.approveMeetingSchedule(meetingId);

      // Hiển thị thông báo thành công
      if (mounted) {
        _showSuccessSnackBar('Duyệt lịch họp thành công');
      }

      // Tải lại dữ liệu
      await _fetchMeetings();
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Lỗi khi duyệt lịch họp: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _unapproveMeeting(String meetingId) async {
    try {
      setState(() {
        _isLoading = true;
      });

      await _meetingService.unapproveMeetingSchedule(meetingId);

      if (mounted) {
        _showSuccessSnackBar(
          'Hủy duyệt lịch họp thành công',
          color: Colors.orange,
        );
      }

      await _fetchMeetings();
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Lỗi khi hủy duyệt lịch họp: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _startMeeting(String meetingId) async {
    try {
      setState(() {
        _isLoading = true;
      });

      await _meetingService.startMeeting(meetingId);
      await _meetingService.changeStatus(meetingId, 2);

      if (mounted) {
        _showSuccessSnackBar('Bắt đầu lịch họp thành công');
      }

      await _fetchMeetings();
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Lỗi khi bắt đầu lịch họp - screen: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _endMeeting(String meetingId) async {
    try {
      setState(() {
        _isLoading = true;
      });

      await _meetingService.endMeeting(meetingId);
      await _meetingService.changeStatus(meetingId, 3);

      if (mounted) {
        _showSuccessSnackBar(
          'Kết thúc lịch họp thành công',
          color: Colors.orange,
        );
      }

      await _fetchMeetings();
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Lỗi khi kết thúc lịch họp: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildMeetingSection({
    required String title,
    required List<MeetingData> meetings,
    required Color color,
    required IconData icon,
    required String sectionType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha((0.2 * 255).toInt()),
            spreadRadius: 0.5,
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header tối giản
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, color: color, size: 18),
                const SizedBox(width: 8),
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
                Text(
                  '${meetings.length}',
                  style: TextStyle(
                    color: color,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // Divider mỏng
          Container(
            height: 1,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            color: Colors.grey[200],
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child:
                meetings.isEmpty
                    ? Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.event_note_outlined,
                            size: 24,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Chưa có cuộc họp',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    )
                    : Column(
                      children:
                          meetings.map((meeting) {
                            return _buildMeetingCard(
                              meeting,
                              color,
                              sectionType,
                            );
                          }).toList(),
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildMeetingCard(
    MeetingData meeting,
    Color color,
    String sectionType,
  ) {
    DateTime? meetingDate;
    try {
      meetingDate = DateTime.parse(meeting.startTime);
    } catch (e) {
      meetingDate = DateTime.now();
    }

    String dayOfWeek = DateFormat('EEEE', 'vi_VN').format(meetingDate);
    String shortDate = DateFormat('dd/MM').format(meetingDate);
    String startTime = DateFormat('HH:mm').format(meetingDate);
    String leaderName = meeting.userChairMan.tenDayDu ?? 'Chưa xác định';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header thời gian
          Row(
            children: [
              Text(
                startTime,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '$dayOfWeek, $shortDate',
                  style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Tiêu đề cuộc họp
          Text(
            meeting.title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),

          const SizedBox(height: 6),

          // Thông tin lãnh đạo
          Text(
            leaderName,
            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 8),

          // Action buttons
          _buildActionButtons(meeting, sectionType),
        ],
      ),
    );
  }

  Widget _buildActionButtons(MeetingData meeting, String sectionType) {
    List<Widget> buttons = [];

    if (sectionType == 'pending' && meeting.status == 0) {
      // Nút Duyệt cho tab "Đang cập nhật"
      buttons.add(
        _buildActionButton(
          icon: Icons.check,
          label: 'Duyệt',
          color: Colors.green,
          onPressed: () => _approveMeeting(meeting.id),
        ),
      );
    }

    if (sectionType == 'approved' &&
        meeting.status == 2 &&
        meeting.start == false) {
      // Nút Hủy duyệt cho tab "Đã duyệt"
      buttons.add(
        _buildActionButton(
          icon: Icons.cancel,
          label: 'Hủy duyệt',
          color: Colors.red,
          onPressed: () => _unapproveMeeting(meeting.id),
        ),
      );
    }

    // Nút Bắt đầu/Kết thúc cho tab "Đã duyệt"
    if (sectionType == 'approved' && meeting.start == false) {
      buttons.add(
        _buildActionButton(
          icon: Icons.play_arrow,
          label: 'Bắt đầu',
          color: Colors.blue,
          onPressed: () => _startMeeting(meeting.id),
        ),
      );
    } else if (sectionType == 'approved' && meeting.start == true) {
      buttons.add(
        _buildActionButton(
          icon: Icons.stop,
          label: 'Kết thúc',
          color: Colors.orange,
          onPressed: () => _endMeeting(meeting.id),
        ),
      );
    }

    if (buttons.isEmpty) return const SizedBox.shrink();

    return Wrap(spacing: 6, runSpacing: 6, children: buttons);
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withAlpha((255 * 0.2).round())),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
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
                          color: Colors.orange[50],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.warning_amber,
                          size: 48,
                          color: Colors.orange[400],
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
      backgroundColor: Colors.grey.shade50,
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

                    const SizedBox(width: 2),

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

                    const SizedBox(width: 2),

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
            Flexible(
              fit: FlexFit.loose,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 700),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
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
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                    ),
                                    children: [
                                      const SizedBox(height: 10),
                                      // Lịch đang cập nhật
                                      _buildMeetingSection(
                                        title: 'Đang cập nhật',
                                        meetings: pendingMeetings,
                                        color: Colors.orange,
                                        icon: Icons.update,
                                        sectionType: 'pending',
                                      ),
                                      const SizedBox(height: 20),

                                      // Lịch đã duyệt
                                      _buildMeetingSection(
                                        title: 'Đã duyệt',
                                        meetings: approvedMeetings,
                                        color: Colors.green,
                                        icon: Icons.check_circle,
                                        sectionType: 'approved',
                                      ),
                                      const SizedBox(height: 20),

                                      // Lịch đã xóa
                                      _buildMeetingSection(
                                        title: 'Đã xóa',
                                        meetings: deletedMeetings,
                                        color: Colors.red,
                                        icon: Icons.delete,
                                        sectionType: 'deleted',
                                      ),
                                      const SizedBox(height: 20),
                                    ],
                                  ),
                                ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
