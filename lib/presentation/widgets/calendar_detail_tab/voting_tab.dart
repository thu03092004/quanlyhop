import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:quanlyhop/data/models/calendar_detail_model.dart';
import 'dart:convert';

import 'package:quanlyhop/data/services/auth_manager.dart';

class VotingTab extends StatelessWidget {
  final MeetingData meetingData;

  const VotingTab({super.key, required this.meetingData});

  // Lấy currentUserId từ AuthManager
  int? get _currentUserId => AuthManager.instance.currentUser?.data.id;

  // Hàm kiểm tra xem người dùng có quyền xem phiếu bảo mật không
  bool _hasAccessToSecretVote(MeetingVote vote) {
    if (vote.type == true) return true; // Phiếu công khai, luôn hiển thị
    if (_currentUserId == null) {
      return false; // Không có user ID, không hiển thị phiếu bảo mật
    }

    try {
      // Kiểm tra trong listMember
      final List<dynamic> members = jsonDecode(vote.listMember ?? '[]');
      bool inListMember = members.any((member) {
        final memberMap = member as Map<String, dynamic>;
        // Kiểm tra cả 'userId' và 'UserId'
        final memberId =
            memberMap['userId']?.toString() ?? memberMap['UserId']?.toString();
        return memberId != null && memberId == _currentUserId.toString();
      });

      // Kiểm tra trong userCreatedBy của meetingVoted
      bool inUserCreatedBy = (vote.meetingVoted ?? []).any((voted) {
        final userCreatedBy = voted.userCreatedBy;
        return userCreatedBy != null &&
            userCreatedBy.id.toString() == _currentUserId.toString();
      });

      // Hiển thị nếu userId nằm trong listMember hoặc userCreatedBy
      return inListMember || inUserCreatedBy;
    } catch (e) {
      return false; // Nếu parse JSON thất bại, không hiển thị
    }
  }

  // Lấy ngày từ timestamp
  String _getDateOnly(int? timestamp) {
    if (timestamp == null) return '';
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateFormat('dd/MM/yyyy').format(date);
  }

  // Lấy giờ từ timestamp
  String _getTimeOnly(int? timestamp) {
    if (timestamp == null) return '';
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateFormat('HH:mm:ss').format(date);
  }

  // Lọc và sắp xếp các biểu quyết theo trạng thái và thời gian (mới nhất đến cũ nhất)
  List<MeetingVote> _getOngoingVotes() {
    final votes =
        meetingData.meetingVotes
            ?.where(
              (vote) =>
                  (vote.end == 0 || vote.end == 1) &&
                  _hasAccessToSecretVote(vote),
            )
            .toList() ??
        [];
    // Sắp xếp theo dateTime từ mới nhất đến cũ nhất
    votes.sort((a, b) => (b.dateTime ?? 0).compareTo(a.dateTime ?? 0));
    return votes;
  }

  List<MeetingVote> _getCompletedVotes() {
    final votes =
        meetingData.meetingVotes
            ?.where((vote) => vote.end == 2 && _hasAccessToSecretVote(vote))
            .toList() ??
        [];
    // Sắp xếp theo dateTime từ cũ nhất đến mới nhất
    votes.sort((a, b) => (a.dateTime ?? 0).compareTo(b.dateTime ?? 0));
    return votes;
  }

  // Lấy màu trạng thái
  Color _getStatusColor(MeetingVote vote) {
    if (vote.end == 0) return Colors.orange; // Chưa bắt đầu
    if (vote.end == 1) return Colors.green; // Đang diễn ra
    return Colors.grey; // Đã kết thúc
  }

  // Lấy text trạng thái
  String _getStatusText(MeetingVote vote) {
    if (vote.end == 0) return 'Chưa bắt đầu';
    if (vote.end == 1) return 'Đang diễn ra';
    return 'Đã kết thúc';
  }

  // Widget hiển thị danh sách biểu quyết với giao diện cải thiện
  Widget _buildVoteList(List<MeetingVote> votes) {
    if (votes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.how_to_vote, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Không có biểu quyết nào',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: votes.length,
      itemBuilder: (context, index) {
        final vote = votes[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withAlpha((255 * 0.1).round()),
                spreadRadius: 1,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              // Xử lý khi tap vào card
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header với tiêu đề và trạng thái
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          vote.title ?? 'Không có tiêu đề',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2C3E50),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(
                            vote,
                          ).withAlpha((255 * 0.1).round()),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _getStatusColor(
                              vote,
                            ).withAlpha((255 * 0.3).round()),
                          ),
                        ),
                        child: Text(
                          _getStatusText(vote),
                          style: TextStyle(
                            color: _getStatusColor(vote),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Thông tin chi tiết
                  Row(
                    children: [
                      // Thời gian
                      Row(
                        children: [
                          Icon(
                            Icons.schedule,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 6),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _getTimeOnly(vote.dateTime),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF34495E),
                                ),
                              ),
                              Text(
                                _getDateOnly(vote.dateTime),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const Spacer(),

                      // Loại phiếu
                      Row(
                        children: [
                          Icon(
                            vote.type == true ? Icons.visibility : Icons.lock,
                            size: 16,
                            color:
                                vote.type == true
                                    ? Colors.green
                                    : Colors.orange,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            vote.type == true ? 'Công khai' : 'Bảo mật',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color:
                                  vote.type == true
                                      ? Colors.green
                                      : Colors.orange,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(width: 4),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Thời lượng
                  Row(
                    children: [
                      Icon(Icons.timer, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 6),
                      Text(
                        'Thời lượng: ${vote.time ?? 0} giây',
                        style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                      ),
                    ],
                  ),

                  // Số lượng phiếu bầu (nếu có)
                  if (vote.meetingVoted?.isNotEmpty == true) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.how_to_vote,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Số phiếu: ${vote.meetingVoted?.length ?? 0}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
                    indicatorSize: TabBarIndicatorSize.tab, // Thêm dòng này
                    indicatorPadding: const EdgeInsets.all(2),
                    indicatorWeight: 0,
                    dividerHeight: 0,
                    splashFactory:
                        NoSplash.splashFactory, // Loại bỏ hiệu ứng splash
                    overlayColor: WidgetStateProperty.all(
                      Colors.transparent,
                    ), // Loại bỏ overlay
                    tabs: const [
                      Tab(text: 'Đang biểu quyết'),
                      Tab(text: 'Đã biểu quyết'),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        body: TabBarView(
          children: [
            _buildVoteList(_getOngoingVotes()),
            _buildVoteList(_getCompletedVotes()),
          ],
        ),
      ),
    );
  }
}
