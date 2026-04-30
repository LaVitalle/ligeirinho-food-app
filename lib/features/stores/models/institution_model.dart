class InstitutionModel {
  final String id;
  final String name;
  final int? stateId;
  final int? cityId;
  final String? photoUrl;

  InstitutionModel({
    required this.id,
    required this.name,
    this.stateId,
    this.cityId,
    this.photoUrl,
  });

  factory InstitutionModel.fromJson(Map<String, dynamic> json) {
    return InstitutionModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      stateId: json['stateId'],
      cityId: json['cityId'],
      photoUrl: json['photoUrl'],
    );
  }
}
