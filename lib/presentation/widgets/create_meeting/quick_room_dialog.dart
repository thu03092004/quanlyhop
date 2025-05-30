// import 'package:flutter/material.dart';

// class QuickRoomDialog extends StatefulWidget {
//   const QuickRoomDialog({super.key});

//   @override
//   State<QuickRoomDialog> createState() => _QuickRoomDialogState();
// }

// class _QuickRoomDialogState extends State<QuickRoomDialog>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _animationController;
//   late Animation<double> _scaleAnimation;
//   late Animation<double> _opacityAnimation;
//   // ignore: unused_field
//   late Animation<double> _passwordFieldAnimation;

//   bool _isPasswordEnabled = false;
//   bool _obscurePassword = true;
//   final TextEditingController _topicController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   final FocusNode _topicFocusNode = FocusNode();
//   final FocusNode _passwordFocusNode = FocusNode();

//   @override
//   void initState() {
//     super.initState();
//     _animationController = AnimationController(
//       duration: const Duration(milliseconds: 300),
//       vsync: this,
//     );

//     _scaleAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
//       CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
//     );

//     _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
//     );

//     _passwordFieldAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
//     );

//     _animationController.forward();
//   }

//   @override
//   void dispose() {
//     _animationController.dispose();
//     _topicController.dispose();
//     _passwordController.dispose();
//     _topicFocusNode.dispose();
//     _passwordFocusNode.dispose();
//     super.dispose();
//   }

//   Future<void> _closeDialog() async {
//     await _animationController.reverse();
//     if (mounted) {
//       Navigator.of(context).pop();
//     }
//   }

//   void _onCreateQuickRoom() {
//     if (_topicController.text.trim().isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: const Text('Vui lòng nhập tiêu đề phòng họp'),
//           backgroundColor: Colors.orange[600],
//           behavior: SnackBarBehavior.floating,
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//         ),
//       );
//       _topicFocusNode.requestFocus();
//       return;
//     }

