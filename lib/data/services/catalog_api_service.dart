import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/services/api_service.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';
import '../models/store_model.dart';

class ProductDetailData {
  final ProductModel product;
  final StoreModel? store;
  final List<AdditionalModel> additionals;
  final List<String> removableIngredients;

  const ProductDetailData({
    required this.product,
    required this.store,
    required this.additionals,
    required this.removableIngredients,
  });

  ProductDetailData copyWith({
    ProductModel? product,
    StoreModel? store,
    List<AdditionalModel>? additionals,
    List<String>? removableIngredients,
  }) {
    return ProductDetailData(
      product: product ?? this.product,
      store: store ?? this.store,
      additionals: additionals ?? this.additionals,
      removableIngredients: removableIngredients ?? this.removableIngredients,
    );
  }
}

/// Fachada de acesso ao catálogo — **padrão de projeto Facade**.
///
/// O backend é composto por microsserviços com dezenas de endpoints
/// distribuídos (categorias, cantinas, produtos, adicionais, ingredientes
/// removíveis, fotos etc.). Esta classe atua como uma **fachada** que
/// simplifica esse acesso para o restante do app:
///
/// - As ViewModels (providers) chamam apenas métodos de alto nível como
///   `fetchProductDetail()`, sem conhecer a estrutura interna de endpoints.
/// - Internamente, a fachada orquestra múltiplas chamadas HTTP, trata os
///   envelopes de resposta do backend (`{ data, status, pagination }`) e
///   devolve objetos de domínio prontos para uso.
///
/// **Exemplo concreto**: `fetchProductDetail()` encapsula 4 chamadas
/// separadas (produto, cantina, adicionais, ingredientes removíveis) em
/// uma única interface coesa para a camada de apresentação.
class CatalogApiService {
  final ApiService _api;

  CatalogApiService([ApiService? api]) : _api = api ?? ApiService();

  Future<List<CategoryModel>> fetchCategories() async {
    final data = await _getData('/categories');
    final items = _asList(data);
    final categories = items
        .whereType<Map<String, dynamic>>()
        .map(CategoryModel.fromJson)
        .toList();
    categories.sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
    return categories;
  }

  Future<List<StoreModel>> fetchCanteens({String? institutionId}) async {
    final query = <String, String>{};
    if (institutionId != null && institutionId.isNotEmpty) {
      query['institutionId'] = institutionId;
    }
    final data = await _getData('/canteens', queryParameters: query);
    final items = _asList(data);
    return items
        .whereType<Map<String, dynamic>>()
        .map(StoreModel.fromJson)
        .toList();
  }

  Future<StoreModel?> fetchCanteenById(String id) async {
    final data = await _getData('/canteens/$id');
    if (data is Map<String, dynamic>) {
      return StoreModel.fromJson(data);
    }
    return null;
  }

  Future<List<ProductModel>> fetchFeaturedProducts(
      {String? institutionId, int limit = 10}) async {
    final query = <String, String>{'limit': limit.toString()};
    if (institutionId != null && institutionId.isNotEmpty) {
      query['institutionId'] = institutionId;
    }
    final data = await _getData('/products/featured', queryParameters: query);
    final items = _asList(data);
    return items
        .whereType<Map<String, dynamic>>()
        .map(ProductModel.fromJson)
        .toList();
  }

  Future<List<ProductModel>> fetchProductsByCanteen({
    required String canteenId,
    String? categoryId,
    String? search,
    bool onlyActive = true,
    int perPage = 100,
  }) async {
    final query = <String, String>{
      'canteenId': canteenId,
      'perPage': perPage.toString(),
      'onlyActive': onlyActive.toString(),
    };
    if (categoryId != null && categoryId.isNotEmpty) {
      query['categoryId'] = categoryId;
    }
    if (search != null && search.isNotEmpty) {
      query['search'] = search;
    }

    final data = await _getData('/products', queryParameters: query);
    final items = _asList(data);
    return items
        .whereType<Map<String, dynamic>>()
        .map(ProductModel.fromJson)
        .toList();
  }

