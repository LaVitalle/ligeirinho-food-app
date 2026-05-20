import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/product_card.dart';
import '../../../data/models/category_model.dart';
import '../../../data/providers/catalog_providers.dart';
import '../cart/cart_provider.dart';

class StoreMenuScreen extends ConsumerStatefulWidget {
  final String storeId;
  const StoreMenuScreen({super.key, required this.storeId});

  @override
  ConsumerState<StoreMenuScreen> createState() => _StoreMenuScreenState();
}

class _StoreMenuScreenState extends ConsumerState<StoreMenuScreen> {
  int _filterIndex = 0;
  final _searchCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final storeAsync = ref.watch(canteenByIdProvider(widget.storeId));
    final productsAsync = ref.watch(productsByCanteenProvider(widget.storeId));
    final categoriesAsync = ref.watch(categoriesProvider);
    final query = _searchCtrl.text.trim().toLowerCase();

    final categories = categoriesAsync.maybeWhen(
      data: (items) => items,
      orElse: () => const <CategoryModel>[],
    );
    final filters = [const CategoryModel(id: 'all', name: 'Todos'), ...categories];
    final safeIndex = _filterIndex.clamp(0, filters.length - 1).toInt();
    final selectedCategoryId = safeIndex == 0 ? null : filters[safeIndex].id;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: storeAsync.when(
        data: (store) {
          if (store == null) {
            return const Center(child: Text('Cantina não encontrada'));
          }

          if (safeIndex != _filterIndex) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() => _filterIndex = safeIndex);
              }
            });
          }

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 180,
                pinned: true,
                backgroundColor: AppColors.background,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                  onPressed: () => context.pop(),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.search, color: Colors.white),
                    onPressed: () => FocusScope.of(context).requestFocus(FocusNode()),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      store.logoUrl != null && store.logoUrl!.isNotEmpty
                          ? Image.network(store.logoUrl!, fit: BoxFit.cover)
                          : Container(color: Colors.grey.shade300),
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.black38, Colors.black12],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(store.name,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w800,
                              color: AppColors.textDark)),
                      const SizedBox(height: 4),
                      Text(store.description,
                          style: const TextStyle(
                              fontSize: 13, color: AppColors.textMedium)),
                      const SizedBox(height: 4),
                      Text(
                        store.isOpen ? 'Aberto agora' : 'Fechado no momento',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: store.isOpen ? AppColors.open : AppColors.closed,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Buscar item no menu',
                      prefixIcon: const Icon(Icons.search, color: AppColors.textLight),
                      fillColor: AppColors.surface,
                      filled: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: SizedBox(
                  height: 48,
                  child: categoriesAsync.when(
                    data: (items) {
                      final filtersFromApi = [const CategoryModel(id: 'all', name: 'Todos'), ...items];
                      final currentIndex = _filterIndex.clamp(0, filtersFromApi.length - 1).toInt();

                      return ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                        itemCount: filtersFromApi.length,
                        itemBuilder: (_, i) {
                          final active = currentIndex == i;
                          return GestureDetector(
                            onTap: () => setState(() => _filterIndex = i),
                            child: Container(
                              margin: const EdgeInsets.only(right: 10),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                              decoration: BoxDecoration(
                                color: active ? AppColors.primary : AppColors.surface,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                filtersFromApi[i].name,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: active ? Colors.white : AppColors.textMedium,
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (_, __) => const Center(child: Text('Erro ao carregar filtros')),
                  ),
                ),
              ),

              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20, 20, 20, 8),
                  child: Text('Destaques',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700,
                          color: AppColors.textDark)),
                ),
              ),

              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                sliver: productsAsync.when(
                  data: (items) {
                    final products = items.where((product) {
                      final matchesCategory = selectedCategoryId == null || product.categoryId == selectedCategoryId;
                      final matchesSearch = query.isEmpty ||
                          product.name.toLowerCase().contains(query) ||
                          product.description.toLowerCase().contains(query);
                      return matchesCategory && matchesSearch;
                    }).toList();

                    if (products.isEmpty) {
                      return const SliverToBoxAdapter(
                        child: Center(child: Padding(
                          padding: EdgeInsets.only(top: 32),
                          child: Text('Nenhum produto encontrado'),
                        )),
                      );
                    }

                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (_, i) => ProductCard(
                          product: products[i],
                          horizontal: true,
                          onTap: () => context.push('/product/${products[i].id}'),
                          onAdd: () {
                            ref.read(cartProvider.notifier).addItem(
                                  products[i],
                                  store.name,
                                  1,
                                  [],
                                  [],
                                );
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${products[i].name} adicionado!'),
                                backgroundColor: AppColors.primary,
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          },
                        ),
                        childCount: products.length,
                      ),
                    );
                  },
                  loading: () => const SliverToBoxAdapter(
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (_, __) => const SliverToBoxAdapter(
                    child: Center(child: Text('Erro ao carregar produtos')),
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Erro ao carregar a cantina')),
      ),
    );
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }
}
