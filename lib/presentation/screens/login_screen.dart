import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:quanlyhop/presentation/widgets/login_form.dart';
import 'package:quanlyhop/data/services/auth_service.dart';
import 'package:quanlyhop/data/services/auth_manager.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _checkExistingAuth();
  }

  // Kiểm tra xem user đã đăng nhập chưa
  Future<void> _checkExistingAuth() async {
    try {
      await AuthManager.instance.loadAuthData();
      if (AuthManager.instance.isLoggedIn &&
          !AuthManager.instance.isTokenExpired()) {
        // Nếu đã đăng nhập và token còn hạn, chuyển về home
        if (mounted) {
          context.go('/home');
        }
      }
    } catch (e) {
      // Có lỗi khi load auth data, tiếp tục hiển thị login
      debugPrint('Error loading auth data: $e');
    }
  }

  void _showLoadingDialog() {
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => PopScope(
            canPop: false,
            child: const Center(
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Đang đăng nhập...'),
                    ],
                  ),
                ),
              ),
            ),
          ),
    );
  }

  void _hideLoadingDialog() {
    if (mounted && Navigator.canPop(context)) {
      Navigator.of(context).pop();
    }
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'Đóng',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  void _showSuccessSnackBar() {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Text('Đăng nhập thành công!'),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _login(String username, String password) async {
    // Validate input
    if (username.trim().isEmpty) {
      _showErrorSnackBar('Vui lòng nhập tên đăng nhập');
      return;
    }

    if (password.trim().isEmpty) {
      _showErrorSnackBar('Vui lòng nhập mật khẩu');
      return;
    }

    if (_isLoading) return; // Prevent multiple login attempts

    setState(() {
      _isLoading = true;
    });

    _showLoadingDialog();

    try {
      // Gọi API đăng nhập
      final userModel = await _authService.login(
        username.trim(),
        password.trim(),
      );

      if (!mounted) return;

      _hideLoadingDialog();

      // Kiểm tra kết quả đăng nhập
      if (userModel.state && userModel.token.isNotEmpty) {
        _showSuccessSnackBar();

        // Chờ một chút để user thấy thông báo thành công
        await Future.delayed(const Duration(milliseconds: 500));

        if (mounted) {
          // Chuyển đến màn hình home
          context.go('/home');
        }
      } else {
        _showErrorSnackBar(
          'Đăng nhập thất bại. Vui lòng kiểm tra lại thông tin.',
        );
      }
    } catch (e) {
      if (!mounted) return;

      _hideLoadingDialog();

      // Xử lý lỗi và hiển thị thông báo phù hợp
      String errorMessage = _parseErrorMessage(e.toString());
      _showErrorSnackBar(errorMessage);

      debugPrint('Login error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _parseErrorMessage(String errorString) {
  if (errorString.contains('Tài khoản') &&
      (errorString.contains('không đúng') || errorString.contains('không chính xác'))) {
    return 'Tài khoản hoặc mật khẩu không đúng. Vui lòng thử lại.';
  } else if (errorString.contains('Tài khoản bị khóa')) {
    return 'Tài khoản của bạn đã bị khóa. Vui lòng liên hệ hỗ trợ.';
  } else if (errorString.contains('Kết nối quá chậm')) {
    return 'Kết nối quá chậm, vui lòng thử lại.';
  } else if (errorString.contains('Không có kết nối internet')) {
    return 'Không có kết nối internet. Vui lòng kiểm tra và thử lại.';
  } else if (errorString.contains('Lỗi server')) {
    return 'Máy chủ đang gặp sự cố. Vui lòng thử lại sau.';
  } else if (errorString.contains('Exception:')) {
    final match = RegExp(r'Exception:\s*(.+?)(?:\n|$)').firstMatch(errorString);
    return match?.group(1)?.trim() ?? 'Đăng nhập thất bại. Vui lòng thử lại.';
  } else {
    return 'Đăng nhập thất bại. Vui lòng thử lại sau.';
  }
}


  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Center(child: LoginForm(onLogin: _login, isLoading: _isLoading)),
      ),
    );
  }
}
