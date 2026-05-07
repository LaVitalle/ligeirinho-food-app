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
}

class SelectedAdditional {
  final AdditionalModel additional;
  final int qty;
  const SelectedAdditional({required this.additional, required this.qty});
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
}
