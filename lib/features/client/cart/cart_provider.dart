import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/models/cart_model.dart';
import '../../../data/models/product_model.dart';

/// Chave usada para persistência local do carrinho.
const _kCartKey = 'saved_cart';

class CartNotifier extends StateNotifier<List<CartStore>> {
  CartNotifier() : super([]) {
    _loadFromStorage();
  }

  /// Carrega o carrinho salvo no SharedPreferences ao iniciar.
  Future<void> _loadFromStorage() async {
    try {
      final sp = await SharedPreferences.getInstance();
      final raw = sp.getString(_kCartKey);
      if (raw == null || raw.isEmpty) return;

      final decoded = json.decode(raw) as List<dynamic>;
      state = decoded
          .whereType<Map<String, dynamic>>()
          .map(CartStore.fromJson)
          .toList();
    } catch (_) {
      // JSON corrompido — ignora e inicia com carrinho vazio
    }
  }

  /// Salva o estado atual do carrinho no SharedPreferences.
  Future<void> _saveToStorage() async {
    try {
      final sp = await SharedPreferences.getInstance();
      final encoded = json.encode(state.map((s) => s.toJson()).toList());
      await sp.setString(_kCartKey, encoded);
    } catch (_) {}
  }

  void addItem(ProductModel product, String storeName, int qty,
      List<SelectedAdditional> additionals, List<String> removed) {
    final storeIndex = state.indexWhere((s) => s.storeId == product.storeId);
    final newItem = CartItem(
      product: product,
      quantity: qty,
      additionals: additionals,
      removedIngredients: removed,
    );

    if (storeIndex == -1) {
      state = [
        ...state,
        CartStore(storeId: product.storeId, storeName: storeName, items: [newItem])
      ];
    } else {
      final store = state[storeIndex];
      final itemIndex = store.items.indexWhere((i) => i.product.id == product.id);
      List<CartItem> newItems;
      if (itemIndex == -1) {
        newItems = [...store.items, newItem];
      } else {
        newItems = [...store.items];
        newItems[itemIndex] = newItems[itemIndex].copyWith(
            quantity: newItems[itemIndex].quantity + qty);
      }
      final newStores = [...state];
      newStores[storeIndex] =
          CartStore(storeId: store.storeId, storeName: store.storeName, items: newItems);
      state = newStores;
    }
    _saveToStorage();
  }

  void updateItemQty(String storeId, String productId, int qty) {
    state = state.map((store) {
      if (store.storeId != storeId) return store;
      final items = store.items.map((item) {
        if (item.product.id != productId) return item;
        return item.copyWith(quantity: qty);
      }).where((item) => item.quantity > 0).toList();
      return CartStore(storeId: store.storeId, storeName: store.storeName, items: items);
    }).where((store) => store.items.isNotEmpty).toList();
    _saveToStorage();
  }

  void removeStore(String storeId) {
    state = state.where((s) => s.storeId != storeId).toList();
    _saveToStorage();
  }

  void clear() {
    state = [];
    _saveToStorage();
  }

  double get total => state.fold(0.0, (sum, s) => sum + s.subtotal);

  int get itemCount =>
      state.fold(0, (sum, s) => sum + s.items.fold(0, (si, i) => si + i.quantity));
}

final cartProvider = StateNotifierProvider<CartNotifier, List<CartStore>>((ref) {
  return CartNotifier();
});

final cartTotalProvider = Provider<double>((ref) {
  final cart = ref.watch(cartProvider.notifier);
  ref.watch(cartProvider);
  return cart.total;
});

final cartCountProvider = Provider<int>((ref) {
  final cart = ref.watch(cartProvider.notifier);
  ref.watch(cartProvider);
  return cart.itemCount;
});
