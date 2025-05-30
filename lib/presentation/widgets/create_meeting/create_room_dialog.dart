import 'package:flutter/material.dart';
import 'package:quanlyhop/core/theme/app_theme.dart';
import 'package:quanlyhop/data/models/permission_model.dart';
import 'package:quanlyhop/data/models/user_model.dart';
import 'package:quanlyhop/data/services/auth_manager.dart';
import 'package:quanlyhop/data/services/permission_service.dart';
import 'package:quanlyhop/presentation/widgets/create_meeting/create_schedule_dialog.dart';
import 'package:quanlyhop/presentation/widgets/create_meeting/quick_room_dialog.dart';

class CreateRoomDialog extends StatefulWidget {
  const CreateRoomDialog({super.key});

  @override
  State<CreateRoomDialog> createState() => _CreateRoomDialogState();
}

class _CreateRoomDialogState extends State<CreateRoomDialog> {
  final PermissionService _permissionService = PermissionService();
  List<PermissionModel> _schedulePermissions = [];
  bool _isLoading = true;
  bool _hasPermission = false;
  String? _errorMessage;
  UserModel? _currentUser;

  @override
  void initState() {
    super.initState();
    _initializeData();
    _checkPermissions();
  }

  Future<void> _initializeData() async {
    // Lấy thông tin user hiện tại
    _currentUser = AuthManager.instance.currentUser;

    if (_currentUser == null) {
      setState(() {
        _errorMessage = 'Không tìm thấy thông tin người dùng';
        _isLoading = false;
      });
      return;
    }

    await _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    try {
      final hasPermission = await _permissionService.hasSchedulePermission();
      if (hasPermission) {
        _schedulePermissions =
            await _permissionService.getSchedulePermissions();
      }

      if (mounted) {
        setState(() {
          _hasPermission = hasPermission;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _onCreateQuickRoom() {
    if (_currentUser == null) {
      _showErrorSnackBar('Không tìm thấy thông tin người dùng');
      return;
    }
    Navigator.of(context).pop();
    _showQuickRoomDialog();
  }

  void _onCreateSchedule() {
    if (_currentUser == null) {
      _showErrorSnackBar('Không tìm thấy thông tin người dùng');
      return;
    }

    Navigator.of(context).pop();
    _showCreateScheduleDialog();
  }

  void _showQuickRoomDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => QuickRoomDialog(userModel: _currentUser!),
    );
  }

  void _showCreateScheduleDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder:
          (context) => CreateScheduleDialog(permissions: _schedulePermissions),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: isTablet ? 500 : screenWidth * 0.9,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.backgroundColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Tạo phòng họp',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, color: Colors.grey),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Content
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(color: Colors.teal),
              )
            else ...[
              // Quick room button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _onCreateQuickRoom,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: FittedBox(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.video_call, size: 24),
                        SizedBox(width: 8),
                        Text(
                          'Tạo nhanh phòng họp',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Schedule button
              if (_hasPermission && _errorMessage == null) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton(
                    onPressed: _onCreateSchedule,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.teal,
                      side: const BorderSide(color: Colors.teal, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: Colors.white,
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.calendar_today, size: 24),
                        SizedBox(width: 8),
                        Text(
                          'Thêm lịch họp mới',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              // Error message
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Colors.red.shade600,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Lỗi khi kiểm tra quyền: $_errorMessage',
                          style: TextStyle(
                            color: Colors.red.shade700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],

            // Bottom padding for safe area
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }
}
