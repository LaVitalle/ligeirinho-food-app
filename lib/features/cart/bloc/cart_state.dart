import 'package:equatable/equatable.dart';

import '../models/cart_item_model.dart';

class CartState extends Equatable {
  final List<CartItemModel> items;

  const CartState({this.items = const []});

  double get total => items.fold(0, (acc, item) => acc + item.total);

  CartState copyWith({List<CartItemModel>? items}) {
    return CartState(items: items ?? this.items);
  }

  @override
  List<Object?> get props => [items];
}
