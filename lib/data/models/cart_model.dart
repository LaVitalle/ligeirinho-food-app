import 'product_model.dart';

class CartItem {
  final ProductModel product;
  final int quantity;
  final List<SelectedAdditional> additionals;
  final List<String> removedIngredients;

  const CartItem({
    required this.product,
    required this.quantity,
    this.additionals = const [],
    this.removedIngredients = const [],
  });

  double get total =>
      (product.price +
          additionals.fold(0.0, (sum, a) => sum + a.additional.price * a.qty)) *
      quantity;

  CartItem copyWith({int? quantity, List<SelectedAdditional>? additionals}) {
    return CartItem(
      product: product,
      quantity: quantity ?? this.quantity,
      additionals: additionals ?? this.additionals,
      removedIngredients: removedIngredients,
    );
  }

  /// Serializa para JSON (persistência local).
  Map<String, dynamic> toJson() => {
        'product': product.toJson(),
        'quantity': quantity,
        'additionals': additionals.map((a) => a.toJson()).toList(),
        'removedIngredients': removedIngredients,
      };

  /// Reconstrói a partir de JSON salvo localmente.
  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      product: ProductModel.fromJson(json['product'] as Map<String, dynamic>),
      quantity: json['quantity'] as int? ?? 1,
      additionals: (json['additionals'] as List<dynamic>?)
              ?.whereType<Map<String, dynamic>>()
              .map(SelectedAdditional.fromJson)
              .toList() ??
          const [],
      removedIngredients: (json['removedIngredients'] as List<dynamic>?)
              ?.whereType<String>()
              .toList() ??
          const [],
    );
  }
}

class SelectedAdditional {
  final AdditionalModel additional;
  final int qty;
  const SelectedAdditional({required this.additional, required this.qty});

  Map<String, dynamic> toJson() => {
        'additional': additional.toJson(),
        'qty': qty,
      };

  factory SelectedAdditional.fromJson(Map<String, dynamic> json) {
    return SelectedAdditional(
      additional:
          AdditionalModel.fromJson(json['additional'] as Map<String, dynamic>),
      qty: json['qty'] as int? ?? 1,
    );
  }
}

class CartStore {
  final String storeId;
  final String storeName;
  final List<CartItem> items;

  const CartStore({
    required this.storeId,
    required this.storeName,
    required this.items,
  });

  double get subtotal => items.fold(0.0, (sum, i) => sum + i.total);

  /// Serializa para JSON (persistência local).
  Map<String, dynamic> toJson() => {
        'storeId': storeId,
        'storeName': storeName,
        'items': items.map((i) => i.toJson()).toList(),
      };

  /// Reconstrói a partir de JSON salvo localmente.
  factory CartStore.fromJson(Map<String, dynamic> json) {
    return CartStore(
      storeId: json['storeId']?.toString() ?? '',
      storeName: json['storeName']?.toString() ?? '',
      items: (json['items'] as List<dynamic>?)
              ?.whereType<Map<String, dynamic>>()
              .map(CartItem.fromJson)
              .toList() ??
          const [],
    );
  }
}
