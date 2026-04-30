class CartItemModel {
  final String productId;
  final String name;
  final double unitPrice;
  final int quantity;

  CartItemModel({
    required this.productId,
    required this.name,
    required this.unitPrice,
    required this.quantity,
  });

  double get total => unitPrice * quantity;

  CartItemModel copyWith({
    String? productId,
    String? name,
    double? unitPrice,
    int? quantity,
  }) {
    return CartItemModel(
      productId: productId ?? this.productId,
      name: name ?? this.name,
      unitPrice: unitPrice ?? this.unitPrice,
      quantity: quantity ?? this.quantity,
    );
  }
}
