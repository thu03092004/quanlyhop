// login
class UserModel {
  final String user;
  final String? token;
  UserModel({required this.user, this.token});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(user: json['user'] ?? '', token: json['token']);
  }
}
