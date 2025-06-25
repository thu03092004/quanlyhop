// Thông tin lịch + Chương trình - Tài liệu họp + Thành phần tham gia + Biểu quyết + Kết luận
import 'dart:convert';

class CalendarDetailModel {
  final int status;
  final MeetingData data;

  CalendarDetailModel({required this.status, required this.data});

  factory CalendarDetailModel.fromJson(Map<String, dynamic> json) {
    return CalendarDetailModel(
      status: json['status'] as int,
      data: MeetingData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {'status': status, 'data': data.toJson()};
  }
}

// Main class for meeting data
class MeetingData {
  final String id;
  final String title;
  final String content;
  final String startTime;
  final String endTime;
  final int chairMan;
  final String roomName;
  final String place;
  final int status;
  final bool start;
  final String token;
  final int serverId;
  final int typeId;
  final int sharedRole;
  final bool isLobby;
  final bool isPublished;
  final bool isCancel;
  final bool isOnline;
  final String password;
  final String createdDate;
  final int createdBy;
  final String modifiedDate;
  final int modifiedBy;
  final String deletedDate;
  final int deletedBy;
  final bool isDeleted;
  final int support;
  final int? technician;
  final List<SupportUser> listSupport;
  final Server server;
  final MeetingType type;
  final int donVi;
  final OrganizationUnit thongTinDonVi;
  final List<MeetingVote> meetingVotes;
  final List<MeetingMemberOutside> meetingMemberOutside;
  final List<MeetingMemberInside> meetingMemberInside;
  final List<MeetingDocument> meetingDocument;
  final List<MeetingDocumentConclusion> meetingDocumentConclusion;
  final List<MeetingConclusion> meetingConslusion;
  final List<MeetingContent> meetingContent;
  final List<MeetingVideo> meetingVideo;
  final User userChairMan;
  final User userCreatedBy;
  final User? userShareRole;
  final User? userSupport;
  final User? userTechnician;
  final int? meetingMemberCount;

  MeetingData({
    required this.id,
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
    required this.isLobby,
    required this.isPublished,
    required this.isCancel,
    required this.isOnline,
    required this.password,
    required this.createdDate,
    required this.createdBy,
    required this.modifiedDate,
    required this.modifiedBy,
    required this.deletedDate,
    required this.deletedBy,
    required this.isDeleted,
    required this.support,
    this.technician,
    required this.listSupport,
    required this.server,
    required this.type,
    required this.donVi,
    required this.thongTinDonVi,
    required this.meetingVotes,
    required this.meetingMemberOutside,
    required this.meetingMemberInside,
    required this.meetingDocument,
    required this.meetingDocumentConclusion,
    required this.meetingConslusion,
    required this.meetingContent,
    required this.meetingVideo,
    required this.userChairMan,
    required this.userCreatedBy,
    this.userShareRole,
    this.userSupport,
    this.userTechnician,
    this.meetingMemberCount,
  });

