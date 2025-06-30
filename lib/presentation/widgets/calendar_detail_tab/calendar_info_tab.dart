// Thông tin cuộc họp
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:quanlyhop/data/models/calendar_detail_model.dart';

class CalendarInfoTab extends StatelessWidget {
  final MeetingData meetingData;
  const CalendarInfoTab({super.key, required this.meetingData});

  @override
  Widget build(BuildContext context) {
    // Định dạng thời gian
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final startTime = dateFormat.format(DateTime.parse(meetingData.startTime));
    final endTime = dateFormat.format(DateTime.parse(meetingData.endTime));

    // Tính thống kê thành phần tham dự
    final totalInvited =
        (meetingData.meetingMemberInside?.length ?? 0) +
        (meetingData.meetingMemberOutside?.length ?? 0);

    final totalAttended =
        (meetingData.meetingMemberInside
                ?.where((m) => m.online == true && m.activated == true)
                .length ??
            0) +
        (meetingData.meetingMemberOutside
                ?.where((m) => m.online == true && m.activated == true)
                .length ??
            0);

    final totalAbsent = totalInvited - totalAttended;

    // xác định tình trạng
    String statusText;
    Color statusColor;
    IconData statusIcon;

    if (meetingData.isCancel) {
      statusText = 'Đã hủy';
      statusColor = Colors.red;
      statusIcon = Icons.cancel;
    } else if (meetingData.start) {
      statusText = 'Đang diễn ra';
      statusColor = Colors.green;
      statusIcon = Icons.play_circle_fill;
    } else if (DateTime.parse(meetingData.startTime).isAfter(DateTime.now())) {
      statusText = 'Sắp diễn ra';
      statusColor = Colors.orange;
      statusIcon = Icons.schedule;
    } else {
      statusText = 'Đã kết thúc';
      statusColor = Colors.blueGrey;
      statusIcon = Icons.check_circle;
    }

    // đường dẫn tới cuộc họp
    String url = 'https://quanlyhop.mae.gov.vn/phong-hop/${meetingData.id}';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tên lịch họp + Trạng thái
          _buildHeaderCard(statusText, statusColor, statusIcon),

          const SizedBox(height: 16),

          // Thông tin chi tiết cuộc họp
          _buildInfoCard('Thông tin cuộc họp', [
            _buildInfoRow(Icons.event, 'Tên cuộc họp', meetingData.title),

            _buildInfoRow(
              Icons.access_time,
              'Thời gian',
              '$startTime - $endTime',
            ),

            _buildInfoRow(Icons.description, 'Nội dung', meetingData.content),

            _buildInfoRow(
              Icons.place,
              'Địa điểm',
              meetingData.place ?? 'Chưa có',
            ),

            _buildInfoRow(
              Icons.person,
              'Lãnh đạo/Chủ trì',
              meetingData.userChairMan.tenDayDu ?? "Không có",
            ),

            _buildInfoRow(
              Icons.support_agent,
              'Chuẩn bị',
              meetingData.userShareRole?.tenDangNhap ?? 'Chưa có',
            ),

            _buildInfoRow(
              Icons.video_call,
              'Phòng họp trực tuyến',
              meetingData.roomName,
            ),
          ]),

          const SizedBox(height: 16),

          // Đường dẫn và QRCode
          _buildLinkCard(context, url),

          const SizedBox(height: 12),

          // Thống kê thành phần tham dự
          _buildStatsCard(totalInvited, totalAttended, totalAbsent),

          const SizedBox(height: 16),

          // Thông tin khác
          _buildSupportCard(),
        ],
      ),
    );
  }

  Widget _buildHeaderCard(
    String statusText,
    Color statusColor,
    IconData statusIcon,
  ) {
    return Card(
      elevation: 4, // độ nổi của Card
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [Colors.teal.shade50, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              meetingData.title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: statusColor.withAlpha((0.1 * 255).round()),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: statusColor.withAlpha((0.3 * 255).round()),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(statusIcon, color: statusColor, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.1 * 255).round()), // màu bóng
            // blurRadius: 5, // độ mờ của bóng
            spreadRadius: 1, // độ lan rộng
            offset: Offset(0, 0), // đổ bóng đều các hướng
          ),
        ],
      ),
      margin: const EdgeInsets.all(8), // đảm bảo không bị cắt bóng
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.teal.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.teal, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color.fromARGB(255, 91, 90, 90),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLinkCard(BuildContext context, String url) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.1 * 255).round()),
            // blurRadius: 5,
            spreadRadius: 1,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tham gia cuộc họp',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 16),

          // Đường dẫn
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    url,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: url));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Row(
                          children: [
                            Icon(Icons.check_circle, color: Colors.white),
                            SizedBox(width: 8),
                            Text('Đã sao chép đường dẫn!'),
                          ],
                        ),
                        backgroundColor: Colors.green,
                        duration: const Duration(seconds: 2),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.copy,
                    color: Color.fromARGB(255, 76, 76, 76),
                  ),
                  tooltip: 'Sao chép đường dẫn',
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // QR Code
          Center(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withAlpha((0.3 * 255).round()),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  QrImageView(data: url, version: QrVersions.auto, size: 150.0),
                  const SizedBox(height: 8),
                  const Text(
                    'Quét mã QR để tham gia',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard(int totalInvited, int totalAttended, int totalAbsent) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.1 * 255).round()),
            spreadRadius: 1,
            offset: Offset(0, 0),
          ),
        ],
      ),
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Thống kê thành phần tham dự',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Được mời',
                  totalInvited.toString(),
                  Colors.blue,
                  Icons.people,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Tham dự',
                  totalAttended.toString(),
                  Colors.green,
                  Icons.check_circle,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Vắng mặt',
                  totalAbsent.toString(),
                  Colors.orange,
                  Icons.cancel,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: color.withAlpha((0.1 * 255).round()),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color.withAlpha((0.8 * 255).round()),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSupportCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.1 * 255).round()),
            spreadRadius: 1,
            offset: Offset(0, 0),
          ),
        ],
      ),
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Đội ngũ hỗ trợ',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          _buildInfoRow(
            Icons.support_agent,
            'Chuyên viên hỗ trợ',
            meetingData.userSupport?.tenDayDu ?? "Chưa có",
          ),
          _buildInfoRow(
            Icons.build,
            'Kỹ thuật viên',
            meetingData.userTechnician?.tenDayDu ?? "Chưa có",
          ),
        ],
      ),
    );
  }
}
