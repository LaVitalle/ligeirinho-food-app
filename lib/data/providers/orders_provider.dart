import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import '../../core/services/api_service.dart';
import '../../core/routes/app_router.dart';
import '../services/orders_api_service.dart';
import 'dart:async';

// ── ViewModel (Providers) ─────────────────────────────────────────────────
// Camada ViewModel do MVVM: gerencia estado e orquestra chamadas ao Service.
// Não contém lógica HTTP — essa responsabilidade é do OrdersApiService.

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
