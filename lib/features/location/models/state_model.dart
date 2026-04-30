class StateModel {
  final int id;
  final String name;
  final String abbreviation;

  StateModel({
    required this.id,
    required this.name,
    required this.abbreviation,
  });

  factory StateModel.fromJson(Map<String, dynamic> json) {
    return StateModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      abbreviation: json['abbreviation'] ?? '',
    );
  }
}
