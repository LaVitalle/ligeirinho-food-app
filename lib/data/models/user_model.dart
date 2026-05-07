class UserModel {
  final String id;
  final String name;
  final String email;
  final String? registration;
  final String? institution;
  final String? avatarUrl;
  final UserRole role;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.registration,
    this.institution,
    this.avatarUrl,
    required this.role,
  });

  UserModel copyWith({
    String? name,
    String? email,
    String? registration,
    String? institution,
    String? avatarUrl,
  }) {
    return UserModel(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      registration: registration ?? this.registration,
      institution: institution ?? this.institution,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role,
    );
  }
}

enum UserRole { client, vendor }
