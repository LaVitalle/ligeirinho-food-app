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

  factory AdditionalModel.fromJson(Map<String, dynamic> json) {
    return AdditionalModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      price: double.tryParse(json['price']?.toString() ?? '') ?? 0,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  /// Serializa para JSON (persistência local do carrinho).
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'price': price,
        'isActive': isActive,
      };
}

class ProductModel {
  final String id;
  final String storeId;
  final String categoryId;
  final String name;
  final String description;
  final double price;
  final String? imageUrl;
  final bool isActive;
  final bool isFeatured;
  final DateTime? createdAt;
  final List<AdditionalModel> additionals;
  final List<String> removableIngredients;
  final String? badge;

  const ProductModel({
    required this.id,
    required this.storeId,
    this.categoryId = '',
    required this.name,
    required this.description,
    required this.price,
    this.imageUrl,
    this.isActive = true,
    this.isFeatured = false,
    this.createdAt,
    this.additionals = const [],
    this.removableIngredients = const [],
    this.badge,
  });

  ProductModel copyWith({
    String? id,
    String? storeId,
    String? categoryId,
    String? name,
    String? description,
    double? price,
    String? imageUrl,
    bool? isActive,
    bool? isFeatured,
    DateTime? createdAt,
    List<AdditionalModel>? additionals,
    List<String>? removableIngredients,
    String? badge,
  }) {
    return ProductModel(
      id: id ?? this.id,
      storeId: storeId ?? this.storeId,
      categoryId: categoryId ?? this.categoryId,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      isActive: isActive ?? this.isActive,
      isFeatured: isFeatured ?? this.isFeatured,
      createdAt: createdAt ?? this.createdAt,
      additionals: additionals ?? this.additionals,
      removableIngredients: removableIngredients ?? this.removableIngredients,
      badge: badge ?? this.badge,
    );
  }

  factory ProductModel.fromJson(
    Map<String, dynamic> json, {
    List<AdditionalModel> additionals = const [],
    List<String> removableIngredients = const [],
  }) {
    // Suporte a adicionais embutidos no JSON (persistência local)
    final localAdditionals = additionals.isNotEmpty
        ? additionals
        : (json['additionals'] as List<dynamic>?)
                ?.whereType<Map<String, dynamic>>()
                .map(AdditionalModel.fromJson)
                .toList() ??
            const [];
    final localRemovable = removableIngredients.isNotEmpty
        ? removableIngredients
        : (json['removableIngredients'] as List<dynamic>?)
                ?.whereType<String>()
                .toList() ??
            const [];

    return ProductModel(
      id: json['id']?.toString() ?? '',
      storeId: json['canteenId']?.toString() ?? json['storeId']?.toString() ?? '',
      categoryId: json['categoryId']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      price: double.tryParse(json['price']?.toString() ?? '') ?? 0,
      imageUrl: json['photoUrl']?.toString() ?? json['imageUrl']?.toString(),
      isActive: json['isActive'] as bool? ?? true,
      isFeatured: json['isFeatured'] as bool? ?? false,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
      additionals: localAdditionals,
      removableIngredients: localRemovable,
    );
  }

  /// Serializa para JSON (persistência local do carrinho).
  Map<String, dynamic> toJson() => {
        'id': id,
        'storeId': storeId,
        'categoryId': categoryId,
        'name': name,
        'description': description,
        'price': price,
        'imageUrl': imageUrl,
        'isActive': isActive,
        'isFeatured': isFeatured,
        'badge': badge,
        'additionals': additionals.map((a) => a.toJson()).toList(),
        'removableIngredients': removableIngredients,
      };
}
