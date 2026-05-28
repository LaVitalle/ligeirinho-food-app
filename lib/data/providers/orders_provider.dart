import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../../core/services/api_service.dart';
import '../models/order_model.dart';
import 'dart:convert';

class OrdersApiService {
  final ApiService _api;

  OrdersApiService([ApiService? api]) : _api = api ?? ApiService();

  Future<List<dynamic>> fetchVendorOrders() async {
    final res = await _api.get('/orders/canteen');
    if (res.statusCode >= 300) {
      throw Exception('Failed to fetch orders');
    }
    final body = json.decode(res.body);
    final data = body['data'] ?? [];
    return data as List<dynamic>;
  }

  Future<void> advanceOrder(String orderId) async {
    final token = await _api.getToken();
    final uri = Uri.parse('${_api.baseUrl}/orders/$orderId/advance');
    final res = await http.patch(
      uri,
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
    if (res.statusCode >= 300) {
      throw Exception('Failed to advance order');
    }
  }
}

final ordersApiProvider = Provider<OrdersApiService>((ref) {
  return OrdersApiService(ApiService());
});

final vendorOrdersProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  final api = ref.read(ordersApiProvider);
  return api.fetchVendorOrders();
});
