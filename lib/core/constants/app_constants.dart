class AppConstants {
  static const String baseUrl = 'https://quanlyhop-api.mae.gov.vn';
  static const String loginEndpoint = '/Auth/dang_nhap';
  static const String permissionEndpoint =
      '/api/htt_qtht/phan_quyen_vai_tro_nguoi_dung/quyen_nguoi_dung';
  static const String meetingInsertEndpoint = '/meeting/MeetingSchedule/Insert';
  // gọi API để lấy alias cho lịch
  static const String thongTinNguoiDung = '/api/htt_qtht/thong_tin_nguoi_dung';
  // lấy thông tin lịch
  static const String calendarDetail = '/meeting/MeetingSchedule/GetById';
  // lấy thông tin tài liệu họp
  static const String docsTab = '/meeting/MeetingDocument/GetByScheduleId';
  // xem tài liệu họp
  static const String viewDoc = '/minio/Export_Object';
  // tải tài liệu họp
  static const String downloadDoc = '/minio/GetDownloadUrlObject';
}
