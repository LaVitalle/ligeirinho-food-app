import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/repositories/orders_repository.dart';
import 'orders_state.dart';

class OrdersCubit extends Cubit<OrdersState> {
  final OrdersRepository repository;

  OrdersCubit({required this.repository}) : super(OrdersInitial());

  Future<void> fetchOrders() async {
    emit(OrdersLoading());
    try {
      final orders = await repository.fetchMyOrders();
      emit(OrdersLoaded(orders: orders));
    } catch (e) {
      emit(OrdersError(message: e.toString()));
    }
  }
}
