import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:quanlyhop/core/theme/app_theme.dart';
import 'package:quanlyhop/data/models/permission_model.dart';

class CreateScheduleDialog extends StatefulWidget {
  final List<PermissionModel> permissions;

  const CreateScheduleDialog({super.key, required this.permissions});

  @override
  State<CreateScheduleDialog> createState() => _CreateScheduleDialogState();
}

class _CreateScheduleDialogState extends State<CreateScheduleDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

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
    super.dispose();
  }

  Future<void> _closeDialog() async {
    await _animationController.reverse();
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  void _onCreateSchedule() {
    _closeDialog();
    _navigateToCreateSchedule(widget.permissions);
  }

  void _navigateToCreateSchedule(List<PermissionModel> permissions) {
    context.go(
      '/calendar/create',
      extra: {
        'permissions': permissions,
        'hasScheduleOrgan': permissions.any(
          (p) => p.mota.contains('ScheduleOrgan'),
        ),
        'hasSchedule': permissions.any((p) => p.mota.contains('Schedule')),
      },
    );
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
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.backgroundColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha((0.1 * 255).toInt()),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Flexible(
                          child: Text(
                            'Tạo lịch họp mới',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: _closeDialog,
                          icon: const Icon(Icons.close, color: Colors.grey),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Icon
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.teal.shade50,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.teal, width: 2),
                      ),
                      child: const Icon(
                        Icons.calendar_today,
                        color: Colors.teal,
                        size: 40,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Description
                    const Text(
                      'Bạn có muốn tạo lịch họp mới với thời gian và địa điểm cụ thể?',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 16),

                    // Permissions info
                    if (widget.permissions.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.teal.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.teal.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: Colors.teal.shade600,
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Quyền hiện tại:',
                                  style: TextStyle(
                                    color: Colors.teal.shade700,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            ...widget.permissions.map(
                              (permission) => Padding(
                                padding: const EdgeInsets.only(
                                  left: 24,
                                  top: 2,
                                ),
                                child: Text(
                                  '• ${permission.mota}',
                                  style: TextStyle(
                                    color: Colors.teal.shade600,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Buttons
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
                              padding: const EdgeInsets.symmetric(vertical: 16),
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
                            onPressed: _onCreateSchedule,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Tiếp tục',
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
        );
      },
    );
  }
}