  factory MeetingData.fromJson(Map<String, dynamic> json) {
    return MeetingData(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
      chairMan: json['chairMan'] as int,
      roomName: json['roomName'] as String,
      place: json['place'] as String,
      status: json['status'] as int,
      start: json['start'] as bool,
      token: json['token'] as String,
      serverId: json['serverId'] as int,
      typeId: json['typeId'] as int,
      sharedRole: json['sharedRole'] as int,
      isLobby: json['isLobby'] as bool,
      isPublished: json['isPublished'] as bool,
      isCancel: json['isCancel'] as bool,
      isOnline: json['isOnline'] as bool,
      password: json['password'] as String,
      createdDate: json['createdDate'] as String,
      createdBy: json['createdBy'] as int,
      modifiedDate: json['modifiedDate'] as String,
      modifiedBy: json['modifiedBy'] as int,
      deletedDate: json['deletedDate'] as String,
      deletedBy: json['deletedBy'] as int,
      isDeleted: json['isDeleted'] as bool,
      support: json['support'] as int,
      technician: json['technician'] as int?,
      listSupport:
          (json['listSupport'] is String
                  ? (jsonDecode(json['listSupport']) as List<dynamic>)
                  : json['listSupport'] as List<dynamic>)
              .map((e) => SupportUser.fromJson(e as Map<String, dynamic>))
              .toList(),
      server: Server.fromJson(json['server'] as Map<String, dynamic>),
      type: MeetingType.fromJson(json['type'] as Map<String, dynamic>),
      donVi: json['don_vi'] as int,
      thongTinDonVi: OrganizationUnit.fromJson(
        json['thong_Tin_Don_Vi'] as Map<String, dynamic>,
      ),
      meetingVotes:
          (json['meetingVotes'] as List<dynamic>)
              .map((e) => MeetingVote.fromJson(e as Map<String, dynamic>))
              .toList(),
      meetingMemberOutside:
          (json['meetingMemberOutside'] as List<dynamic>)
              .map(
                (e) => MeetingMemberOutside.fromJson(e as Map<String, dynamic>),
              )
              .toList(),
      meetingMemberInside:
          (json['meetingMemberInside'] as List<dynamic>)
              .map(
                (e) => MeetingMemberInside.fromJson(e as Map<String, dynamic>),
              )
              .toList(),
      meetingDocument:
          (json['meetingDocument'] as List<dynamic>)
              .map((e) => MeetingDocument.fromJson(e as Map<String, dynamic>))
              .toList(),
      meetingDocumentConclusion:
          (json['meetingDocumentConclusion'] as List<dynamic>)
              .map(
                (e) => MeetingDocumentConclusion.fromJson(
                  e as Map<String, dynamic>,
                ),
              )
              .toList(),
      meetingConslusion:
          (json['meetingConslusion'] as List<dynamic>)
              .map((e) => MeetingConclusion.fromJson(e as Map<String, dynamic>))
              .toList(),
      meetingContent:
          (json['meetingContent'] as List<dynamic>)
              .map((e) => MeetingContent.fromJson(e as Map<String, dynamic>))
              .toList(),
      meetingVideo:
          (json['meetingVideo'] as List<dynamic>)
              .map((e) => MeetingVideo.fromJson(e as Map<String, dynamic>))
              .toList(),
      userChairMan: User.fromJson(json['userChairMan'] as Map<String, dynamic>),
      userCreatedBy: User.fromJson(
        json['userCreatedBy'] as Map<String, dynamic>,
      ),
      userShareRole:
          json['userShareRole'] != null
              ? User.fromJson(json['userShareRole'] as Map<String, dynamic>)
              : null,
      userSupport:
          json['userSupport'] != null
              ? User.fromJson(json['userSupport'] as Map<String, dynamic>)
              : null,
      userTechnician:
          json['userTechnician'] != null
              ? User.fromJson(json['userTechnician'] as Map<String, dynamic>)
              : null,
      meetingMemberCount: json['meetingMemberCount'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'startTime': startTime,
      'endTime': endTime,
      'chairMan': chairMan,
      'roomName': roomName,
      'place': place,
      'status': status,
      'start': start,
      'token': token,
      'serverId': serverId,
      'typeId': typeId,
      'sharedRole': sharedRole,
      'isLobby': isLobby,
      'isPublished': isPublished,
      'isCancel': isCancel,
      'isOnline': isOnline,
      'password': password,
      'createdDate': createdDate,
      'createdBy': createdBy,
      'modifiedDate': modifiedDate,
      'modifiedBy': modifiedBy,
      'deletedDate': deletedDate,
      'deletedBy': deletedBy,
      'isDeleted': isDeleted,
      'support': support,
      'technician': technician,
      'listSupport': listSupport.map((e) => e.toJson()).toList(),
      'server': server.toJson(),
      'type': type.toJson(),
      'don_vi': donVi,
      'thong_Tin_Don_Vi': thongTinDonVi.toJson(),
      'meetingVotes': meetingVotes.map((e) => e.toJson()).toList(),
      'meetingMemberOutside':
          meetingMemberOutside.map((e) => e.toJson()).toList(),
      'meetingMemberInside':
          meetingMemberInside.map((e) => e.toJson()).toList(),
      'meetingDocument': meetingDocument.map((e) => e.toJson()).toList(),
      'meetingDocumentConclusion':
          meetingDocumentConclusion.map((e) => e.toJson()).toList(),
      'meetingConslusion': meetingConslusion.map((e) => e.toJson()).toList(),
      'meetingContent': meetingContent.map((e) => e.toJson()).toList(),
      'meetingVideo': meetingVideo.map((e) => e.toJson()).toList(),
      'userChairMan': userChairMan.toJson(),
      'userCreatedBy': userCreatedBy.toJson(),
      'userShareRole': userShareRole?.toJson(),
      'userSupport': userSupport?.toJson(),
      'userTechnician': userTechnician?.toJson(),
      'meetingMemberCount': meetingMemberCount,
    };
  }
}

// Class for Support User
class SupportUser {
  final int id;
  final String tenDangNhap;
  final String tenDayDu;
  final String maToChuc;
  final String? maChucVu;
  final String? soDienThoai;
  final String? email;
  final int thoigianTao;
  final String? idWso2;
  final bool daXoa;
  final String? maDinhDanh;
  final OrganizationUnit thongTinDonVi;
  final Position? thongTinChucVu;
  final int value;
  final String label;

