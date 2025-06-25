// file model của thong_tin_nguoi_dung và gọi get ở file calendar_service.dart
class UserInfo {
  final int id;
  final String tenDangNhap;
  final String tenDayDu;
  final String? maToChuc;
  final String? maChucVu;
  final String? soDienThoai;
  final String? email;
  final int thoigianTao;
  final String? idWso2;
  final bool daxoa;
  final String? maDinhDanh;
  final ThongTinDonVi? thongTinDonVi;
  final ThongTinChucVu? thongTinChucVu;

  UserInfo({
    required this.id,
    required this.tenDangNhap,
    required this.tenDayDu,
    this.maToChuc,
    this.maChucVu,
    this.soDienThoai,
    this.email,
    required this.thoigianTao,
    this.idWso2,
    required this.daxoa,
    this.maDinhDanh,
    this.thongTinDonVi,
    this.thongTinChucVu,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      id: json['id'],
      tenDangNhap: json['ten_dangnhap'],
      tenDayDu: json['ten_day_du'],
      maToChuc: json['ma_tochuc'],
      maChucVu: json['ma_chucvu'],
      soDienThoai: json['so_dien_thoai'],
      email: json['email'],
      thoigianTao: json['thoigian_tao'],
      idWso2: json['id_wso2'],
      daxoa: json['daxoa'],
      maDinhDanh: json['ma_dinhdanh'],
      thongTinDonVi:
          json['thong_tin_don_vi'] != null
              ? ThongTinDonVi.fromJson(json['thong_tin_don_vi'])
              : null,
      thongTinChucVu:
          json['thong_tin_chuc_vu'] != null
              ? ThongTinChucVu.fromJson(json['thong_tin_chuc_vu'])
              : null,
    );
  }
}

class ThongTinDonVi {
  final int id;
  final String ma;
  final String? maParent;
  final String ten;
  final String maHanhChinh;
  final String? diachi;
  final String? dienthoai;
  final String? mail;
  final String fax;
  final String website;
  final String mota;
  final String bidanh;
  final String trangthaiHoatdong;
  final int thoigianTao;
  final bool daxoa;

  ThongTinDonVi({
    required this.id,
    required this.ma,
    this.maParent,
    required this.ten,
    required this.maHanhChinh,
    this.diachi,
    this.dienthoai,
    this.mail,
    required this.fax,
    required this.website,
    required this.mota,
    required this.bidanh,
    required this.trangthaiHoatdong,
    required this.thoigianTao,
    required this.daxoa,
  });

  factory ThongTinDonVi.fromJson(Map<String, dynamic> json) {
    return ThongTinDonVi(
      id: json['id'],
      ma: json['ma'],
      maParent: json['ma_parent'],
      ten: json['ten'],
      maHanhChinh: json['ma_hanhchinh'],
      diachi: json['diachi'],
      dienthoai: json['dienthoai'],
      mail: json['mail'],
      fax: json['fax'],
      website: json['website'],
      mota: json['mota'],
      bidanh: json['bidanh'],
      trangthaiHoatdong: json['trangthai_hoatdong'],
      thoigianTao: json['thoigian_tao'],
      daxoa: json['daxoa'],
    );
  }
}

class ThongTinChucVu {
  final String ma;
  final String ten;
  final String maHanhChinh;
  final int thutu;
  final String? mota;
  final String trangthaiHoatdong;
  final int thoigianTao;
  final bool daxoa;

  ThongTinChucVu({
    required this.ma,
    required this.ten,
    required this.maHanhChinh,
    required this.thutu,
    this.mota,
    required this.trangthaiHoatdong,
    required this.thoigianTao,
    required this.daxoa,
  });

  factory ThongTinChucVu.fromJson(Map<String, dynamic> json) {
    return ThongTinChucVu(
      ma: json['ma'],
      ten: json['ten'],
      maHanhChinh: json['ma_hanhchinh'],
      thutu: json['thutu'],
      mota: json['mota'],
      trangthaiHoatdong: json['trangthai_hoatdong'],
      thoigianTao: json['thoigian_tao'],
      daxoa: json['daxoa'],
    );
  }
}