//     _closeDialog();
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Row(
//           children: [
//             const SizedBox(
//               width: 20,
//               height: 20,
//               child: CircularProgressIndicator(
//                 strokeWidth: 2,
//                 valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//               ),
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Text(
//                 'Đang tạo phòng "${_topicController.text.trim()}"...',
//               ),
//             ),
//           ],
//         ),
//         backgroundColor: Colors.teal,
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//         duration: const Duration(seconds: 3),
//       ),
//     );
//   }

//   Widget _buildInputField({
//     required TextEditingController controller,
//     required FocusNode focusNode,
//     required String label,
//     required String hint,
//     bool isRequired = false,
//     bool obscureText = false,
//     Widget? suffixIcon,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // Sửa lỗi overflow ở đây - sử dụng Flexible thay vì Row cứng
//         Wrap(
//           crossAxisAlignment: WrapCrossAlignment.center,
//           children: [
//             Text(
//               label,
//               style: const TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w600,
//                 color: Colors.black87,
//               ),
//             ),
//             if (isRequired) ...[
//               const SizedBox(width: 4),
//               const Text(
//                 '*',
//                 style: TextStyle(
//                   color: Colors.red,
//                   fontWeight: FontWeight.bold,
//                   fontSize: 16,
//                 ),
//               ),
//             ],
//           ],
//         ),
//         const SizedBox(height: 8),
//         TextField(
//           controller: controller,
//           focusNode: focusNode,
//           obscureText: obscureText,
//           style: const TextStyle(fontSize: 16, color: Colors.black87),
//           decoration: InputDecoration(
//             hintText: hint,
//             hintStyle: TextStyle(color: Colors.grey[500], fontSize: 16),
//             filled: true,
//             fillColor: Colors.grey[50],
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12),
//               borderSide: BorderSide(color: Colors.grey[300]!),
//             ),
//             enabledBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12),
//               borderSide: BorderSide(color: Colors.grey[300]!),
//             ),
//             focusedBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12),
//               borderSide: const BorderSide(color: Colors.teal, width: 2),
//             ),
//             errorBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12),
//               borderSide: const BorderSide(color: Colors.red, width: 2),
//             ),
//             contentPadding: const EdgeInsets.symmetric(
//               horizontal: 16,
//               vertical: 16,
//             ),
//             suffixIcon: suffixIcon,
//           ),
//         ),
//       ],
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AnimatedBuilder(
//       animation: _animationController,
//       builder: (context, child) {
//         return Dialog(
//           backgroundColor: Colors.transparent,
//           child: Transform.scale(
//             scale: _scaleAnimation.value,
//             child: Opacity(
//               opacity: _opacityAnimation.value,
//               child: Container(
//                 constraints: const BoxConstraints(
//                   maxWidth: 420, // Tăng maxWidth để tránh overflow
//                   minWidth: 320,
//                 ),
//                 margin: const EdgeInsets.all(
//                   16,
//                 ), // Thêm margin để tránh overflow màn hình
//                 padding: const EdgeInsets.all(24), // Giảm padding một chút
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(20),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withAlpha((0.15 * 255).toInt()),
//                       blurRadius: 30,
//                       offset: const Offset(0, 15),
//                       spreadRadius: 0,
//                     ),
//                   ],
//                 ),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Header với icon - Sử dụng Flexible để tránh overflow
//                     Row(
//                       children: [
//                         Container(
//                           padding: const EdgeInsets.all(8),
//                           decoration: BoxDecoration(
//                             color: Colors.teal.withAlpha((0.1 * 255).toInt()),
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           child: const Icon(
//                             Icons.video_call,
//                             color: Colors.teal,
//                             size: 24,
//                           ),
//                         ),
//                         const SizedBox(width: 12),
//                         const Expanded(
//                           // Sử dụng Expanded để text có thể wrap
//                           child: Text(
//                             'Tạo phòng họp nhanh',
//                             style: TextStyle(
//                               fontSize: 20, // Giảm font size một chút
//                               fontWeight: FontWeight.bold,
//                               color: Colors.black87,
//                             ),
//                             maxLines: 2, // Cho phép text xuống dòng
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                         ),
//                         const SizedBox(width: 8),
//                         IconButton(
//                           onPressed: _closeDialog,
//                           icon: const Icon(Icons.close),
//                           color: Colors.grey[600],
//                           padding: const EdgeInsets.all(6), // Giảm padding
//                           constraints: const BoxConstraints(
//                             minWidth: 32,
//                             minHeight: 32,
//                           ),
//                           style: IconButton.styleFrom(
//                             backgroundColor: Colors.grey[100],
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),

//                     const SizedBox(height: 24),

//                     // Tiêu đề field
//                     _buildInputField(
//                       controller: _topicController,
//                       focusNode: _topicFocusNode,
//                       label: 'Tiêu đề phòng họp',
//                       hint: 'Nhập tên cuộc họp...',
//                       isRequired: true,
//                     ),

//                     const SizedBox(height: 20),

//                     // Password section với animation
//                     Container(
//                       padding: const EdgeInsets.all(16),
//                       decoration: BoxDecoration(
//                         color: Colors.grey[50],
//                         borderRadius: BorderRadius.circular(12),
//                         border: Border.all(color: Colors.grey[200]!),
//                       ),
//                       child: Column(
//                         children: [
//                           Row(
//                             children: [
//                               Icon(
//                                 Icons.lock_outline,
//                                 color: Colors.grey[600],
//                                 size: 20,
//                               ),
//                               const SizedBox(width: 8),
//                               const Expanded(
//                                 // Sử dụng Expanded để tránh overflow
//                                 child: Text(
//                                   'Mật khẩu',
//                                   style: TextStyle(
//                                     fontSize: 15, // Giảm font size
//                                     fontWeight: FontWeight.w600,
//                                     color: Colors.black87,
//                                   ),
//                                   overflow: TextOverflow.ellipsis,
//                                 ),
//                               ),
//                               Switch(
//                                 value: _isPasswordEnabled,
//                                 onChanged: (value) {
//                                   setState(() {
//                                     _isPasswordEnabled = value;
//                                     if (!value) {
//                                       _passwordController.clear();
//                                     } else {
//                                       Future.delayed(
//                                         const Duration(milliseconds: 300),
//                                         () => _passwordFocusNode.requestFocus(),
//                                       );
//                                     }
//                                   });
//                                 },
//                                 activeColor: Colors.teal,
//                                 materialTapTargetSize:
//                                     MaterialTapTargetSize.shrinkWrap,
//                               ),
//                             ],
//                           ),

//                           // Password field với animation
//                           AnimatedContainer(
//                             duration: const Duration(milliseconds: 300),
//                             curve: Curves.easeInOut,
//                             height: _isPasswordEnabled ? 80 : 0,
//                             child: AnimatedOpacity(
//                               duration: const Duration(milliseconds: 300),
//                               opacity: _isPasswordEnabled ? 1.0 : 0.0,
//                               child:
//                                   _isPasswordEnabled
//                                       ? Padding(
//                                         padding: const EdgeInsets.only(top: 16),
//                                         child: TextField(
//                                           controller: _passwordController,
//                                           focusNode: _passwordFocusNode,
//                                           obscureText: _obscurePassword,
//                                           style: const TextStyle(
//                                             fontSize: 16,
//                                             color: Colors.black87,
//                                           ),
//                                           decoration: InputDecoration(
//                                             hintText: 'Nhập mật khẩu...',
//                                             hintStyle: TextStyle(
//                                               color: Colors.grey[500],
//                                               fontSize:
//                                                   15, // Giảm font size hint
//                                             ),
//                                             filled: true,
//                                             fillColor: Colors.white,
//                                             border: OutlineInputBorder(
//                                               borderRadius:
//                                                   BorderRadius.circular(8),
//                                               borderSide: BorderSide(
//                                                 color: Colors.grey[300]!,
//                                               ),
//                                             ),
//                                             enabledBorder: OutlineInputBorder(
//                                               borderRadius:
//                                                   BorderRadius.circular(8),
//                                               borderSide: BorderSide(
//                                                 color: Colors.grey[300]!,
//                                               ),
//                                             ),
//                                             focusedBorder: OutlineInputBorder(
//                                               borderRadius:
//                                                   BorderRadius.circular(8),
//                                               borderSide: const BorderSide(
//                                                 color: Colors.teal,
//                                                 width: 2,
//                                               ),
//                                             ),
//                                             contentPadding:
//                                                 const EdgeInsets.symmetric(
//                                                   horizontal: 12,
//                                                   vertical: 12,
//                                                 ),
//                                             suffixIcon: IconButton(
//                                               icon: Icon(
//                                                 _obscurePassword
//                                                     ? Icons
//                                                         .visibility_off_outlined
//                                                     : Icons.visibility_outlined,
//                                                 color: Colors.grey[600],
//                                                 size: 20,
//                                               ),
//                                               onPressed: () {
//                                                 setState(() {
//                                                   _obscurePassword =
//                                                       !_obscurePassword;
//                                                 });
//                                               },
//                                               padding: const EdgeInsets.all(8),
//                                             ),
//                                           ),
//                                         ),
//                                       )
//                                       : const SizedBox.shrink(),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),

//                     const SizedBox(height: 28),

//                     // Buttons (giữ nguyên như yêu cầu)
//                     Row(
//                       children: [
//                         Expanded(
//                           child: OutlinedButton(
//                             onPressed: _closeDialog,
//                             style: OutlinedButton.styleFrom(
//                               foregroundColor: Colors.grey[600],
//                               side: BorderSide(color: Colors.grey[400]!),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                               padding: const EdgeInsets.symmetric(vertical: 16),
//                             ),
//                             child: const Text(
//                               'Hủy',
//                               style: TextStyle(
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.w500,
//                               ),
//                             ),
//                           ),
//                         ),
//                         const SizedBox(width: 12),
//                         Expanded(
//                           child: ElevatedButton(
//                             onPressed: _onCreateQuickRoom,
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: Colors.teal,
//                               foregroundColor: Colors.white,
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                               padding: const EdgeInsets.symmetric(vertical: 16),
//                               elevation: 0,
//                             ),
//                             child: const Text(
//                               'Tạo ngay',
//                               style: TextStyle(
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }

import 'package:flutter/material.dart';
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
      if (mounted) {
        _showSnackBar(result['message'], result['success']);
        if (result['success']) {
          _closeDialog();
        }
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
