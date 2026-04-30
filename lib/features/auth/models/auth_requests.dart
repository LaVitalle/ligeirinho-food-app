class RegisterRequestModel {
  final String fullName;
  final String email;
  final String password;
  final String role;
  final String? phoneNumber;
  final String? institutionId;
  final String? canteenId;

  RegisterRequestModel({
    required this.fullName,
    required this.email,
    required this.password,
    required this.role,
    this.phoneNumber,
    this.institutionId,
    this.canteenId,
  });

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'email': email,
      'password': password,
      'role': role,
      'phoneNumber': phoneNumber,
      'institutionId': institutionId,
      'canteenId': canteenId,
    };
  }
}

class ResetPasswordRequestModel {
  final String email;
  final String code;
  final String newPassword;

  ResetPasswordRequestModel({
    required this.email,
    required this.code,
    required this.newPassword,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'code': code,
      'newPassword': newPassword,
    };
  }
}
