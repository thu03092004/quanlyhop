import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:quanlyhop/presentation/screens/calendar_screen.dart';
import 'package:quanlyhop/presentation/screens/meeting_management_screen.dart';
import 'package:quanlyhop/presentation/screens/home_screen.dart';
import 'package:quanlyhop/presentation/screens/login_screen.dart';
import 'package:quanlyhop/presentation/screens/profile_screen.dart';
import 'package:quanlyhop/presentation/screens/setting_screen.dart';
import 'package:quanlyhop/presentation/widgets/navigation_bar_widget.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: navigatorKey,
  initialLocation: '/login',
  routes: [
    /// Route đăng nhập
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),

    /// Shell route dùng NavigationBar và giữ trạng thái
    ShellRoute(
      builder: (context, state, child) {
        return NavigationBarWidget(child: child);
      },
      routes: [
        GoRoute(
          path: '/home',
          pageBuilder:
              (context, state) => CustomTransitionPage(
                key: state.pageKey,
                child: const HomeScreen(),
                transitionsBuilder: (
                  context,
                  animation,
                  secondaryAnimation,
                  child,
                ) {
                  return FadeTransition(opacity: animation, child: child);
                },
              ),
        ),

        /// Route lịch họp
        GoRoute(
          path: '/calendar',
          pageBuilder:
              (context, state) => CustomTransitionPage(
                key: state.pageKey,
                child: const CalendarScreen(),
                transitionsBuilder: (
                  context,
                  animation,
                  secondaryAnimation,
                  child,
                ) {
                  return FadeTransition(opacity: animation, child: child);
                },
              ),
        ),

        /// Route quản lý họp
        GoRoute(
          path: '/quanlylich',
          pageBuilder:
              (context, state) => CustomTransitionPage(
                key: state.pageKey,
                child: const MeetingManagementScreen(),
                transitionsBuilder: (
                  context,
                  animation,
                  secondaryAnimation,
                  child,
                ) {
                  return FadeTransition(opacity: animation, child: child);
                },
              ),
        ),

        // GoRoute(
        //   path: '/profile',
        //   builder: (context, state) => const ProfileScreen(),
        // ),
        GoRoute(
          path: '/profile',
          pageBuilder:
              (context, state) => CustomTransitionPage(
                key: state.pageKey,
                child: const ProfileScreen(),
                transitionsBuilder: (
                  context,
                  animation,
                  secondaryAnimation,
                  child,
                ) {
                  return FadeTransition(opacity: animation, child: child);
                },
              ),
        ),
      ],
    ),
    GoRoute(
      path: '/setting',
      builder: (context, state) => const SettingScreen(),
    ),
  ],

  /// Trang lỗi
  errorBuilder:
      (context, state) => const Scaffold(
        body: Center(child: Text('404 - Không tìm thấy trang')),
      ),
);
