import 'package:dio/dio.dart';

import '../../../../core/errors/app_exception.dart';
import '../../models/order_model.dart';

abstract class OrdersRemoteDataSource {
  Future<List<OrderModel>> fetchMyOrders();
}

class OrdersRemoteDataSourceImpl implements OrdersRemoteDataSource {
  final Dio dio;

  OrdersRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<OrderModel>> fetchMyOrders() async {
    try {
      // Endpoint placeholder: adjust when backend orders module is available.
      final response = await dio.get('/orders');
      final data = response.data as List<dynamic>;
      return data
          .map((item) => OrderModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw AppException(e.message ?? 'Erro ao carregar pedidos');
    }
  }
}