  SupportUser({
    required this.id,
    required this.tenDangNhap,
    required this.tenDayDu,
    required this.maToChuc,
    this.maChucVu,
    this.soDienThoai,
    this.email,
    required this.thoigianTao,
    this.idWso2,
    required this.daXoa,
    this.maDinhDanh,
    required this.thongTinDonVi,
    this.thongTinChucVu,
    required this.value,
    required this.label,
  });

  factory SupportUser.fromJson(Map<String, dynamic> json) {
    return SupportUser(
      id: json['id'] as int,
      tenDangNhap: json['ten_dangnhap'] as String,
      tenDayDu: json['ten_day_du'] as String,
      maToChuc: json['ma_tochuc'] as String,
      maChucVu: json['ma_chucvu'] as String?,
      soDienThoai: json['so_dien_thoai'] as String?,
      email: json['email'] as String?,
      thoigianTao: json['thoigian_tao'] as int,
      idWso2: json['id_wso2'] as String?,
      daXoa: json['daxoa'] as bool,
      maDinhDanh: json['ma_dinhdanh'] as String?,
      thongTinDonVi: OrganizationUnit.fromJson(
        json['thong_tin_don_vi'] as Map<String, dynamic>,
      ),
      thongTinChucVu:
          json['thong_tin_chuc_vu'] != null
              ? Position.fromJson(
                json['thong_tin_chuc_vu'] as Map<String, dynamic>,
              )
              : null,
      value: json['value'] as int,
      label: json['label'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ten_dangnhap': tenDangNhap,
      'ten_day_du': tenDayDu,
      'ma_tochuc': maToChuc,
      'ma_chucvu': maChucVu,
      'so_dien_thoai': soDienThoai,
      'email': email,
      'thoigian_tao': thoigianTao,
      'id_wso2': idWso2,
      'daxoa': daXoa,
      'ma_dinhdanh': maDinhDanh,
      'thong_tin_don_vi': thongTinDonVi.toJson(),
      'thong_tin_chuc_vu': thongTinChucVu?.toJson(),
      'value': value,
      'label': label,
    };
  }
}

// Class for Server
class Server {
  final int id;
  final String title;
  final String ip;
  final String iss;
  final String aud;
  final bool activated;
  final bool defaultServer;
  final String createdDate;
  final int createdBy;
  final String modifiedDate;
  final int modifiedBy;
  final String deletedDate;
  final int deletedBy;
  final int rowNumber;
  final int? totalRecord;

  Server({
    required this.id,
    required this.title,
    required this.ip,
    required this.iss,
    required this.aud,
    required this.activated,
    required this.defaultServer,
    required this.createdDate,
    required this.createdBy,
    required this.modifiedDate,
    required this.modifiedBy,
    required this.deletedDate,
    required this.deletedBy,
    required this.rowNumber,
    this.totalRecord,
  });

