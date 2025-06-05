import 'package:flutter/material.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime selectedDate = DateTime.now();
  PageController pageController = PageController();

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        elevation: 0, // không đổ bóng
        title: Center(
          child: Text(
            'Lịch họp',
            style: TextStyle(
              color: Colors.white,
              fontSize: Theme.of(context).textTheme.titleLarge?.fontSize ?? 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
      body: Center(
        child: Text(
          'Chức năng lịch họp sẽ được cập nhật trong tương lai.',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
    );
  }
}
