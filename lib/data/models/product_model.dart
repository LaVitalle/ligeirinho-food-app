class AdditionalModel {
  final String id;
  final String name;
  final double price;
  final bool isActive;
  final String unit;
  final int maxPerOrder;

  const AdditionalModel({
    required this.id,
    required this.name,
    required this.price,
    this.isActive = true,
    this.unit = 'Unitário',
    this.maxPerOrder = 5,
  });
}

class ProductModel {
  final String id;
  final String storeId;
  final String name;
  final String description;
  final double price;
  final String? imageUrl;
  final bool isActive;
  final List<AdditionalModel> additionals;
  final List<String> removableIngredients;
  final String? badge;

  const ProductModel({
    required this.id,
    required this.storeId,
    required this.name,
    required this.description,
    required this.price,
    this.imageUrl,
    this.isActive = true,
    this.additionals = const [],
    this.removableIngredients = const [],
    this.badge,
  });
}
