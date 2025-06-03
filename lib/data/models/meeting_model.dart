import 'package:intl/intl.dart';

import 'user_model.dart';

class MeetingModel {
  final String title;
  final String content;
  final DateTime startTime;
  final DateTime endTime;
  final int chairMan;
  final String roomName;
  final String place;
  final int status;
  final bool start;
  final String token;
  final int serverId;
  final int typeId;
  final int sharedRole;
  final String password;
  final bool isLobby;
  final bool isPublished;
  final bool isCancel;
  final bool isOnline;
  final DateTime createdDate;
  final int createdBy;
  final int donVi;
  final int support;
  final int technician;
  final String listSupport;
  final UserData user;

  MeetingModel({
    required this.title,
    required this.content,
    required this.startTime,
    required this.endTime,
    required this.chairMan,
    required this.roomName,
    required this.place,
    required this.status,
    required this.start,
    required this.token,
    required this.serverId,
    required this.typeId,
    required this.sharedRole,
    required this.password,
    required this.isLobby,
    required this.isPublished,
    required this.isCancel,
    required this.isOnline,
    required this.createdDate,
    required this.createdBy,
    required this.donVi,
    required this.support,
    required this.technician,
    required this.listSupport,
    required this.user,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'chairMan': chairMan,
      'roomName': roomName,
      'place': place,
      'status': status,
      'start': start,
      'token': token,
      'serverId': serverId,
      'typeId': typeId,
      'sharedRole': sharedRole,
      'password': password,
      'isLobby': isLobby,
      'isPublished': isPublished,
      'isCancel': isCancel,
      'isOnline': isOnline,
      'createdDate': createdDate.toIso8601String(),
      'createdBy': createdBy,
      'don_vi': donVi,
      'support': support,
      'technician': technician,
      'listSupport': listSupport,
      'user': user.toJson(),
    };
  }

  /// Hàm tạo cuộc họp "ngay bây giờ" kéo dài 8 tiếng
  factory MeetingModel.createQuickMeeting({
    required String roomName,
    required UserModel userModel,
    required String password,
  }) {
    assert(roomName.isNotEmpty, 'roomName không được để trống');

    final now = DateTime.now();
    final formattedNow = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);

    return MeetingModel(
      title: "Cuộc họp nhanh",
      content: "Cuộc họp nhanh $formattedNow",
      startTime: now,
      endTime: now.add(const Duration(hours: 8)),
      chairMan: userModel.data.id,
      roomName: roomName,
      place: '',
      status: 2,
      start: true,
      token: userModel.token,
      serverId: 0,
      typeId: 1,
      sharedRole: 0,
      password: password,
      isLobby: false,
      isPublished: true,
      isCancel: false,
      isOnline: true,
      createdDate: now,
      createdBy: userModel.data.id,
      donVi: userModel.data.donVi?.id ?? 0,
      support: 0,
      technician: 0,
      listSupport: '',
      user: userModel.data,
    );
  }
}
