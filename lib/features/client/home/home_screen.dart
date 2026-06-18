import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/product_card.dart';
import '../../../data/models/category_model.dart';
import '../../../data/models/product_model.dart';
import '../../../data/models/store_model.dart';
import '../../../data/providers/catalog_providers.dart';
import '../../../features/auth/auth_provider.dart';
import '../cart/cart_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(() {
      ref.read(homeSearchQueryProvider.notifier).state = _searchCtrl.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider);
    final cartCount = ref.watch(cartCountProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final featuredAsync = ref.watch(featuredProductsProvider);
    // user?.institution was returning empty because the user model sets it from 'institutionId' which wasn't fully mapped sometimes. Let's ensure we use the actual institution ID.
    // If the user's institution is null in the front-end, it will send empty strings.
    final institutionId = user?.institution ?? '';
    final canteensAsync = ref.watch(canteensProvider(institutionId.isNotEmpty ? institutionId : null));

    final categories = categoriesAsync.maybeWhen(
      data: (items) => items,
      orElse: () => const <CategoryModel>[],
    );
    final featured = featuredAsync.maybeWhen(
      data: (items) => items,
      orElse: () => const <ProductModel>[],
    );
    final canteens = canteensAsync.maybeWhen(
      data: (items) => items,
      orElse: () => const <StoreModel>[],
    );
    final filteredFeatured = ref.watch(homeFilteredProductsProvider);
    final highlights = filteredFeatured.skip(2).take(5).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      child: const Icon(Icons.person, color: AppColors.primary, size: 22),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Ligeirinho Food',
                            style: TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 16,
                                color: AppColors.textDark),
                          ),
                          Text(
                            user?.institution?.isNotEmpty == true
                                ? 'Instituição ${user?.institution}'
                                : 'Catálogo da sua instituição',
                            style: const TextStyle(fontSize: 11, color: AppColors.textLight),
                          ),
                        ],
                      ),
                    ),
                    Stack(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.shopping_cart_outlined,
                              color: AppColors.textDark),
                          onPressed: () => context.push('/cart'),
                        ),
                        if (cartCount > 0)
                          Positioned(
                            right: 6,
                            top: 6,
                            child: Container(
                              width: 16,
                              height: 16,
                              decoration: const BoxDecoration(
                                  color: AppColors.primary, shape: BoxShape.circle),
                              child: Center(
                                child: Text('$cartCount',
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 9,
                                        fontWeight: FontWeight.w700)),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Search bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: TextField(
                  controller: _searchCtrl,
                  decoration: InputDecoration(
                    hintText: 'O que vais querer hoje?',
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

            // Categorias
            SliverToBoxAdapter(
              child: SizedBox(
                height: 96,
                child: categoriesAsync.when(
                  data: (items) {
                    final chips = [
                      const CategoryModel(id: 'all', name: 'Todos'),
                      ...items,
                    ];
                    final currentIdx = ref.watch(homeSelectedCategoryProvider);
                    final safeIndex = currentIdx.clamp(0, chips.length - 1).toInt();
                    if (safeIndex != currentIdx) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        ref.read(homeSelectedCategoryProvider.notifier).state = safeIndex;
                      });
                    }

                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                      itemCount: chips.length,
                      itemBuilder: (_, i) {
                        final cat = chips[i];
                        final active = safeIndex == i;
                        return GestureDetector(
                          onTap: () => ref.read(homeSelectedCategoryProvider.notifier).state = i,
                          child: Container(
                            margin: const EdgeInsets.only(right: 16),
                            child: Column(
                              children: [
                                Container(
                                  width: 52,
                                  height: 52,
                                  decoration: BoxDecoration(
                                    color: active
                                        ? AppColors.primary
                                        : AppColors.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Icon(
                                    _categoryIcon(cat),
                                    color: active ? Colors.white : AppColors.primary,
                                    size: 26,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(cat.name,
                                    style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                        color: active ? AppColors.primary : AppColors.textMedium)),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (_, __) => const Center(
                    child: Text('Não foi possível carregar as categorias'),
                  ),
                ),
              ),
            ),

            // Mais Vendidos
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Mais Vendidos',
                        style: TextStyle(
                            fontSize: 17, fontWeight: FontWeight.w800,
                            color: AppColors.textDark)),
                    TextButton(
                      onPressed: () {},
                      child: const Text('Ver todos',
                          style: TextStyle(color: AppColors.primary, fontSize: 13)),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 220,
                child: featuredAsync.when(
                  data: (items) {
                    final products = ref.watch(homeFilteredProductsProvider);

                    if (products.isEmpty) {
                      return const Center(child: Text('Nenhum produto encontrado'));
                    }

                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.only(left: 20, right: 8),
                      itemCount: products.length,
                      itemBuilder: (_, i) {
                        final product = products[i];
                        final store = _storeById(canteens, product.storeId);
                        return Padding(
                          padding: const EdgeInsets.only(right: 14),
                          child: ProductCard(
                            product: product,
                            onTap: () => context.push('/product/${product.id}'),
                            onAdd: () {
                              ref.read(cartProvider.notifier).addItem(
                                    product,
                                    store?.name ?? 'Cantina',
                                    1,
                                    [],
                                    [],
                                  );
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('${product.name} adicionado!'),
                                  backgroundColor: AppColors.primary,
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (_, __) => const Center(child: Text('Erro ao carregar produtos')),
                ),
              ),
            ),

            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 20, 20, 8),
                child: Text('Cantinas da sua instituição',
                    style: TextStyle(
                        fontSize: 17, fontWeight: FontWeight.w800,
                        color: AppColors.textDark)),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 132,
                child: canteensAsync.when(
                  data: (items) {
                    if (items.isEmpty) {
                      return const Center(child: Text('Nenhuma cantina encontrada'));
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                      scrollDirection: Axis.horizontal,
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (_, index) {
                        final store = items[index];
                        return _StoreShortcut(
                          store: store,
                          onTap: () => context.push('/store/${store.id}'),
                        );
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (_, __) => const Center(child: Text('Erro ao carregar cantinas')),
                ),
              ),
            ),

            // Destaques da Galera
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 20, 20, 8),
                child: Text('Destaques da Galera',
                    style: TextStyle(
                        fontSize: 17, fontWeight: FontWeight.w800,
                        color: AppColors.textDark)),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) {
                    final p = highlights[i];
                    final store = _storeById(canteens, p.storeId);
                    return ProductCard(
                      product: p,
                      horizontal: true,
                      onTap: () => context.push('/product/${p.id}'),
                      onAdd: () {
                        ref.read(cartProvider.notifier).addItem(p, store?.name ?? 'Cantina', 1, [], []);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${p.name} adicionado!'),
                            backgroundColor: AppColors.primary,
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                    );
                  },
                  childCount: highlights.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  IconData _categoryIcon(CategoryModel category) {
    switch ((category.iconKey ?? category.name).toLowerCase()) {
      case 'drink':
      case 'bebidas':
        return Icons.local_cafe;
      case 'snack':
      case 'lanches':
        return Icons.restaurant_menu;
      case 'sweet':
      case 'doces':
        return Icons.cake;
      case 'pizza':
      case 'outros':
        return Icons.local_pizza;
      default:
        return Icons.restaurant;
    }
  }

  StoreModel? _storeById(List<StoreModel> stores, String storeId) {
    for (final store in stores) {
      if (store.id == storeId) return store;
    }
    return null;
  }
}

class _StoreShortcut extends StatelessWidget {
  final StoreModel store;
  final VoidCallback onTap;

  const _StoreShortcut({required this.store, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final location = store.address.isNotEmpty ? store.address : [store.block, store.room].whereType<String>().where((value) => value.isNotEmpty).join(' · ');

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 220,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              clipBehavior: Clip.antiAlias,
              child: store.logoUrl != null && store.logoUrl!.isNotEmpty
                  ? Image.network(store.logoUrl!, fit: BoxFit.cover)
                  : const Icon(Icons.store, color: AppColors.primary, size: 30),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(store.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark)),
                  const SizedBox(height: 4),
                  Text(location.isNotEmpty ? location : 'Cantina da instituição',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textLight)),
                  const SizedBox(height: 6),
                  Text(
                    store.isOpen ? 'Aberto agora' : 'Fechado',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: store.isOpen ? AppColors.open : AppColors.closed,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