  factory Server.fromJson(Map<String, dynamic> json) {
    return Server(
      id: json['id'] as int,
      title: json['title'] as String,
      ip: json['ip'] as String,
      iss: json['iss'] as String,
      aud: json['aud'] as String,
      activated: json['activated'] as bool,
      defaultServer: json['default'] as bool,
      createdDate: json['createdDate'] as String,
      createdBy: json['createdBy'] as int,
      modifiedDate: json['modifiedDate'] as String,
      modifiedBy: json['modifiedBy'] as int,
      deletedDate: json['deletedDate'] as String,
      deletedBy: json['deletedBy'] as int,
      rowNumber: json['rowNumber'] as int,
      totalRecord: json['totalRecord'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'ip': ip,
      'iss': iss,
      'aud': aud,
      'activated': activated,
      'default': defaultServer,
      'createdDate': createdDate,
      'createdBy': createdBy,
      'modifiedDate': modifiedDate,
      'modifiedBy': modifiedBy,
      'deletedDate': deletedDate,
      'deletedBy': deletedBy,
      'rowNumber': rowNumber,
      'totalRecord': totalRecord,
    };
  }
}

// Class for Meeting Type
class MeetingType {
  final int id;
  final String title;
  final String createdDate;
  final int createdBy;
  final String modifiedDate;
  final int modifiedBy;
  final String deletedDate;
  final int deletedBy;
  final int rowNumber;
  final int? totalRecord;

  MeetingType({
    required this.id,
    required this.title,
    required this.createdDate,
    required this.createdBy,
    required this.modifiedDate,
    required this.modifiedBy,
    required this.deletedDate,
    required this.deletedBy,
    required this.rowNumber,
    this.totalRecord,
  });

  factory MeetingType.fromJson(Map<String, dynamic> json) {
    return MeetingType(
      id: json['id'] as int,
      title: json['title'] as String,
      createdDate: json['createdDate'] as String,
      createdBy: json['createdBy'] as int,
      modifiedDate: json['modifiedDate'] as String,
      modifiedBy: json['modifiedBy'] as int,
      deletedDate: json['deletedDate'] as String,
      deletedBy: json['deletedBy'] as int,
      rowNumber: json['rowNumber'] as int,
      totalRecord: json['totalRecord'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'createdDate': createdDate,
      'createdBy': createdBy,
      'modifiedDate': modifiedDate,
      'modifiedBy': modifiedBy,
      'deletedDate': deletedDate,
      'deletedBy': deletedBy,
      'rowNumber': rowNumber,
      'totalRecord': totalRecord,
    };
  }
}

// Class for Organization Unit
class OrganizationUnit {
  final int id;
  final String ma;
  final String? maParent;
  final String ten;
  final String maHanhChinh;
  final String? diaChi;
  final String? dienThoai;
  final String? mail;
  final String? fax;
  final String? website;
  final String? moTa;
  final String? biDanh;
  final String trangThaiHoatDong;
  final int thoigianTao;
  final bool daXoa;

  OrganizationUnit({
    required this.id,
    required this.ma,
    this.maParent,
    required this.ten,
    required this.maHanhChinh,
    this.diaChi,
    this.dienThoai,
    this.mail,
    this.fax,
    this.website,
    this.moTa,
    this.biDanh,
    required this.trangThaiHoatDong,
    required this.thoigianTao,
    required this.daXoa,
  });

  factory OrganizationUnit.fromJson(Map<String, dynamic> json) {
    return OrganizationUnit(
      id: json['id'] as int,
      ma: json['ma'] as String,
      maParent: json['ma_parent'] as String?,
      ten: json['ten'] as String,
      maHanhChinh: json['ma_hanhchinh'] as String,
      diaChi: json['diachi'] as String?,
      dienThoai: json['dienthoai'] as String?,
      mail: json['mail'] as String?,
      fax: json['fax'] as String?,
      website: json['website'] as String?,
      moTa: json['mota'] as String?,
      biDanh: json['bidanh'] as String?,
      trangThaiHoatDong: json['trangthai_hoatdong'] as String,
      thoigianTao: json['thoigian_tao'] as int,
      daXoa: json['daxoa'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ma': ma,
      'ma_parent': maParent,
      'ten': ten,
      'ma_hanhchinh': maHanhChinh,
      'diachi': diaChi,
      'dienthoai': dienThoai,
      'mail': mail,
      'fax': fax,
      'website': website,
      'mota': moTa,
      'bidanh': biDanh,
      'trangthai_hoatdong': trangThaiHoatDong,
      'thoigian_tao': thoigianTao,
      'daxoa': daXoa,
    };
  }
}

// Class for Meeting Vote
class MeetingVote {
  final String id;
  final String title;
  final String scheduleId;

