import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/reports_api_service.dart';

// ── ViewModel (Providers) ─────────────────────────────────────────────────
// Camada ViewModel do MVVM: gerencia estado e orquestra chamadas ao Service.
// Não contém lógica HTTP — essa responsabilidade é do ReportsApiService.

final reportsApiProvider = Provider<ReportsApiService>((ref) {
  return ReportsApiService();
});

final revenueProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  return ref.read(reportsApiProvider).fetchRevenue();
});

final ordersCountProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  return ref.read(reportsApiProvider).fetchOrdersCount();
});

final revenueTrendProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  return ref.read(reportsApiProvider).fetchRevenueTrend();
});

final topProductsProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  return ref.read(reportsApiProvider).fetchTopProducts();
});
