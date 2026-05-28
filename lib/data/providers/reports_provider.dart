import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../core/services/api_service.dart';

class ReportsApiService {
  final ApiService _api;

  ReportsApiService([ApiService? api]) : _api = api ?? ApiService();

  Future<Map<String, dynamic>> fetchRevenue() async {
    final res = await _api.get('/reports/revenue');
    if (res.statusCode >= 300) throw Exception('Failed to fetch revenue');
    return json.decode(res.body)['data'];
  }

  Future<Map<String, dynamic>> fetchOrdersCount() async {
    final res = await _api.get('/reports/orders-count');
    if (res.statusCode >= 300) throw Exception('Failed to fetch orders count');
    return json.decode(res.body)['data'];
  }

  Future<List<dynamic>> fetchRevenueTrend() async {
    final res = await _api.get('/reports/revenue-trend');
    if (res.statusCode >= 300) throw Exception('Failed to fetch revenue trend');
    return json.decode(res.body)['data'] ?? [];
  }

  Future<List<dynamic>> fetchTopProducts() async {
    final res = await _api.get('/reports/top-products');
    if (res.statusCode >= 300) throw Exception('Failed to fetch top products');
    return json.decode(res.body)['data'] ?? [];
  }
}

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
