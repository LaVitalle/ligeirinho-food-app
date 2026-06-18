import '../../core/services/api_service.dart';
import 'dart:convert';

/// Service de acesso à API de relatórios (camada Model/Service do MVVM).
///
/// Responsável exclusivamente pela comunicação HTTP com os endpoints de
/// relatórios do backend. Não contém lógica de estado nem de apresentação.
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
