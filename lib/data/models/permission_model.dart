class PermissionModel {
  final String ma;
  final String ten;
  final String mota;
  final int thoigianTao;

  PermissionModel({
    required this.ma,
    required this.ten,
    required this.mota,
    required this.thoigianTao,
  });

  // không tạo đối tượng mới nếu thấy đã có một đối tượng sẵn rồi
  // - hoạt động như Singleton Pattern
  // chuyển đổi json thành đối tượng
  factory PermissionModel.fromJson(Map<String, dynamic> json) {
    return PermissionModel(
      ma: json['ma']?.toString() ?? '',
      ten: json['ten']?.toString() ?? '',
      mota: json['mota']?.toString() ?? '',
      thoigianTao: json['thoigian_tao'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'ma': ma, 'ten': ten, 'mota': mota, 'thoigian_tao': thoigianTao};
  }

  // kiểm tra quyền Thêm lịch họp mới
  // một thuộc tính được tính toán nên phải có get
  // nếu không thì là hàm => phải có tham số
  bool get isSchedulePermission =>
      mota.contains('Schedule') || mota.contains('ScheduleOrgan');

  bool get isSchedule => mota.contains('Schedule');
  bool get isScheduleOrgan => mota.contains('ScheduleOrgan');

  // ghi đè
  // mặc định toString sẽ trả về "Instance of 'PermissionModel'"
  @override
  String toString() {
    return 'PermissionModel(ma: $ma, ten: $ten, mota: $mota, thoigian_tao: $thoigianTao)';
  }
}
