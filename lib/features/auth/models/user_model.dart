class UserModel {
  final String id;
  final String fullName;
  final String email;
  final String? phoneNumber;
  final String? profilePhotoUrl;
  final String role;
  final String? institutionId;
  final String? canteenId;

  UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    this.phoneNumber,
    this.profilePhotoUrl,
    required this.role,
    this.institutionId,
    this.canteenId,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'],
      profilePhotoUrl: json['profilePhotoUrl'],
      role: json['role'] ?? 'CLIENT',
      institutionId: json['institutionId'],
      canteenId: json['canteenId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'phoneNumber': phoneNumber,
      'profilePhotoUrl': profilePhotoUrl,
      'role': role,
      'institutionId': institutionId,
      'canteenId': canteenId,
    };
  }
}
