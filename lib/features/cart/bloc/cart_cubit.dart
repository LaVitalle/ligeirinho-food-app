import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/cart_item_model.dart';
import 'cart_state.dart';

class CartCubit extends Cubit<CartState> {
  CartCubit() : super(const CartState());

  void addItem(CartItemModel item) {
    final current = List<CartItemModel>.from(state.items);
    final index = current.indexWhere((x) => x.productId == item.productId);

    if (index >= 0) {
      current[index] = current[index].copyWith(
        quantity: current[index].quantity + item.quantity,
      );
    } else {
      current.add(item);
    }

    emit(state.copyWith(items: current));
  }

  void removeItem(String productId) {
    final current = state.items.where((item) => item.productId != productId).toList();
    emit(state.copyWith(items: current));
  }

  void clear() {
    emit(const CartState());
  }
}
