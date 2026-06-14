import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../../core/services/api_service.dart';
import '../../core/routes/app_router.dart';
import 'package:flutter/material.dart';
import '../models/order_model.dart';
import 'dart:convert';
import 'dart:async';

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
}

final ordersApiProvider = Provider<OrdersApiService>((ref) {
  return OrdersApiService(ApiService());
});

final vendorOrdersProvider =
    FutureProvider.autoDispose<List<dynamic>>((ref) async {
  final api = ref.read(ordersApiProvider);
  return api.fetchVendorOrders();
});

final clientOrdersProvider = FutureProvider.family
    .autoDispose<List<dynamic>, String>((ref, status) async {
  final api = ref.read(ordersApiProvider);
  return api.fetchClientOrders(status: status);
});

// A provider that polls the active orders every 10 seconds to notify changes
final _lastOrdersStatusProvider = StateProvider<Map<String, String>>((ref) => {});

final orderPollingProvider = Provider.autoDispose((ref) {
  final api = ref.read(ordersApiProvider);
  Timer? timer;

  timer = Timer.periodic(const Duration(seconds: 10), (_) async {
    try {
      final activeOrders = await api.fetchClientOrders(status: 'open');
      final lastStatusMap = ref.read(_lastOrdersStatusProvider);

      final currentMap = <String, String>{};
      for (final order in activeOrders) {
        final id = order['id'].toString();
        final status = order['status'].toString();
        currentMap[id] = status;

        if (lastStatusMap.containsKey(id) && lastStatusMap[id] != status) {
          // Fire a notification / invalidate orders to trigger UI rebuild
          ref.invalidate(clientOrdersProvider('open'));
          ref.invalidate(clientOrdersProvider('history'));

          final context = rootNavigatorKey.currentContext;
          if (context != null) {
            _showNotification(context, id.substring(0, 6), status);
          }
        }
      }
      ref.read(_lastOrdersStatusProvider.notifier).state = currentMap;
    } catch (_) {
      // Ignore polling errors
    }
  });

  ref.onDispose(() => timer?.cancel());
});

void _showNotification(BuildContext context, String shortId, String status) {
  String text = 'Seu pedido #$shortId foi atualizado para: $status';
  if (status == 'AGUARDANDO_RETIRADA' || status == 'PRONTO') {
    text = '🎉 Seu pedido #$shortId está PRONTO para retirada!';
  } else if (status == 'CANCELADO') {
    text = '⚠️ Seu pedido #$shortId foi cancelado.';
  }

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(text),
      behavior: SnackBarBehavior.floating,
      backgroundColor: status == 'CANCELADO' ? Colors.red : Colors.green,
      duration: const Duration(seconds: 5),
    )
  );
}