  MeetingVote({
    required this.id,
    required this.title,
    required this.scheduleId,
  });

  factory MeetingVote.fromJson(Map<String, dynamic> json) {
    return MeetingVote(
      id: json['id'] as String,
      title: json['title'] as String,
      scheduleId: json['scheduleId'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'title': title, 'scheduleId': scheduleId};
  }
}

// Class for Meeting Member Outside
class MeetingMemberOutside {
  final String id;
  final String scheduleId;
  final int userId;
  final String? fullName;
  final String? organ;
  final String? position;
  final bool online;
  final String? email;
  final bool activated;
  final String createdDate;
  final int createdBy;
  final String? modifiedDate;
  final int modifiedBy;
  final String? deletedDate;
  final int deletedBy;
  final User? user;
  final String? chucVu;
  final String? phone;
  final bool isSms;
  final bool isEmail;
  final String? reason;
  final int? status;

  MeetingMemberOutside({
    required this.id,
    required this.scheduleId,
    required this.userId,
    this.fullName,
    this.organ,
    this.position,
    required this.online,
    this.email,
    required this.activated,
    required this.createdDate,
    required this.createdBy,
    this.modifiedDate,
    required this.modifiedBy,
    this.deletedDate,
    required this.deletedBy,
    this.user,
    this.chucVu,
    this.phone,
    required this.isSms,
    required this.isEmail,
    this.reason,
    this.status,
  });

  factory MeetingMemberOutside.fromJson(Map<String, dynamic> json) {
    return MeetingMemberOutside(
      id: json['id'] as String,
      scheduleId: json['scheduleId'] as String,
      userId: json['userId'] as int,
      fullName: json['fullName'] as String?,
      organ: json['organ'] as String?,
      position: json['position'] as String?,
      online: json['online'] as bool,
      email: json['email'] as String?,
      activated: json['activated'] as bool,
      createdDate: json['createdDate'] as String,
      createdBy: json['createdBy'] as int,
      modifiedDate: json['modifiedDate'] as String?,
      modifiedBy: json['modifiedBy'] as int,
      deletedDate: json['deletedDate'] as String?,
      deletedBy: json['deletedBy'] as int,
      user:
          json['user'] != null
              ? User.fromJson(json['user'] as Map<String, dynamic>)
              : null,
      chucVu: json['chucVu'] as String?,
      phone: json['phone'] as String?,
      isSms: json['isSms'] as bool,
      isEmail: json['isEmail'] as bool,
      reason: json['reason'] as String?,
      status: json['status'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'scheduleId': scheduleId,
      'userId': userId,
      'fullName': fullName,
      'organ': organ,
      'position': position,
      'online': online,
      'email': email,
      'activated': activated,
      'createdDate': createdDate,
      'createdBy': createdBy,
      'modifiedDate': modifiedDate,
      'modifiedBy': modifiedBy,
      'deletedDate': deletedDate,
      'deletedBy': deletedBy,
      'user': user?.toJson(),
      'chucVu': chucVu,
      'phone': phone,
      'isSms': isSms,
      'isEmail': isEmail,
      'reason': reason,
      'status': status,
    };
  }
}

// Class for Meeting Member Inside
class MeetingMemberInside {
  final String id;
  final String scheduleId;
  final int userId;
  final String? fullName;
  final String? organ;
  final String? position;
  final bool online;
  final String? email;
  final bool activated;
  final String createdDate;
  final int createdBy;
  final String? modifiedDate;
  final int modifiedBy;
  final String? deletedDate;
  final int deletedBy;
  final User? user;
  final String? chucVu;
  final String? phone;
  final bool isSms;
  final bool isEmail;
  final String? reason;
  final int? status;

