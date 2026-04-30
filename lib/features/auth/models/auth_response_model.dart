import 'user_model.dart';

class AuthResponseModel {
  final String accessToken;
  final String? refreshToken;
  final UserModel user;

  AuthResponseModel({
    required this.accessToken,
    this.refreshToken,
    required this.user,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    final payload = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;

    return AuthResponseModel(
      accessToken: payload['accessToken'] ?? '',
      refreshToken: payload['refreshToken'],
      user: UserModel.fromJson(payload['user'] ?? {}),
    );
  }

  AuthResponseModel copyWith({
    String? accessToken,
    String? refreshToken,
    UserModel? user,
  }) {
    return AuthResponseModel(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      user: user ?? this.user,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'user': user.toJson(),
    };
  }
}
