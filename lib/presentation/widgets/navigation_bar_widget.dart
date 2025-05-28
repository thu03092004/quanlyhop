import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:quanlyhop/core/theme/app_theme.dart';
import 'package:quanlyhop/presentation/widgets/create_meeting/create_room_dialog.dart';

class NavigationBarWidget extends StatefulWidget {
  final Widget child;

  const NavigationBarWidget({super.key, required this.child});

  @override
  State<NavigationBarWidget> createState() => _NavigationBarWidgetState();
}

class _NavigationBarWidgetState extends State<NavigationBarWidget> {
  static const List<String> _routes = [
    '/home',
    '/calendar',
    '/create',
    '/docs',
    '/profile',
  ];

  int _currentIndex(String location) {
    final index = _routes.indexWhere((r) => location.startsWith(r));
    return index != -1 ? index : 0;
  }

  void _onItemTapped(int index) {
    final route = _routes[index];
    if (route != '/create') {
      context.go(route);
    } else {
      _showCreateRoomDialog();
    }
  }

  void _showCreateRoomDialog() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Create Room Dialog',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return const CreateRoomDialog();
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1), // Bắt đầu từ dưới màn hình
            end: Offset.zero, // Kết thúc ở giữa màn hình
          ).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeInOut),
          ),
          child: FadeTransition(opacity: animation, child: child),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final String currentLocation = GoRouterState.of(context).uri.toString();
    final int selectedIndex = _currentIndex(currentLocation);

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppTheme.backgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha((0.1 * 255).round()),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            height: 70,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.all_inbox, 'Hoạt động', selectedIndex),
                _buildNavItem(1, Icons.event, 'Lịch họp', selectedIndex),

                // Nút tạo phòng nổi bật với Transform.translate đẩy lên cao
                Expanded(
                  child: GestureDetector(
                    onTap: () => _onItemTapped(2),
                    child: Transform.translate(
                      offset: const Offset(0, -12), // đẩy lên cao 12 pixel
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.teal,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.teal.withAlpha((0.4 * 255).round()),
                              blurRadius: 4,
                              spreadRadius: 0,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.video_call,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ),
                  ),
                ),

                _buildNavItem(3, Icons.folder_open, 'Tài liệu', selectedIndex),
                _buildNavItem(
                  4,
                  Icons.person_outline,
                  'Tài khoản',
                  selectedIndex,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    IconData icon,
    String label,
    int selectedIndex,
  ) {
    final isSelected = selectedIndex == index;
    final color = isSelected ? Colors.teal : Colors.grey[600];

    return Expanded(
      child: InkWell(
        onTap: () => _onItemTapped(index),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 24, color: color),
              const SizedBox(height: 4),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: color,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