  MeetingMemberInside({
    required this.id,
    required this.scheduleId,
    required this.userId,
    this.fullName,
    this.organ,
    this.position,
    required this.online,
    this.email,
    required this.activated,
    required this.createdDate,
    required this.createdBy,
    this.modifiedDate,
    required this.modifiedBy,
    this.deletedDate,
    required this.deletedBy,
    this.user,
    this.chucVu,
    this.phone,
    required this.isSms,
    required this.isEmail,
    this.reason,
    this.status,
  });

  factory MeetingMemberInside.fromJson(Map<String, dynamic> json) {
    return MeetingMemberInside(
      id: json['id'] as String,
      scheduleId: json['scheduleId'] as String,
      userId: json['userId'] as int,
      fullName: json['fullName'] as String?,
      organ: json['organ'] as String?,
      position: json['position'] as String?,
      online: json['online'] as bool,
      email: json['email'] as String?,
      activated: json['activated'] as bool,
      createdDate: json['createdDate'] as String,
      createdBy: json['createdBy'] as int,
      modifiedDate: json['modifiedDate'] as String?,
      modifiedBy: json['modifiedBy'] as int,
      deletedDate: json['deletedDate'] as String?,
      deletedBy: json['deletedBy'] as int,
      user:
          json['user'] != null
              ? User.fromJson(json['user'] as Map<String, dynamic>)
              : null,
      chucVu: json['chucVu'] as String?,
      phone: json['phone'] as String?,
      isSms: json['isSms'] as bool,
      isEmail: json['isEmail'] as bool,
      reason: json['reason'] as String?,
      status: json['status'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'scheduleId': scheduleId,
      'userId': userId,
      'fullName': fullName,
      'organ': organ,
      'position': position,
      'online': online,
      'email': email,
      'activated': activated,
      'createdDate': createdDate,
      'createdBy': createdBy,
      'modifiedDate': modifiedDate,
      'modifiedBy': modifiedBy,
      'deletedDate': deletedDate,
      'deletedBy': deletedBy,
      'user': user?.toJson(),
      'chucVu': chucVu,
      'phone': phone,
      'isSms': isSms,
      'isEmail': isEmail,
      'reason': reason,
      'status': status,
    };
  }
}

// Class for Meeting Document
class MeetingDocument {
  final String id;
  final String title;
  final String scheduleId;
  final String url;
  final String originalName;
  final String? systemName;
  final String? organ;
  final int size;
  final String type;
  final int status;
  final String createdDate;
  final int createdBy;
  final String modifiedDate;
  final int modifiedBy;
  final String deletedDate;
  final int deletedBy;
  final bool isDeleted;
  final int thuTu;
  final String typeId;
  final User? user;
  final DocumentType? documentType;

  MeetingDocument({
    required this.id,
    required this.title,
    required this.scheduleId,
    required this.url,
    required this.originalName,
    this.systemName,
    this.organ,
    required this.size,
    required this.type,
    required this.status,
    required this.createdDate,
    required this.createdBy,
    required this.modifiedDate,
    required this.modifiedBy,
    required this.deletedDate,
    required this.deletedBy,
    required this.isDeleted,
    required this.thuTu,
    required this.typeId,
    this.user,
    this.documentType,
  });

