import 'package:flutter/material.dart';
import 'package:quanlyhop/data/models/calendar_detail_model.dart';

class ParticipantsTab extends StatelessWidget {
  final MeetingData meetingData;

  const ParticipantsTab({super.key, required this.meetingData});

  @override
  Widget build(BuildContext context) {
    // Phân loại danh sách thành viên
    final leaders =
        meetingData.meetingMemberInside
            ?.where((member) => member.position == 'Chủ trì')
            .toList() ??
        [];

    final delegates =
        meetingData.meetingMemberInside
            ?.where((member) => member.position == 'Đại biểu')
            .toList() ??
        [];

    final guests =
        meetingData.meetingMemberOutside
            ?.where((member) => member.position == 'Khách mời')
            .toList() ??
        [];

    final others = [
      ...meetingData.meetingMemberInside?.where(
            (member) =>
                member.position != 'Chủ trì' && member.position != 'Đại biểu',
          ) ??
          [],
      ...meetingData.meetingMemberOutside?.where(
            (member) => member.position != 'Khách mời',
          ) ??
          [],
    ];

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          // colors: [Colors.teal.shade50, Colors.grey.shade50],
          colors: [
            Colors.grey.withAlpha((255 * 0.1).round()),
            Colors.grey.withAlpha((255 * 0.1).round()),
          ],
        ),
      ),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header với tổng số thành viên
          _buildHeader(leaders, delegates, guests, others),
          const SizedBox(height: 24),

          // Lãnh đạo chủ trì
          _buildSection('Lãnh đạo chủ trì', leaders, Icons.workspace_premium),
          const SizedBox(height: 20),

          // Đại biểu tham dự
          _buildSection('Đại biểu tham dự', delegates, Icons.person_pin),
          const SizedBox(height: 20),

          // Khách mời khác
          _buildSection('Khách mời khác', guests, Icons.group_add),

          // Thành viên khác - chỉ hiển thị khi có dữ liệu
          if (others.isNotEmpty) ...[
            const SizedBox(height: 20),
            _buildSection('Thành viên khác', others, Icons.people_outline),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader(
    List<dynamic> leaders,
    List<dynamic> delegates,
    List<dynamic> guests,
    List<dynamic> others,
  ) {
    final totalMembers =
        leaders.length + delegates.length + guests.length + others.length;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.teal.shade500, Colors.teal.shade700],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.teal.withAlpha((255 * 0.1).round()),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha((255 * 0.2).round()),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.groups, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Danh sách thành viên',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Tổng cộng: $totalMembers người tham dự',
                  style: const TextStyle(color: Colors.white70, fontSize: 15),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<dynamic> members, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.teal.shade50, Colors.teal.shade100],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withAlpha((255 * 0.5).round()),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha((255 * 0.2).round()),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: const Color.fromARGB(255, 52, 52, 52),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color.fromARGB(255, 52, 52, 52),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${members.length}',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (members.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.info_outline, color: Colors.grey.shade400, size: 24),
                const SizedBox(width: 12),
                Text(
                  'Chưa có thành viên nào',
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 15,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          )
        else
          ...members.asMap().entries.map(
            (entry) =>
                _buildMemberCard(entry.key + 1, entry.value, Colors.blueGrey),
          ),
      ],
    );
  }

  Widget _buildMemberCard(int index, dynamic member, Color themeColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.teal.shade200.withAlpha((255 * 0.08).round()),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey),
      ),
      child: Column(
        children: [
          // Header của card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  themeColor.withAlpha((255 * 0.1).round()),
                  themeColor.withAlpha((255 * 0.3).round()),
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        themeColor,
                        themeColor.withAlpha((255 * 0.8).round()),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: themeColor.withAlpha((255 * 0.1).round()),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      '$index',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        member.fullName ?? 'Không rõ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ],
                  ),
                ),
                if (member.status != null) _buildStatusBadge(member.status!),
              ],
            ),
          ),
          // Thông tin chi tiết
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                if (member.organ != null && member.organ!.isNotEmpty)
                  _buildInfoRow(
                    Icons.business_outlined,
                    'Đơn vị công tác',
                    member.organ!,
                  ),
                if (member.chucVu != null && member.chucVu!.isNotEmpty)
                  _buildInfoRow(Icons.work_outline, 'Chức vụ', member.chucVu!),
                if (member.phone != null && member.phone!.isNotEmpty)
                  _buildInfoRow(
                    Icons.phone_outlined,
                    'Số điện thoại',
                    member.phone!,
                  ),
                if (member.email != null && member.email!.isNotEmpty)
                  _buildInfoRow(Icons.email_outlined, 'Email', member.email!),
                _buildNotificationRow(member),
                if (member.reason != null && member.reason!.isNotEmpty)
                  _buildInfoRow(Icons.note_outlined, 'Lý do', member.reason!),
              ],
            ),
          ),
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
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.teal.shade50,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, size: 16, color: Colors.teal.shade600),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 110,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade800),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationRow(dynamic member) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.teal.shade50,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              Icons.notifications_outlined,
              size: 16,
              color: Colors.teal.shade600,
            ),
          ),
          const SizedBox(width: 12),
          const SizedBox(
            width: 110,
            child: Text(
              'Thông báo:',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Wrap(
              spacing: 8, // khoảng cách giữa các phần tử
              runSpacing: 8, // khoảng cách giữa các dòng nếu xuống hàng
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color:
                        member.isSms == true
                            ? Colors.teal.shade100
                            : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color:
                          member.isSms == true
                              ? Colors.teal.shade300
                              : Colors.grey.shade300,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.sms_outlined,
                        size: 12,
                        color:
                            member.isSms == true
                                ? Colors.teal.shade700
                                : Colors.grey.shade600,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'SMS',
                        style: TextStyle(
                          fontSize: 11,
                          color:
                              member.isSms == true
                                  ? Colors.teal.shade700
                                  : Colors.grey.shade600,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color:
                        member.isEmail == true
                            ? Colors.teal.shade100
                            : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color:
                          member.isEmail == true
                              ? Colors.teal.shade300
                              : Colors.grey.shade300,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.email_outlined,
                        size: 12,
                        color:
                            member.isEmail == true
                                ? Colors.teal.shade700
                                : Colors.grey.shade600,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Email',
                        style: TextStyle(
                          fontSize: 11,
                          color:
                              member.isEmail == true
                                  ? Colors.teal.shade700
                                  : Colors.grey.shade600,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(int status) {
    String statusText;
    Color statusColor;
    IconData statusIcon;

    switch (status) {
      case 0:
        statusText = 'Chưa xác nhận';
        statusColor = Colors.amber.shade600;
        statusIcon = Icons.pending_outlined;
        break;
      case 1:
        statusText = 'Đã xác nhận';
        statusColor = Colors.green.shade600;
        statusIcon = Icons.check_circle_outline;
        break;
      case 2:
        statusText = 'Từ chối';
        statusColor = Colors.red.shade600;
        statusIcon = Icons.cancel_outlined;
        break;
      default:
        statusText = 'Không xác định';
        statusColor = Colors.grey.shade600;
        statusIcon = Icons.help_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: statusColor.withAlpha((255 * 0.1).round()),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withAlpha((255 * 0.3).round())),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusIcon, size: 14, color: statusColor),
          const SizedBox(width: 6),
          Text(
            statusText,
            style: TextStyle(
              fontSize: 12,
              color: statusColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
