import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

import 'package:quanlyhop/data/models/user_model.dart';

class AuthManager {
  static const String _tokenKey = 'auth_token';
  static const String _userDataKey = 'user_data';
  
  static AuthManager? _instance;
  static AuthManager get instance => _instance ??= AuthManager._();
  AuthManager._();

  // Cấu hình FlutterSecureStorage
  static const _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
      // Sử dụng biometric authentication nếu có
      // requiresAuthentication: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  String? _token;
  UserModel? _currentUser;

  String? get token => _token;
  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _token != null && _currentUser != null;

  // Lưu thông tin đăng nhập
  Future<void> saveAuthData(UserModel user) async {
    try {
      _token = user.token;
      _currentUser = user;
      
      // Lưu token và user data vào secure storage
      await _secureStorage.write(key: _tokenKey, value: user.token);
      await _secureStorage.write(key: _userDataKey, value: jsonEncode(user.toJson()));
    } catch (e) {
      throw Exception('Không thể lưu thông tin đăng nhập: $e');
    }
  }

  // Khôi phục thông tin đăng nhập khi khởi động app
  Future<void> loadAuthData() async {
    try {
      _token = await _secureStorage.read(key: _tokenKey);
      
      final userData = await _secureStorage.read(key: _userDataKey);
      if (userData != null && userData.isNotEmpty) {
        try {
          _currentUser = UserModel.fromJson(jsonDecode(userData));
        } catch (e) {
          // Nếu có lỗi parse data, xóa dữ liệu cũ
          debugPrint('Error parsing user data: $e');
          await clearAuthData();
        }
      }
    } catch (e) {
      debugPrint('Error loading auth data: $e');
      await clearAuthData();
    }
  }

  // Xóa thông tin đăng nhập (logout)
  Future<void> clearAuthData() async {
    try {
      _token = null;
      _currentUser = null;
      
      await _secureStorage.delete(key: _tokenKey);
      await _secureStorage.delete(key: _userDataKey);
    } catch (e) {
      debugPrint('Error clearing auth data: $e');
      // Xóa toàn bộ secure storage nếu có lỗi
      await _secureStorage.deleteAll();
    }
  }

  // Xóa toàn bộ dữ liệu secure storage (dùng khi cần reset hoàn toàn)
  Future<void> clearAllSecureData() async {
    try {
      await _secureStorage.deleteAll();
      _token = null;
      _currentUser = null;
    } catch (e) {
      debugPrint('Error clearing all secure data: $e');
    }
  }

  // Kiểm tra token có hết hạn không
  bool isTokenExpired() {
    if (_token == null) return true;
    
    try {
      // Decode JWT token để lấy thời gian hết hạn
      final parts = _token!.split('.');
      if (parts.length != 3) return true;
      
      final payload = parts[1];
      // Thêm padding nếu cần
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final map = jsonDecode(decoded) as Map<String, dynamic>;
      
      final exp = map['exp'] as int?;
      if (exp == null) return true;
      
      final expirationDate = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      return DateTime.now().isAfter(expirationDate);
    } catch (e) {
      debugPrint('Error checking token expiration: $e');
      return true;
    }
  }

  // Kiểm tra và làm mới token nếu cần
  Future<bool> validateToken() async {
    if (!isLoggedIn || isTokenExpired()) {
      await clearAuthData();
      return false;
    }
    return true;
  }

  // Kiểm tra quyền của user
  bool hasRole(String roleCode) {
    if (_currentUser == null) return false;
    return _currentUser!.roles.any((role) => role.ma == roleCode);
  }

  // Lấy danh sách quyền
  List<String> getUserRoles() {
    if (_currentUser == null) return [];
    return _currentUser!.roles.map((role) => role.ma).toList();
  }

  // Lấy thông tin user hiện tại
  String? getCurrentUserName() {
    return _currentUser?.data.tenDayDu;
  }

  String? getCurrentUsername() {
    return _currentUser?.data.tenDangNhap;
  }

  // Kiểm tra user có thuộc đơn vị nào không
  bool hasOrganization() {
    return _currentUser?.data.donVi != null;
  }

  // Lấy thông tin đơn vị
  DonVi? getUserOrganization() {
    return _currentUser?.data.donVi;
  }
}