  factory MeetingDocument.fromJson(Map<String, dynamic> json) {
    return MeetingDocument(
      id: json['id'] as String,
      title: json['title'] as String,
      scheduleId: json['scheduleId'] as String,
      url: json['url'] as String,
      originalName: json['originalName'] as String,
      systemName: json['systemName'] as String?,
      organ: json['organ'] as String?,
      size: json['size'] as int,
      type: json['type'] as String,
      status: json['status'] as int,
      createdDate: json['createdDate'] as String,
      createdBy: json['createdBy'] as int,
      modifiedDate: json['modifiedDate'] as String,
      modifiedBy: json['modifiedBy'] as int,
      deletedDate: json['deletedDate'] as String,
      deletedBy: json['deletedBy'] as int,
      isDeleted: json['isDeleted'] as bool,
      thuTu: json['thuTu'] as int,
      typeId: json['typeId'] as String,
      user:
          json['user'] != null
              ? User.fromJson(json['user'] as Map<String, dynamic>)
              : null,
      documentType:
          json['documentType'] != null
              ? DocumentType.fromJson(
                json['documentType'] as Map<String, dynamic>,
              )
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'scheduleId': scheduleId,
      'url': url,
      'originalName': originalName,
      'systemName': systemName,
      'organ': organ,
      'size': size,
      'type': type,
      'status': status,
      'createdDate': createdDate,
      'createdBy': createdBy,
      'modifiedDate': modifiedDate,
      'modifiedBy': modifiedBy,
      'deletedDate': deletedDate,
      'deletedBy': deletedBy,
      'isDeleted': isDeleted,
      'thuTu': thuTu,
      'typeId': typeId,
      'user': user?.toJson(),
      'documentType': documentType?.toJson(),
    };
  }
}

// Class for Document Type
class DocumentType {
  final String id;
  final String title;

  DocumentType({required this.id, required this.title});

  factory DocumentType.fromJson(Map<String, dynamic> json) {
    return DocumentType(
      id: json['id'] as String,
      title: json['title'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'title': title};
  }
}

// Class for Meeting Document Conclusion
class MeetingDocumentConclusion {
  final String id;
  final String title;

  MeetingDocumentConclusion({required this.id, required this.title});

  factory MeetingDocumentConclusion.fromJson(Map<String, dynamic> json) {
    return MeetingDocumentConclusion(
      id: json['id'] as String,
      title: json['title'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'title': title};
  }
}

// Class for Meeting Conclusion
class MeetingConclusion {
  final String id;
  final String title;

  MeetingConclusion({required this.id, required this.title});

  factory MeetingConclusion.fromJson(Map<String, dynamic> json) {
    return MeetingConclusion(
      id: json['id'] as String,
      title: json['title'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'title': title};
  }
}

// Class for Meeting Content
class MeetingContent {
  final String id;
  final String title;
  final String scheduleId;
  final String content;
  final String startTime;
  final String endTime;
  final int presenters;
  final String createdDate;
  final int createdBy;
  final String modifiedDate;
  final int modifiedBy;
  final String deletedDate;
  final int deletedBy;
  final int status;
  final bool isDeleted;
  final User? userPresenters;
  final String? tailieu;

  MeetingContent({
    required this.id,
    required this.title,
    required this.scheduleId,
    required this.content,
    required this.startTime,
    required this.endTime,
    required this.presenters,
    required this.createdDate,
    required this.createdBy,
    required this.modifiedDate,
    required this.modifiedBy,
    required this.deletedDate,
    required this.deletedBy,
    required this.status,
    required this.isDeleted,
    this.userPresenters,
    this.tailieu,
  });

  factory MeetingContent.fromJson(Map<String, dynamic> json) {
    return MeetingContent(
      id: json['id'] as String,
      title: json['title'] as String,
      scheduleId: json['scheduleId'] as String,
      content: json['content_'] as String,
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
      presenters: json['presenters'] as int,
      createdDate: json['createdDate'] as String,
      createdBy: json['createdBy'] as int,
      modifiedDate: json['modifiedDate'] as String,
      modifiedBy: json['modifiedBy'] as int,
      deletedDate: json['deletedDate'] as String,
      deletedBy: json['deletedBy'] as int,
      status: json['status'] as int,
      isDeleted: json['isDeleted'] as bool,
      userPresenters:
          json['userPresenters'] != null
              ? User.fromJson(json['userPresenters'] as Map<String, dynamic>)
              : null,
      tailieu: json['tailieu'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'scheduleId': scheduleId,
      'content_': content,
      'startTime': startTime,
      'endTime': endTime,
      'presenters': presenters,
      'createdDate': createdDate,
      'createdBy': createdBy,
      'modifiedDate': modifiedDate,
      'modifiedBy': modifiedBy,
      'deletedDate': deletedDate,
      'deletedBy': deletedBy,
      'status': status,
      'isDeleted': isDeleted,
      'userPresenters': userPresenters?.toJson(),
      'tailieu': tailieu,
    };
  }
}

// Class for Meeting Video
class MeetingVideo {
  final String id;
  final String title;

