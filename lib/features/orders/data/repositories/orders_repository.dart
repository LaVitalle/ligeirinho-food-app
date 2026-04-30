import '../../models/order_model.dart';
import '../datasources/orders_remote_data_source.dart';

abstract class OrdersRepository {
  Future<List<OrderModel>> fetchMyOrders();
}

class OrdersRepositoryImpl implements OrdersRepository {
  final OrdersRemoteDataSource remoteDataSource;

  OrdersRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<OrderModel>> fetchMyOrders() {
    return remoteDataSource.fetchMyOrders();
  }
}
