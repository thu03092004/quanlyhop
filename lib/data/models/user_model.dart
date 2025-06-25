class UserModel {
  final bool state;
  final String token;
  final UserData data;
  final List<Role> roles;

  UserModel({
    required this.state,
    required this.token,
    required this.data,
    required this.roles,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      state: json['state'] ?? false,
      token: json['token'] ?? '',
      data: UserData.fromJson(json['data'] ?? {}),
      roles:
          (json['role'] as List<dynamic>?)
              ?.map((role) => Role.fromJson(role))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'state': state,
      'token': token,
      'data': data.toJson(),
      'role': roles.map((role) => role.toJson()).toList(),
    };
  }
}

class UserData {
  final int id;
  final String tenDangNhap;
  final String tenDayDu;
  final String? maToChuc;
  final DonVi? donVi;
  final ChucVu? chucVu;
  final String? email;
  final String? soDienThoai;

  UserData({
    required this.id,
    required this.tenDangNhap,
    required this.tenDayDu,
    this.maToChuc,
    this.donVi,
    this.chucVu,
    this.email,
    this.soDienThoai,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['id'] ?? 0,
      tenDangNhap: json['ten_dangnhap'] ?? '',
      tenDayDu: json['ten_day_du'] ?? '',
      maToChuc: json['ma_tochuc'],
      donVi: json['donvi'] != null ? DonVi.fromJson(json['donvi']) : null,
      chucVu: json['chucvu'] != null ? ChucVu.fromJson(json['chucvu']) : null,
      email: json['email'],
      soDienThoai: json['so_dien_thoai'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ten_dangnhap': tenDangNhap,
      'ten_day_du': tenDayDu,
      'ma_tochuc': maToChuc,
      'donvi': donVi?.toJson(),
      'chucvu': chucVu?.toJson(),
      'email': email,
      'so_dien_thoai': soDienThoai,
    };
  }
}

class DonVi {
  final int id;
  final String ma;
  final String ten;
  final String maHanhChinh;
  final String? diaChi;
  final String? dienThoai;
  final String? mail;
  final String? fax;
  final String? website;

  DonVi({
    required this.id,
    required this.ma,
    required this.ten,
    required this.maHanhChinh,
    this.diaChi,
    this.dienThoai,
    this.mail,
    this.fax,
    this.website,
  });

  factory DonVi.fromJson(Map<String, dynamic> json) {
    return DonVi(
      id: json['id'] ?? 0,
      ma: json['ma'] ?? '',
      ten: json['ten'] ?? '',
      maHanhChinh: json['ma_hanhchinh'] ?? '',
      diaChi: json['diachi'],
      dienThoai: json['dienthoai'],
      mail: json['mail'],
      fax: json['fax'],
      website: json['website'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ma': ma,
      'ten': ten,
      'ma_hanhchinh': maHanhChinh,
      'diachi': diaChi,
      'dienthoai': dienThoai,
      'mail': mail,
      'fax': fax,
      'website': website,
    };
  }
}

class ChucVu {
  final String ma;
  final String ten;
  final String maHanhChinh;

  ChucVu({required this.ma, required this.ten, required this.maHanhChinh});

  factory ChucVu.fromJson(Map<String, dynamic> json) {
    return ChucVu(
      ma: json['ma'] ?? '',
      ten: json['ten'] ?? '',
      maHanhChinh: json['ma_hanhchinh'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'ma': ma, 'ten': ten, 'ma_hanhchinh': maHanhChinh};
  }
}

class Role {
  final String ma;
  final String ten;
  final String moTa;
  final int thoiGianTao;

  Role({
    required this.ma,
    required this.ten,
    required this.moTa,
    required this.thoiGianTao,
  });

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      ma: json['ma'] ?? '',
      ten: json['ten'] ?? '',
      moTa: json['mota'] ?? '',
      thoiGianTao: json['thoigian_tao'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'ma': ma, 'ten': ten, 'mota': moTa, 'thoigian_tao': thoiGianTao};
  }
}
