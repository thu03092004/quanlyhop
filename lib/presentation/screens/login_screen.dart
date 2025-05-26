import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:quanlyhop/presentation/widgets/login_form.dart';
import 'package:quanlyhop/data/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String? error;
  final AuthService _authService = AuthService();

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
  }

  void _hideLoadingDialog() {
    if (Navigator.canPop(context)) {
      Navigator.of(context).pop();
    }
  }

  void _login(String user, String password) async {
    _showLoadingDialog();
    try {
      await _authService.login(user, password);
      if (!mounted) return;
      _hideLoadingDialog();
      context.go('/home');
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
          duration: Duration(milliseconds: 1500),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      _hideLoadingDialog();

      final rawMessage = e.toString();
      final match = RegExp(r'message: (.+?)(}|$)').firstMatch(rawMessage);
      error =
          match != null
              ? match.group(1)
              : 'Đăng nhập thất bại. Vui lòng thử lại.';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error!),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          duration: Duration(milliseconds: 1500),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: LoginForm(onLogin: _login)));
  }
}

// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:quanlyhop/app/presentation/widgets/login_form.dart';
// import 'package:quanlyhop/data/services/auth_service.dart';

// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});

//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   bool isLoading = false;
//   String? error;

//   final AuthService _authService = AuthService();

//   void _login(String user, String password) async {
//     setState(() {
//       isLoading = true;
//       error = null;
//     });
//     try {
//       await _authService.login(user, password);
//       if (!mounted) return;
//       setState(() {
//         isLoading = false;
//       });
//       context.go('/home');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Row(
//             children: const [
//               Icon(Icons.check_circle, color: Colors.white),
//               SizedBox(width: 8),
//               Text('Đăng nhập thành công!'),
//             ],
//           ),
//           backgroundColor: Colors.green,
//           behavior: SnackBarBehavior.floating,
//         ),
//       );
//     } catch (e) {
//       setState(() {
//         isLoading = false;
//         // error = e.toString();
//         final rawMessage = e.toString();
//         final match = RegExp(r'message: (.+?)(}|$)').firstMatch(rawMessage);
//         error =
//             match != null
//                 ? match.group(1)
//                 : 'Đăng nhập thất bại. Vui lòng thử lại.';
//       });
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(error!),
//           backgroundColor: Colors.red,
//           behavior: SnackBarBehavior.floating,
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       // appBar: AppBar(title: const Text('Login')),
//       body: Center(
//         child:
//             isLoading
//                 ? const CircularProgressIndicator()
//                 : LoginForm(onLogin: _login),
//       ),
//     );
//   }
// }
