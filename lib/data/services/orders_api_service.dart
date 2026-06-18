import 'package:http/http.dart' as http;
import '../../core/services/api_service.dart';
import 'dart:convert';

/// Service de acesso à API de pedidos (camada Model/Service do MVVM).
///
/// Responsável exclusivamente pela comunicação HTTP com os endpoints de
/// pedidos do backend. Não contém lógica de estado nem de apresentação —
/// essa responsabilidade pertence aos ViewModels (providers).
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

  Future<void> clearCart() async {
    final token = await _api.getToken();
    final uri = Uri.parse('${_api.baseUrl}/cart');
    final res = await http.delete(
      uri,
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
    if (res.statusCode >= 300) {
      throw Exception('Failed to clear cart');
    }
  }

  Future<void> addCartItem({
    required String productId,
    required int quantity,
    String? note,
    List<String>? extraIds,
  }) async {
    final body = {
      'productId': productId,
      'quantity': quantity,
      if (note != null && note.isNotEmpty) 'note': note,
      if (extraIds != null && extraIds.isNotEmpty) 'extraIds': extraIds,
    };
    final res = await _api.post('/cart/items', body);
    if (res.statusCode >= 300) {
      throw Exception('Failed to add item to cart: ${res.body}');
    }
  }

  Future<void> createOrder() async {
    final res = await _api.post('/orders', {});
    if (res.statusCode >= 300) {
      throw Exception('Failed to create order: ${res.body}');
    }
  }

  Future<List<dynamic>> fetchClientOrders({String status = 'open'}) async {
    final res = await _api.get('/orders/me?status=$status');
    if (res.statusCode >= 300) {
      throw Exception('Failed to fetch client orders');
    }
    final body = json.decode(res.body);
    final data = body['data'] ?? [];
    return data as List<dynamic>;
  }

  Future<void> pickupOrder(String orderId) async {
    final res = await _api.patch('/orders/$orderId/pickup', {});
    if (res.statusCode >= 300) {
      throw Exception('Erro ao confirmar retirada');
    }
  }

  Future<void> cancelOrder(String orderId, {String? reason}) async {
    final res = await _api.patch('/orders/$orderId/cancel', {
      if (reason != null && reason.isNotEmpty) 'reason': reason,
    });
    if (res.statusCode >= 300) {
      throw Exception('Erro ao cancelar pedido');
    }
  }

  Future<void> rateOrder(String orderId, int rating, {String? comment}) async {
    final res = await _api.patch('/orders/$orderId/rating', {
      'rating': rating,
      if (comment != null && comment.isNotEmpty) 'comment': comment,
    });
    if (res.statusCode >= 300) {
      throw Exception('Erro ao avaliar pedido');
    }
  }
}
