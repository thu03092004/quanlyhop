import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:quanlyhop/data/models/calendar_detail_model.dart';
import 'dart:convert';

import 'package:quanlyhop/data/services/auth_manager.dart';
import 'package:quanlyhop/data/services/calendar_service.dart';

class VotingTab extends StatefulWidget {
  final MeetingData meetingData;

  const VotingTab({super.key, required this.meetingData});

  @override
  State<VotingTab> createState() => _VotingTabState();
}

class _VotingTabState extends State<VotingTab> {
  final CalendarService _calendarService = CalendarService();
  late MeetingData _meetingData;
  bool _isLoading = false;

  // Lấy currentUserId từ AuthManager
  int? get _currentUserId => AuthManager.instance.currentUser?.data.id;

  @override
  void initState() {
    super.initState();
    _meetingData = widget.meetingData;
  }

  // hàm refresh meetingData
  Future<void> _refreshMeetingData() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final updateMeetingData = await _calendarService.getCalendarDetail(
        _meetingData.id.toString(),
      );
      if (mounted) {
        setState(() {
          _meetingData = updateMeetingData.data;
        });
      }
    } catch (e) {
      _showSnackBar('Lỗi khi tải dữ liệu: $e', backgroundColor: Colors.red);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

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
        _meetingData.meetingVotes
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
        _meetingData.meetingVotes
            ?.where((vote) => vote.end == 2 && _hasAccessToSecretVote(vote))
            .toList() ??
        [];
    // Sắp xếp theo dateTime từ mới nhất đến cũ nhất
    votes.sort((a, b) => (b.dateTime ?? 0).compareTo(a.dateTime ?? 0));
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

  // Chuyển thời lượng họp time từ giây sang hh:mm:ss
  String _formatDuration(int? seconds) {
    if (seconds == null || seconds == 0) return '00:00:00';
    final duration = Duration(seconds: seconds);
    return [
      duration.inHours,
      duration.inMinutes % 60,
      duration.inSeconds % 60,
    ].map((e) => e.toString().padLeft(2, '0')).join(':');
  }

  // Hàm hiển thị snackbar
  void _showSnackBar(String message, {Color? backgroundColor}) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: backgroundColor ?? Colors.green,
        ),
      );
    }
  }

  // Widget hiển thị danh sách biểu quyết
  Widget _buildVoteList(List<MeetingVote> votes) {
    if (votes.isEmpty) {
      return RefreshIndicator(
        onRefresh: _refreshMeetingData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: Center(
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
                  const SizedBox(height: 8),
                  Text(
                    'Vuốt xuống để tải lại',
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshMeetingData,
      child: ListView.builder(
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
                if (vote.end == 2) {
                  _showResultDialog(context, vote);
                }
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
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[700],
                          ),
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

                    // Nút điều khiển (Bắt đầu, Dừng lại, Xem kết quả)
                    const SizedBox(height: 12),

                    Align(
                      alignment: Alignment.centerRight,
                      child: Wrap(
                        spacing: 8, // Khoảng cách giữa các nút
                        children: [
                          // Nút "Bắt đầu" cho end == 0
                          if (vote.end == 0)
                            ElevatedButton(
                              onPressed: () async {
                                try {
                                  await _calendarService.updateMeetingVoteEnd(
                                    meetingVoteId: vote.id.toString(),
                                    isStart: true,
                                  );

                                  _showSnackBar(
                                    'Bắt đầu biểu quyết thành công',
                                  );

                                  // Refresh meeting data
                                  await _refreshMeetingData();
                                } catch (e) {
                                  _showSnackBar(
                                    'Lỗi: $e',
                                    backgroundColor: Colors.red,
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'Bắt đầu',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ),

                          if (vote.end == 1 && vote.type == false)
                            ElevatedButton(
                              onPressed: () async {
                                try {
                                  await _calendarService.updateMeetingVoteEnd(
                                    meetingVoteId: vote.id.toString(),
                                    isStart: false,
                                  );

                                  _showSnackBar('Dừng biểu quyết thành công');

                                  // Refresh meeting data
                                  await _refreshMeetingData();
                                } catch (e) {
                                  _showSnackBar(
                                    'Lỗi: $e',
                                    backgroundColor: Colors.red,
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'Dừng lại',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ),

                          // nút Xem kết quả (chỉ hiển thị khi end = 2)
                          if (vote.end == 2)
                            ElevatedButton(
                              onPressed: () => _showResultDialog(context, vote),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.teal,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'Xem kết quả',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // popup Xem kết quả biểu quyết
  void _showResultDialog(BuildContext context, MeetingVote vote) {
    // tổng số phiếu
    final totalVotes =
        vote.meetingVotedCount?.fold(
          0,
          (sum, item) => sum + (item.vote ?? 0),
        ) ??
        0;

    // phiếu tham gia biểu quyết
    final totalVotesShow =
        vote.meetingVotedCount?.fold<int>(0, (sum, item) {
          if (item.title == 'Không biểu quyết') {
            return sum; // bỏ qua không cộng
          }
          return sum + (item.vote ?? 0);
        }) ??
        0;

    final voteResults = {
      'Tán thành': 0,
      'Không tán thành': 0,
      'Không biểu quyết': 0,
    };

    // tính số lượng và phần trăm cho từng loại
    vote.meetingVotedCount?.forEach((result) {
      if (voteResults.containsKey(result.title)) {
        voteResults[result.title!] = result.vote ?? 0;
      }
    });

    // lấy danh sách đại biểu không biểu quyết trong meetingVoted
    final nonVoters =
        vote.meetingVoted
            ?.where((voted) => voted.title == 'Không biểu quyết')
            .toList() ??
        [];

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            backgroundColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 16,
            ), // Tăng padding để Dialog rộng hơn
            title: Column(
              children: [
                Text(
                  'KẾT QUẢ BIỂU QUYẾT',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Color(0xFF2C3E50),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12),
                Text(
                  vote.title ?? '',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFF7F8C8D),
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Thời gian
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Thời gian: ${_formatDuration(vote.time)}',
                      style: TextStyle(fontSize: 14, color: Colors.black87),
                    ),
                  ),
                  SizedBox(height: 16),
                  // Số đại biểu tham gia
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Tham gia: $totalVotesShow',
                      style: TextStyle(fontSize: 14, color: Colors.black87),
                    ),
                  ),
                  SizedBox(height: 16),
                  // Kết quả biểu quyết
                  ...voteResults.entries.map((entry) {
                    final percentage =
                        totalVotes > 0
                            ? (entry.value / totalVotes * 100).toStringAsFixed(
                              2,
                            )
                            : '0.0';
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            entry.key,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            '${entry.value} ($percentage%)',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2C3E50),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  // Danh sách đại biểu không biểu quyết
                  if (vote.type == true && nonVoters.isNotEmpty) ...[
                    SizedBox(height: 16),
                    Text(
                      'Danh sách đại biểu không biểu quyết:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                    SizedBox(height: 12),
                    ...nonVoters.map((voted) {
                      final user = voted.userCreatedBy;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                flex: 2,
                                child: Text(
                                  user?.tenDayDu ?? 'undefined',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  user?.tenDangNhap ?? 'undefined',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  user?.thongTinDonVi?.ten ?? 'undefined',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Đóng',
                  style: TextStyle(
                    color: Colors.teal,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
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