  Future<ProductDetailData?> fetchProductDetail(String productId) async {
    final productData = await _getData('/products/$productId');
    if (productData is! Map<String, dynamic>) {
      return null;
    }

    final product = ProductModel.fromJson(productData);
    final store = await fetchCanteenById(product.storeId);
    final extras = await fetchExtrasByProduct(productId);
    final removableIngredients = await fetchRemovableIngredients(productId);

    return ProductDetailData(
      product: product.copyWith(
        additionals: extras,
        removableIngredients: removableIngredients,
      ),
      store: store,
      additionals: extras,
      removableIngredients: removableIngredients,
    );
  }

  Future<List<AdditionalModel>> fetchExtrasByProduct(String productId) async {
    final data = await _getData('/products/$productId/extras');
    final items = _asList(data);
    return items
        .whereType<Map<String, dynamic>>()
        .map(AdditionalModel.fromJson)
        .toList();
  }

  Future<List<String>> fetchRemovableIngredients(String productId) async {
    final data = await _getData('/products/$productId/removable-ingredients');
    final items = _asList(data);
    return items.whereType<String>().toList();
  }

  // --- VENDOR ENDPOINTS ---

  Future<String> createProduct(Map<String, dynamic> body) async {
    final res = await _api.post('/products', body);
    if (res.statusCode >= 300) {
      throw Exception('Failed to create product: ${res.body}');
    }
    final decoded = json.decode(res.body);
    if (decoded is Map &&
        decoded['data'] != null &&
        decoded['data']['id'] != null) {
      return decoded['data']['id'].toString();
    }
    return '';
  }

  Future<void> updateProduct(
      String productId, Map<String, dynamic> body) async {
    final token = await _api.getToken();
    final uri = Uri.parse('${_api.baseUrl}/products/$productId');
    final res = await http.put(uri,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: json.encode(body));
    if (res.statusCode >= 300) {
      throw Exception('Failed to update product: ${res.body}');
    }
  }

  Future<void> uploadProductPhoto(String productId, String imagePath) async {
    final token = await _api.getToken();
    final uri = Uri.parse('${_api.baseUrl}/products/$productId/photo');
    final request = http.MultipartRequest('POST', uri);

    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    request.files.add(await http.MultipartFile.fromPath('photo', imagePath));

    final res = await request.send();
    if (res.statusCode >= 300) {
      final resBody = await res.stream.bytesToString();
      throw Exception('Failed to upload photo: $resBody');
    }
  }

  Future<void> createAdditional(Map<String, dynamic> body) async {
    final res = await _api.post('/extras', body);
    if (res.statusCode >= 300) {
      throw Exception('Failed to create additional: ${res.body}');
    }
  }

  Future<List<AdditionalModel>> fetchExtrasByCanteen(String canteenId) async {
    final data =
        await _getData('/extras', queryParameters: {'canteenId': canteenId});
    final items = _asList(data);
    return items
        .whereType<Map<String, dynamic>>()
        .map(AdditionalModel.fromJson)
        .toList();
  }

  Future<StoreModel> fetchMyCanteen() async {
    final data = await _getData('/canteens/me');
    return StoreModel.fromJson(data);
  }

  Future<void> updateMyCanteen(Map<String, dynamic> body) async {
    final token = await _api.getToken();
    final uri = Uri.parse('${_api.baseUrl}/canteens/me');
    final res = await http.patch(uri,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: json.encode(body));

    if (res.statusCode >= 300) {
      throw Exception('Failed to update canteen: ${res.body}');
    }
  }

  Future<dynamic> _getData(
    String path, {
    Map<String, String>? queryParameters,
  }) async {
    final uri = Uri.parse('${_api.baseUrl}$path')
        .replace(queryParameters: queryParameters);
    final token = await _api.getToken();
    final response = await http.get(uri, headers: {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    });

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(_extractErrorMessage(response.body));
    }

    final decoded = json.decode(response.body);
    if (decoded is Map<String, dynamic> && decoded.containsKey('data')) {
      return decoded['data'];
    }
    return decoded;
  }

  List<dynamic> _asList(dynamic data) {
    if (data is List<dynamic>) {
      return data;
    }
    if (data is Map<String, dynamic> && data['items'] is List<dynamic>) {
      return data['items'] as List<dynamic>;
    }
    return const [];
  }

  String _extractErrorMessage(String body) {
    try {
      final decoded = json.decode(body);
      if (decoded is Map<String, dynamic>) {
        final status = decoded['status'];
        if (status is Map<String, dynamic> && status['message'] != null) {
          return status['message'].toString();
        }
      }
    } catch (_) {}
    return 'Erro ao carregar dados';
  }
}
