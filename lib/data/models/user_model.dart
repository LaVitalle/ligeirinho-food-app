class UserModel {
  final String id;
  final String name;
  final String email;
  final String? registration;
  final String? institution;
  final String? avatarUrl;
  final String? phoneNumber;
  final UserRole role;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.registration,
    this.institution,
    this.avatarUrl,
    this.phoneNumber,
    required this.role,
  });

  UserModel copyWith({
    String? name,
    String? email,
    String? registration,
    String? institution,
    String? avatarUrl,
    String? phoneNumber,
  }) {
    return UserModel(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      registration: registration ?? this.registration,
      institution: institution ?? this.institution,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      role: role,
    );
  }

  /// Serializa o usuário para JSON (persistência local).
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'registration': registration,
        'institution': institution,
        'avatarUrl': avatarUrl,
        'phoneNumber': phoneNumber,
        'role': role == UserRole.vendor ? 'vendor' : 'client',
      };

  /// Reconstrói o usuário a partir de JSON salvo localmente.
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      registration: json['registration']?.toString(),
      institution: json['institution']?.toString(),
      avatarUrl: json['avatarUrl']?.toString(),
      phoneNumber: json['phoneNumber']?.toString(),
      role: json['role'] == 'vendor' ? UserRole.vendor : UserRole.client,
    );
  }
}

enum UserRole { client, vendor }