  MeetingVideo({required this.id, required this.title});

  factory MeetingVideo.fromJson(Map<String, dynamic> json) {
    return MeetingVideo(
      id: json['id'] as String,
      title: json['title'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'title': title};
  }
}

// Class for User
class User {
  final int id;
  final String tenDangNhap;
  final String tenDayDu;
  final String maToChuc;
  final String? maChucVu;
  final String? soDienThoai;
  final String? email;
  final int thoigianTao;
  final String? idWso2;
  final bool daXoa;
  final String? maDinhDanh;
  final OrganizationUnit? thongTinDonVi;
  final Position? thongTinChucVu;

  User({
    required this.id,
    required this.tenDangNhap,
    required this.tenDayDu,
    required this.maToChuc,
    this.maChucVu,
    this.soDienThoai,
    this.email,
    required this.thoigianTao,
    this.idWso2,
    required this.daXoa,
    this.maDinhDanh,
    this.thongTinDonVi,
    this.thongTinChucVu,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      tenDangNhap: json['ten_dangnhap'] as String,
      tenDayDu: json['ten_day_du'] as String,
      maToChuc: json['ma_tochuc'] as String,
      maChucVu: json['ma_chucvu'] as String?,
      soDienThoai: json['so_dien_thoai'] as String?,
      email: json['email'] as String?,
      thoigianTao: json['thoigian_tao'] as int,
      idWso2: json['id_wso2'] as String?,
      daXoa: json['daxoa'] as bool,
      maDinhDanh: json['ma_dinhdanh'] as String?,
      thongTinDonVi:
          json['thong_tin_don_vi'] != null
              ? OrganizationUnit.fromJson(
                json['thong_tin_don_vi'] as Map<String, dynamic>,
              )
              : null,
      thongTinChucVu:
          json['thong_tin_chuc_vu'] != null
              ? Position.fromJson(
                json['thong_tin_chuc_vu'] as Map<String, dynamic>,
              )
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ten_dangnhap': tenDangNhap,
      'ten_day_du': tenDayDu,
      'ma_tochuc': maToChuc,
      'ma_chucvu': maChucVu,
      'so_dien_thoai': soDienThoai,
      'email': email,
      'thoigian_tao': thoigianTao,
      'id_wso2': idWso2,
      'daxoa': daXoa,
      'ma_dinhdanh': maDinhDanh,
      'thong_tin_don_vi': thongTinDonVi?.toJson(),
      'thong_tin_chuc_vu': thongTinChucVu?.toJson(),
    };
  }
}

// Class for Position
class Position {
  final String ma;
  final String ten;
  final String? maHanhChinh;
  final int? thuTu;
  final String? moTa;
  final String trangThaiHoatDong;
  final int thoigianTao;
  final bool daXoa;

  Position({
    required this.ma,
    required this.ten,
    this.maHanhChinh,
    this.thuTu,
    this.moTa,
    required this.trangThaiHoatDong,
    required this.thoigianTao,
    required this.daXoa,
  });

  factory Position.fromJson(Map<String, dynamic> json) {
    return Position(
      ma: json['ma'] as String,
      ten: json['ten'] as String,
      maHanhChinh: json['ma_hanhchinh'] as String?,
      thuTu: json['thutu'] as int?,
      moTa: json['mota'] as String?,
      trangThaiHoatDong: json['trangthai_hoatdong'] as String,
      thoigianTao: json['thoigian_tao'] as int,
      daXoa: json['daxoa'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ma': ma,
      'ten': ten,
      'ma_hanhchinh': maHanhChinh,
      'thutu': thuTu,
      'mota': moTa,
      'trangthai_hoatdong': trangThaiHoatDong,
      'thoigian_tao': thoigianTao,
      'daxoa': daXoa,
    };
  }
}
