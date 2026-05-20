class CategoryModel {
  final String id;
  final String name;
  final String? iconKey;
  final int displayOrder;

  const CategoryModel({
    required this.id,
    required this.name,
    this.iconKey,
    this.displayOrder = 0,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      iconKey: json['iconKey']?.toString(),
      displayOrder: int.tryParse(json['displayOrder']?.toString() ?? '') ?? 0,
    );
  }
}