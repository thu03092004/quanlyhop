import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:quanlyhop/data/models/calendar_model.dart';
import 'package:quanlyhop/data/services/calendar_service.dart';
import 'package:quanlyhop/presentation/screens/calendar_detail_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen>
    with SingleTickerProviderStateMixin {
  DateTime selectedDate = DateTime.now();
  PageController pageController = PageController();

  bool isBodyVisible = true;
  late AnimationController _animationController;
  late Animation<double> _animation;
  String selectedValue = 'Lịch công tác đơn vị';

  // gọi API
  final CalendarService _calendarService = CalendarService();
  List<Meeting> allMeetings = []; // Lưu toàn bộ lịch họp trong tuần
  List<Meeting> meetings = []; // Lịch họp cho ngày được chọn
  bool isLoading = false;
  String? errorMessage;

  // Lưu trữ danh sách tuần để tái sử dụng
  late List<Map<String, dynamic>> weeks;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      value: 1.0, // Bắt đầu với giá trị 1.0 (hiển thị)
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_animationController)..addListener(() {
      setState(() {});
    });
    weeks = getWeeksInYear(selectedDate.year);
    isBodyVisible = false;
    _fetchMeetings();
  }

  @override
  void dispose() {
    _animationController.dispose();
    pageController.dispose();
    super.dispose();
  }

  // danh sách các ngày trong tuần hiện tại
  List<DateTime> getCurrentWeekDays() {
    DateTime now = selectedDate;
    int weekday = now.weekday;
    DateTime startOfWeek = now.subtract(Duration(days: weekday - 1));
    return List.generate(7, (index) => startOfWeek.add(Duration(days: index)));
  }

  String getVietnameseDayName(int weekday) {
    switch (weekday) {
      case 1:
        return 'Thứ hai';
      case 2:
        return 'Thứ ba';
      case 3:
        return 'Thứ tư';
      case 4:
        return 'Thứ năm';
      case 5:
        return 'Thứ sáu';
      case 6:
        return 'Thứ bảy';
      case 7:
        return 'Chủ nhật';
      default:
        return '';
    }
  }

  // Format ngày theo định dạng dd/MM/yyyy
  String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String formatTime(DateTime date) {
    return DateFormat('HH:mm').format(date);
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

    return 'Tuần ${getWeekNumber(startDate)} (${formatDate(startDate).substring(0, 5)} - ${formatDate(endDate).substring(0, 5)})';
  }

  // Tạo danh sách các tuần trong năm
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
            'Tuần ${weekNumber.toString().padLeft(2, '0')} (${formatDate(startOfWeek)} - ${formatDate(endOfWeek)})',
      });

      startOfWeek = startOfWeek.add(Duration(days: 7));
    }
    return weeks;
  }

  // chọn tuần từ dropdown ở title
  void selectWeek(DateTime startDate) {
    setState(() {
      selectedDate = startDate;
      _fetchMeetings();
    });
  }

  void toggleVisibility() {
    if (isBodyVisible) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
    setState(() {
      isBodyVisible = !isBodyVisible;
    });
  }

  // Map dropdown
  String getMeetingType() {
    switch (selectedValue) {
      case 'Lịch công tác Bộ':
        return 'ministry';
      case 'Lịch công tác đơn vị':
        return 'unit';
      case 'Lịch công tác cá nhân':
        return 'personal';
      default:
        return 'ministry';
    }
  }

  // Fetch meetings cho tuần được chọn
  Future<void> _fetchMeetings() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      List<DateTime> weekDays = getCurrentWeekDays();
      DateTime dateFrom = weekDays.first;
      DateTime dateTo = weekDays.last;

      final meetingsData = await _calendarService.getMeetings(
        type: getMeetingType(),
        dateFrom: dateFrom,
        dateTo: dateTo,
      );

      setState(() {
        allMeetings = meetingsData;
        meetings =
            meetingsData
                .where(
                  (meeting) =>
                      meeting.startTime?.day == selectedDate.day &&
                      meeting.startTime?.month == selectedDate.month &&
                      meeting.startTime?.year == selectedDate.year,
                )
                .toList();
        isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = e.toString();
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    List<DateTime> weekDays = getCurrentWeekDays();
    // List<Map<String, dynamic>> weeks = getWeeksInYear(selectedDate.year);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        elevation: 0, // không đổ bóng
        title: Row(
          mainAxisAlignment:
              MainAxisAlignment
                  .spaceBetween, // đảm bảo phân bố không gian hợp lý
          children: [
            // tiêu đề
            Flexible(
              flex: 1, // ưu tiên không gian cho tiêu đề
              child: FittedBox(
                fit: BoxFit.scaleDown, // thu nhỏ chữ nếu không đủ không gian
                child: Text(
                  'Lịch họp',
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
              flex: 1, // chia sẻ không gian với tiêu đề
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
                    mainAxisSize:
                        MainAxisSize.min, // chỉ chiếm không gian cần thiết
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
      body: Column(
        children: [
          // header với các ngày trong tuần
          Container(
            color: Colors.white,
            child: Column(
              children: [
                // SizeTransition(
                //   sizeFactor: Tween<double>(begin: 1.0, end: 0.0).animate(
                //     CurvedAnimation(
                //       parent: _animationController,
                //       curve: Curves.easeInOut,
                //     ),
                //   ),
                SizeTransition(
                  sizeFactor: _animation,
                  child: SizedBox(
                    height: 55,
                    child: Center(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children:
                              weekDays.map((date) {
                                bool isToday =
                                    DateTime.now().day == date.day &&
                                    DateTime.now().month == date.month &&
                                    DateTime.now().year == date.year;
                                bool isSelected =
                                    selectedDate.day == date.day &&
                                    selectedDate.month == date.month &&
                                    selectedDate.year == date.year;
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedDate =
                                          date; // cập nhật ngày được chọn
                                    });
                                    _fetchMeetings();
                                  },
                                  child: Container(
                                    width: 130,
                                    decoration: BoxDecoration(
                                      // color:
                                      //     isToday
                                      //         ? Color(0xFF139364)
                                      //         : Colors.transparent,
                                      color:
                                          isSelected
                                              ? Color(0xFF139364)
                                              // màu cho ngày được chọn
                                              : isToday
                                              ? Colors.teal.withAlpha(
                                                (255 * 0.5).round(),
                                              )
                                              : Colors.transparent,
                                      border:
                                          isSelected
                                              ? Border.all(
                                                color: Colors.teal,
                                                width: 2,
                                              ) // Viền cho ngày được chọn
                                              : null,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 2,
                                      vertical: 8,
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          '${getVietnameseDayName(date.weekday)} (${DateFormat('dd/MM').format(date)})',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                            color:
                                                isSelected
                                                    ? Colors.white
                                                    : Colors.grey[800],
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                        ),
                      ),
                    ),
                  ),
                ),
                // row các ngày trong tuần
                Container(height: 0.5, color: Colors.grey[300]),
              ],
            ),
          ),

          SizeTransition(
            sizeFactor: _animation,
            child: Container(
              color: Colors.white,
              width: double.infinity, // chiếm toàn bộ chiều ngang
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Center(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisSize: MainAxisSize.min, // chỉ rộng bằng nội dung
                    children: [
                      // nút tuần trước
                      // GestureDetector(
                      //   onTap: goToPreviousWeek,
                      //   child: Row(
                      //     children: [
                      //       Icon(
                      //         Icons.chevron_left,
                      //         color: Colors.grey[600],
                      //         size: 20,
                      //       ),
                      //       const SizedBox(width: 4),
                      //       Text(
                      //         'Tuần trước',
                      //         style: TextStyle(
                      //           color: Colors.black,
                      //           fontSize: 14,
                      //         ),
                      //       ),
                      //     ],
                      //   ),
                      // ),

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

                      // // nút tuần sau
                      // GestureDetector(
                      //   onTap: goToNextWeek,
                      //   child: Row(
                      //     children: [
                      //       Text(
                      //         'Tuần sau',
                      //         style: TextStyle(
                      //           color: Colors.black,
                      //           fontSize: 14,
                      //         ),
                      //       ),
                      //       const SizedBox(width: 4),
                      //       Icon(
                      //         Icons.chevron_right,
                      //         color: Colors.grey[600],
                      //         size: 20,
                      //       ),
                      //     ],
                      //   ),
                      // ),

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
            ),
          ),

          // Navigation bar tuần
          // Divider
          Container(height: 4, color: Colors.grey[100]),

          Flexible(
            fit: FlexFit.loose,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 700),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Dropdown + nút ẩn/hiển thị
                    Container(
                      color: Colors.white,
                      width: double.infinity,
                      padding: const EdgeInsets.only(
                        left: 16,
                        right: 16,
                        bottom: 8,
                      ),
                      child: Row(
                        // mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Center(
                              child: DropdownButton<String>(
                                value: selectedValue,
                                dropdownColor: Colors.white,
                                items:
                                    [
                                      'Lịch công tác Bộ',
                                      'Lịch công tác đơn vị',
                                      'Lịch công tác cá nhân',
                                    ].map((String value) {
                                      return DropdownMenuItem(
                                        value: value,
                                        child: Text(value),
                                      );
                                    }).toList(),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    selectedValue = newValue!;
                                    _fetchMeetings();
                                  });
                                },
                              ),
                            ),
                          ),
                          Transform.translate(
                            offset: const Offset(
                              0,
                              -10,
                            ), // Dịch chuyển lên trên 8px
                            child: GestureDetector(
                              onTap: toggleVisibility,
                              child: SizedBox(
                                width: 50,
                                height: 50,
                                child: Icon(
                                  isBodyVisible
                                      ? Icons.vertical_align_bottom
                                      : Icons.vertical_align_top,
                                  color: Colors.grey[600],
                                  size: 50,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // hiển thị ngày đang được chọn
                    Container(
                      color: Colors.white,
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Text(
                        'Ngày: ${getVietnameseDayName(selectedDate.weekday)}, ${formatDate(selectedDate)}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[800],
                        ),
                      ),
                    ),

                    // hiển thị Meetings list
                    Expanded(
                      child:
                          isLoading
                              ? const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircularProgressIndicator(
                                      strokeWidth: 3,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.blue,
                                      ),
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      'Đang tải dữ liệu...',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                              : errorMessage != null
                              ? Center(
                                child: Container(
                                  padding: const EdgeInsets.all(24),
                                  margin: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade50,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.red.shade200,
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.error_outline,
                                        color: Colors.red.shade600,
                                        size: 48,
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'Đã xảy ra lỗi',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.red.shade800,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      // Text(
                                      //   errorMessage!,
                                      //   style: TextStyle(
                                      //     fontSize: 14,
                                      //     color: Colors.red.shade600,
                                      //   ),
                                      //   textAlign: TextAlign.center,
                                      // ),
                                      Text(
                                        "Vui lòng đăng nhập lại!",
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.red.shade600,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              )
                              : meetings.isEmpty
                              ? Center(
                                child: Container(
                                  padding: const EdgeInsets.all(32),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.event_busy,
                                        size: 64,
                                        color: Colors.grey.shade400,
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'Không có lịch họp',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Hiện tại chưa có cuộc họp nào được lên lịch',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey.shade500,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              )
                              : RefreshIndicator(
                                onRefresh: () async {
                                  // logic refresh ở đây
                                  _fetchMeetings();
                                },
                                child: ListView.builder(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  itemCount: meetings.length,
                                  itemBuilder: (context, index) {
                                    final meeting = meetings[index];
                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 12),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withAlpha(
                                              (0.2 * 255).toInt(),
                                            ),
                                            spreadRadius: 0.5,
                                            blurRadius: 4,
                                            offset: const Offset(0, 1),
                                          ),
                                        ],
                                      ),
                                      child: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          onTap: () {
                                            // Xử lý khi tap vào item
                                            debugPrint(
                                              'ID lịch1: ${meeting.id}',
                                            );
                                            if (meeting.id != null) {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder:
                                                      (context) =>
                                                          CalendarDetailScreen(
                                                            meetingId:
                                                                meeting.id!,
                                                          ),
                                                ),
                                              );
                                            }
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.all(16),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                // Header với icon và chủ trì
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      flex: 2,
                                                      child: Row(
                                                        children: [
                                                          Container(
                                                            padding:
                                                                const EdgeInsets.all(
                                                                  6,
                                                                ),
                                                            decoration: BoxDecoration(
                                                              color:
                                                                  Colors
                                                                      .blue
                                                                      .shade50,
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    6,
                                                                  ),
                                                            ),
                                                            child: Icon(
                                                              Icons
                                                                  .person_outline,
                                                              color:
                                                                  Colors
                                                                      .blue
                                                                      .shade600,
                                                              size: 18,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            width: 8,
                                                          ),
                                                          Expanded(
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Text(
                                                                  'Lãnh đạo/Chủ trì',
                                                                  style: TextStyle(
                                                                    fontSize:
                                                                        11,
                                                                    color:
                                                                        Colors
                                                                            .grey
                                                                            .shade600,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                  ),
                                                                ),

                                                                Text(
                                                                  '${meeting.userChairMan?.chucVu?.ten ?? ''} ${meeting.userChairMan?.tenDayDu ?? 'Không xác định'}',
                                                                  style: const TextStyle(
                                                                    fontSize:
                                                                        14,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color:
                                                                        Colors
                                                                            .black87,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),

                                                    // Thời gian + Trạng thái
                                                    Expanded(
                                                      flex: 1,
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .end,
                                                        children: [
                                                          Text(
                                                            formatTime(
                                                              meeting.startTime ??
                                                                  DateTime.now(),
                                                            ),
                                                            style: const TextStyle(
                                                              fontSize: 16,
                                                              color:
                                                                  Colors
                                                                      .black87,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                            ),
                                                          ),

                                                          if (meeting.status ==
                                                                  2 ||
                                                              meeting.status ==
                                                                  3)
                                                            Container(
                                                              padding:
                                                                  const EdgeInsets.symmetric(
                                                                    horizontal:
                                                                        6,
                                                                    vertical: 2,
                                                                  ),
                                                              decoration: BoxDecoration(
                                                                color:
                                                                    meeting.status ==
                                                                            2
                                                                        ? Colors
                                                                            .green
                                                                            .shade50
                                                                        : Colors
                                                                            .red
                                                                            .shade50,
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      4,
                                                                    ),
                                                              ),
                                                              child: Text(
                                                                meeting.status ==
                                                                        2
                                                                    ? 'Đang trực tuyến'
                                                                    : 'Đã kết thúc',
                                                                style: TextStyle(
                                                                  fontSize: 10,
                                                                  color:
                                                                      meeting.status ==
                                                                              2
                                                                          ? Colors
                                                                              .green
                                                                              .shade600
                                                                          : Colors
                                                                              .red
                                                                              .shade600,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                ),
                                                              ),
                                                            ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),

                                                const SizedBox(height: 12),

                                                // Nội dung chính - hiển thị trên 1 hàng với icon nhỏ
                                                Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                            6,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color:
                                                            Colors
                                                                .indigo
                                                                .shade50,
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              6,
                                                            ),
                                                      ),
                                                      child: Icon(
                                                        Icons.event_note,
                                                        color:
                                                            Colors
                                                                .indigo
                                                                .shade600,
                                                        size: 18,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            meeting.title ??
                                                                'Không có tiêu đề',
                                                            style: const TextStyle(
                                                              fontSize: 15,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color:
                                                                  Colors
                                                                      .black87,
                                                            ),
                                                            maxLines: 2,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),

                                                          if (meeting.content !=
                                                                  null &&
                                                              meeting
                                                                  .content!
                                                                  .isNotEmpty) ...[
                                                            const SizedBox(
                                                              height: 4,
                                                            ),

                                                            Text(
                                                              meeting.content!,
                                                              style: TextStyle(
                                                                fontSize: 13,
                                                                color:
                                                                    Colors
                                                                        .grey
                                                                        .shade700,
                                                                height: 1.3,
                                                              ),
                                                              maxLines: 2,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                          ],
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),

                                                const SizedBox(height: 12),

                                                // Footer compact - Địa điểm và action button trên cùng 1 hàng
                                                Row(
                                                  children: [
                                                    // Địa điểm
                                                    Expanded(
                                                      child: Row(
                                                        children: [
                                                          Icon(
                                                            Icons
                                                                .location_on_outlined,
                                                            color:
                                                                Colors
                                                                    .grey
                                                                    .shade600,
                                                            size: 16,
                                                          ),
                                                          const SizedBox(
                                                            width: 6,
                                                          ),
                                                          Expanded(
                                                            child: Text(
                                                              meeting.place ??
                                                                  'Không xác định',
                                                              style: TextStyle(
                                                                fontSize: 13,
                                                                color:
                                                                    Colors
                                                                        .grey
                                                                        .shade700,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                              ),
                                                              maxLines: 1,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),

                                                    // Action button
                                                    TextButton.icon(
                                                      onPressed: () {
                                                        debugPrint(
                                                          'ID lịch2: ${meeting.id}',
                                                        );
                                                        if (meeting.id !=
                                                            null) {
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder:
                                                                  (
                                                                    context,
                                                                  ) => CalendarDetailScreen(
                                                                    meetingId:
                                                                        meeting
                                                                            .id!,
                                                                  ),
                                                            ),
                                                          );
                                                        } else {
                                                          ScaffoldMessenger.of(
                                                            context,
                                                          ).showSnackBar(
                                                            const SnackBar(
                                                              content: Text(
                                                                'Không tìm thấy ID cuộc họp',
                                                              ),
                                                            ),
                                                          );
                                                        }
                                                      },
                                                      icon: const Icon(
                                                        Icons.arrow_forward_ios,
                                                        size: 12,
                                                      ),
                                                      label: const Text(
                                                        'Chi tiết',
                                                      ),
                                                      style: TextButton.styleFrom(
                                                        foregroundColor:
                                                            Colors
                                                                .blue
                                                                .shade600,
                                                        textStyle:
                                                            const TextStyle(
                                                              fontSize: 12,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                            ),
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                              horizontal: 8,
                                                              vertical: 4,
                                                            ),
                                                        minimumSize: Size.zero,
                                                        tapTargetSize:
                                                            MaterialTapTargetSize
                                                                .shrinkWrap,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
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
    );
  }
}
