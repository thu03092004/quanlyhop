import 'package:flutter/material.dart';
import 'package:quanlyhop/core/theme/app_theme.dart';
import 'package:quanlyhop/data/models/meeting_model.dart';
import 'package:quanlyhop/data/models/user_model.dart';
import 'package:quanlyhop/data/services/meeting_service.dart';
import 'package:quanlyhop/presentation/widgets/password_field.dart';

import 'custom_input_field.dart';

class QuickRoomDialog extends StatefulWidget {
  final UserModel userModel;

  const QuickRoomDialog({super.key, required this.userModel});

  @override
  State<QuickRoomDialog> createState() => _QuickRoomDialogState();
}

class _QuickRoomDialogState extends State<QuickRoomDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  final TextEditingController _topicController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _topicFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final MeetingService _meetingService = MeetingService();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _topicController.dispose();
    _passwordController.dispose();
    _topicFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  // kiểm tra tiêu đề phòng họp có hợp lệ không
  bool _isValidRoomName(String roomName) {
    final regex = RegExp(r'^[a-zA-Z0-9]+$');
    return regex.hasMatch(roomName) && roomName.isNotEmpty;
  }

  Future<void> _closeDialog() async {
    await _animationController.reverse();
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  void _showSnackBar(String message, bool isSuccess) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? Colors.teal : Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _onCreateQuickRoom() {
    final roomName = _topicController.text.trim();

    if (!_isValidRoomName(roomName)) {
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              backgroundColor: AppTheme.backgroundColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text(
                'Lỗi đặt tên phòng',
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Text(
                'Tên lịch họp phải viết liền, không dấu, không chứa ký tự đặc biệt hoặc khoảng trắng!',
                style: const TextStyle(color: Colors.black87, fontSize: 18),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.teal, // màu chữ nút
                  ),
                  child: const Text('Đóng'),
                ),
              ],
            ),
      );

      return;
    }
    final meeting = MeetingModel.createQuickMeeting(
      roomName: roomName,
      userModel: widget.userModel,
      password: _passwordController.text.trim(),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text('Đang tạo phòng "${meeting.title}"...')),
          ],
        ),
        backgroundColor: Colors.teal,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 3),
      ),
    );

    _meetingService.createMeeting(meeting).then((result) {
      // if (mounted) {
      //   _showSnackBar(result['message'], result['success']);
      //   if (result['success']) {
      //     _closeDialog();
      //   }
      // }
      if (!mounted) return;

      if (result['success']) {
        _showSnackBar(result['message'], true);
        _closeDialog();
      } else {
        showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                backgroundColor: AppTheme.backgroundColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                title: const Text(
                  'Lỗi tạo phòng',
                  style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                content: Text(
                  result['message'],
                  style: const TextStyle(color: Colors.black87, fontSize: 18),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.teal, // màu chữ nút
                    ),
                    child: const Text('Đóng'),
                  ),
                ],
              ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Opacity(
              opacity: _opacityAnimation.value,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 420, minWidth: 320),
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha((0.15 * 255).toInt()),
                      blurRadius: 30,
                      offset: const Offset(0, 15),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.teal.withAlpha((0.1 * 255).toInt()),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.video_call,
                              color: Colors.teal,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Tạo phòng họp nhanh',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: _closeDialog,
                            icon: const Icon(Icons.close),
                            color: Colors.grey[600],
                            padding: const EdgeInsets.all(6),
                            constraints: const BoxConstraints(
                              minWidth: 32,
                              minHeight: 32,
                            ),
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.grey[100],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      CustomInputField(
                        controller: _topicController,
                        focusNode: _topicFocusNode,
                        label: 'Tiêu đề phòng họp',
                        hint: 'Nhập tên cuộc họp...',
                        isRequired: false,
                      ),
                      const SizedBox(height: 20),
                      PasswordField(
                        controller: _passwordController,
                        focusNode: _passwordFocusNode,
                        onPasswordToggle: (value) {},
                      ),
                      const SizedBox(height: 28),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _closeDialog,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.grey[600],
                                side: BorderSide(color: Colors.grey[400]!),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                              ),
                              child: const Text(
                                'Hủy',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _onCreateQuickRoom,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.teal,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                elevation: 0,
                              ),
                              child: const Text(
                                'Tạo ngay',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
