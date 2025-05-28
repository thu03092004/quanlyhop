import 'package:flutter/material.dart';
import 'package:quanlyhop/core/theme/app_theme.dart';

class QuickRoomDialog extends StatefulWidget {
  const QuickRoomDialog({super.key});

  @override
  State<QuickRoomDialog> createState() => _QuickRoomDialogState();
}

class _QuickRoomDialogState extends State<QuickRoomDialog>
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

  void _onCreateQuickRoom() {
    _closeDialog();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đang tạo phòng họp nhanh...'),
        backgroundColor: Colors.teal,
        duration: Duration(seconds: 2),
      ),
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
                        const Text(
                          'Tạo phòng họp nhanh',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
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
                      decoration: const BoxDecoration(
                        color: Colors.teal,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.video_call,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Description
                    const Text(
                      'Bạn có muốn tạo phòng họp nhanh ngay bây giờ?',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 24),

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
                            onPressed: _onCreateQuickRoom,
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
        );
      },
    );
  }
}
