import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:quanlyhop/data/models/calendar_model.dart';
import 'package:quanlyhop/data/services/calendar_service.dart';

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
    );
    _animation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(_animationController)..addListener(() {
      setState(() {});
    });
    weeks = getWeeksInYear(selectedDate.year);
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
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  String _formatTimeRange(DateTime? start, DateTime? end) {
    String startStr =
        start != null ? '${formatDate(start)} ${formatTime(start)}' : 'N/A';
    String endStr = end != null ? formatTime(end) : 'N/A';
    return '$startStr - $endStr';
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
                SizeTransition(
                  sizeFactor: Tween<double>(begin: 1.0, end: 0.0).animate(
                    CurvedAnimation(
                      parent: _animationController,
                      curve: Curves.easeInOut,
                    ),
                  ),
                  child: SizedBox(
                    height: 80,
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
                                    width: 120,
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
                                          getVietnameseDayName(date.weekday),
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                            color:
                                                isSelected
                                                    ? Colors.white
                                                    : Colors.grey[600],
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          formatDate(date),
                                          style: TextStyle(
                                            fontSize: 16,
                                            color:
                                                isSelected
                                                    ? Colors.white
                                                    : Colors.grey[800],
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
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
                Container(height: 1, color: Colors.grey[200]),
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
                      GestureDetector(
                        onTap: goToPreviousWeek,
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

                      // nút tuần sau
                      GestureDetector(
                        onTap: goToNextWeek,
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
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Navigation bar tuần
          // Divider
          Container(height: 8, color: Colors.grey[100]),

          // Dropdown + nút ẩn/hiển thị
          Container(
            color: Colors.white,
            width: double.infinity,
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
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
                GestureDetector(
                  onTap: toggleVisibility,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey[300]!, width: 1),
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withAlpha((0.2 * 255).round()),
                          spreadRadius: 1,
                          blurRadius: 2,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Icon(
                      isBodyVisible
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: Colors.grey[600],
                      size: 35,
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                    ? const Center(child: CircularProgressIndicator())
                    : errorMessage != null
                    ? Center(child: Text('Error: $errorMessage'))
                    : meetings.isEmpty
                    ? const Center(child: Text('Không có lịch họp'))
                    : ListView.builder(
                      itemCount: meetings.length,
                      itemBuilder: (context, index) {
                        final meeting = meetings[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: ListTile(
                            title: Text(
                              'Chủ trì: ${meeting.userChairMan?.tenDayDu ?? 'Không xác định'}',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Thời gian: ${_formatTimeRange(meeting.startTime, meeting.endTime)}',
                                ),
                                Text(
                                  'Nội dung: ${meeting.title ?? 'Không có tiêu đề'}\n${meeting.content ?? 'Không có nội dung'}',
                                ),
                                Text(
                                  'Địa điểm: ${meeting.place ?? 'Không xác định'}',
                                ),
                              ],
                            ),
                            onTap: () {},
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
