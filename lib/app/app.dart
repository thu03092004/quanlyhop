import 'package:flutter/material.dart';
import 'package:quanlyhop/app/router/app_router.dart';
import 'package:quanlyhop/core/theme/app_theme.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Hệ thống quản lý họp',
      theme: AppTheme.lightTheme,
      routerConfig: appRouter,
    );
  }
}
