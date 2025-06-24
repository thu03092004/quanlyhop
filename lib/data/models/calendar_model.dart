import 'package:html/parser.dart' show parse;
import 'package:quanlyhop/data/models/user_model.dart';

class CalendarResponse {
  final int status;
  final List<Meeting> data;
  final int pageSize;
  final int pageNumber;

  CalendarResponse({
    required this.status,
    required this.data,
    required this.pageSize,
    required this.pageNumber,
  });

  factory CalendarResponse.fromJson(Map<String, dynamic> json) {
    return CalendarResponse(
      status: json['status'] as int,
      data:
          (json['data'] as List<dynamic>?)
              ?.map((item) => Meeting.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      pageSize: json['pageSize'] as int? ?? 0,
      pageNumber: json['pageNumber'] as int? ?? 0,
    );
  }
}

class Meeting {
  final String? id;
  final String? title;
  final String? content;
  final DateTime? startTime;
  final DateTime? endTime;
  final int? chairMan;
  final String? roomName;
  final String? place;
  final int? status;
  final bool? start;
  final String? token;
  final int? serverId;
  final int? typeId;
  final int? sharedRole;
  final bool? isLobby;
  final bool? isPublished;
  final bool? isCancel;
  final bool? isOnline;
  final String? password;
  final DateTime? createdDate;
  final int? createdBy;
  final DateTime? modifiedDate;
  final int? modifiedBy;
  final DateTime? deletedDate;
  final int? deletedBy;
  final bool? isDeleted;
  final int? support;
  final int? technician;
  final UserData? userChairMan;

  Meeting({
    this.id,
    this.title,
    this.content,
    this.startTime,
    this.endTime,
    this.chairMan,
    this.roomName,
    this.place,
    this.status,
    this.start,
    this.token,
    this.serverId,
    this.typeId,
    this.sharedRole,
    this.isLobby,
    this.isPublished,
    this.isCancel,
    this.isOnline,
    this.password,
    this.createdDate,
    this.createdBy,
    this.modifiedDate,
    this.modifiedBy,
    this.deletedDate,
    this.deletedBy,
    this.isDeleted,
    this.support,
    this.technician,
    this.userChairMan,
  });

  factory Meeting.fromJson(Map<String, dynamic> json) {
    return Meeting(
      id: json['id'] as String?,
      title: json['title'] as String?,
      content: _stripHtml(
        json['content'] as String?,
      ), // Xử lý HTML trong content
      startTime:
          json['startTime'] != null
              ? DateTime.parse(json['startTime'] as String)
              : null,
      endTime:
          json['endTime'] != null
              ? DateTime.parse(json['endTime'] as String)
              : null,
      chairMan: json['chairMan'] as int?,
      roomName: json['roomName'] as String?,
      place: json['place'] as String?,
      status: json['status'] as int?,
      start: json['start'] as bool?,
      token: json['token'] as String?,
      serverId: json['serverId'] as int?,
      typeId: json['typeId'] as int?,
      sharedRole: json['sharedRole'] as int?,
      isLobby: json['isLobby'] as bool?,
      isPublished: json['isPublished'] as bool?,
      isCancel: json['isCancel'] as bool?,
      isOnline: json['isOnline'] as bool?,
      password: json['password'] as String?,
      createdDate:
          json['createdDate'] != null
              ? DateTime.parse(json['createdDate'] as String)
              : null,
      createdBy: json['createdBy'] as int?,
      modifiedDate:
          json['modifiedDate'] != null
              ? DateTime.parse(json['modifiedDate'] as String)
              : null,
      deletedDate:
          json['deletedDate'] != null
              ? DateTime.parse(json['deletedDate'] as String)
              : null,
      deletedBy: json['deletedBy'] as int?,
      isDeleted: json['isDeleted'] as bool?,
      support: json['support'] as int?,
      technician: json['technician'] as int?,
      userChairMan:
          json['userChairMan'] != null
              ? UserData.fromJson({
                'id': json['userChairMan']['id'],
                'ten_dangnhap': json['userChairMan']['ten_dangnhap'],
                'ten_day_du': json['userChairMan']['ten_day_du'],
                'ma_tochuc': json['userChairMan']['ma_tochuc'],
                'email': json['userChairMan']['email'],
                'so_dien_thoai': json['userChairMan']['so_dien_thoai'],
                'donvi': json['userChairMan']['thong_tin_don_vi'],
                'chucvu': json['userChairMan']['thong_tin_chuc_vu'],
              })
              : null,
    );
  }

  static String? _stripHtml(String? htmlString) {
    if (htmlString == null) return null;
    final document = parse(htmlString);
    return document.body?.text.trim();
  }
}
