import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/auth_provider.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';
import '../models/store_model.dart';
import '../services/catalog_api_service.dart';

final catalogApiServiceProvider = Provider<CatalogApiService>((ref) {
  return CatalogApiService();
});

final categoriesProvider = FutureProvider<List<CategoryModel>>((ref) async {
  return ref.read(catalogApiServiceProvider).fetchCategories();
});

final featuredProductsProvider = FutureProvider<List<ProductModel>>((ref) async {
  final user = ref.watch(authProvider);
  return ref.read(catalogApiServiceProvider).fetchFeaturedProducts(
        institutionId: user?.institution,
      );
});

final canteensProvider = FutureProvider.family<List<StoreModel>, String?>((ref, institutionId) {
  return ref.read(catalogApiServiceProvider).fetchCanteens(institutionId: institutionId);
});

final canteenByIdProvider = FutureProvider.family<StoreModel?, String>((ref, id) async {
  return ref.read(catalogApiServiceProvider).fetchCanteenById(id);
});

final productsByCanteenProvider = FutureProvider.family<List<ProductModel>, String>((ref, canteenId) async {
  return ref.read(catalogApiServiceProvider).fetchProductsByCanteen(canteenId: canteenId);
});

final productDetailProvider = FutureProvider.family<ProductDetailData?, String>((ref, productId) async {
  return ref.read(catalogApiServiceProvider).fetchProductDetail(productId);
});

// --- HOME SCREEN VIEWMODELS ---
final homeSearchQueryProvider = StateProvider<String>((ref) => '');
final homeSelectedCategoryProvider = StateProvider<int>((ref) => 0);

final homeFilteredProductsProvider = Provider<List<ProductModel>>((ref) {
  final query = ref.watch(homeSearchQueryProvider).trim().toLowerCase();
  final selectedIdx = ref.watch(homeSelectedCategoryProvider);
  
  final categories = ref.watch(categoriesProvider).maybeWhen(
        data: (c) => c,
        orElse: () => const <CategoryModel>[],
      );
      
  final featured = ref.watch(featuredProductsProvider).maybeWhen(
        data: (f) => f,
        orElse: () => const <ProductModel>[],
      );

  final selectedCategoryId = selectedIdx == 0 || categories.isEmpty
      ? null
      : categories[selectedIdx - 1].id;

  return featured.where((product) {
    final matchesCategory = selectedCategoryId == null || product.categoryId == selectedCategoryId;
    final matchesSearch = query.isEmpty ||
        product.name.toLowerCase().contains(query) ||
        product.description.toLowerCase().contains(query);
    return matchesCategory && matchesSearch;
  }).toList();
});

// --- VENDOR PROVIDERS ---
final myCanteenProvider = FutureProvider<StoreModel>((ref) {
  return ref.read(catalogApiServiceProvider).fetchMyCanteen();
});

final vendorProductsProvider = FutureProvider.family<List<ProductModel>, String>((ref, canteenId) {
  return ref.read(catalogApiServiceProvider).fetchProductsByCanteen(canteenId: canteenId);
});

final vendorAdditionalsProvider = FutureProvider.family<List<AdditionalModel>, String>((ref, canteenId) {
  return ref.read(catalogApiServiceProvider).fetchExtrasByCanteen(canteenId);
});