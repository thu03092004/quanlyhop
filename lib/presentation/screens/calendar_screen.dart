import 'package:flutter/material.dart';

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
  }

  @override
  void dispose() {
    _animationController.dispose();
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

  // chuyển đến tuần trước
  void goToPreviousWeek() {
    setState(() {
      selectedDate = selectedDate.subtract(const Duration(days: 7));
    });
  }

  // trở về tuần hiện tại
  void goToCurrentWeek() {
    setState(() {
      selectedDate = DateTime.now();
    });
  }

  // chuyển sang tuần sau
  void goToNextWeek() {
    setState(() {
      selectedDate = selectedDate.add(const Duration(days: 7));
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

  @override
  Widget build(BuildContext context) {
    List<DateTime> weekDays = getCurrentWeekDays();
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
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children:
                            weekDays.map((date) {
                              bool isToday =
                                  DateTime.now().day == date.day &&
                                  DateTime.now().month == date.month &&
                                  DateTime.now().year == date.year;
                              return Container(
                                width: 120,
                                decoration: BoxDecoration(
                                  color:
                                      isToday
                                          ? Color(0xFF139364)
                                          : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 2,
                                  vertical: 8,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      getVietnameseDayName(date.weekday),
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color:
                                            isToday
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
                                            isToday
                                                ? Colors.white
                                                : Colors.grey[800],
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
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

          // nút ẩn/hiển thị
          Container(
            color: Colors.white,
            width: double.infinity,
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: toggleVisibility,
                  child: Container(
                    width: 28,
                    height: 28,
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
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
