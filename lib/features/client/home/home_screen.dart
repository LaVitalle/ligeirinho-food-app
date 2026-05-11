import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/product_card.dart';
import '../../../data/mock/mock_data.dart';
import '../../../features/auth/auth_provider.dart';
import '../cart/cart_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _searchCtrl = TextEditingController();
  int _selectedCategory = 0;

  final _categories = [
    {'icon': Icons.local_fire_department, 'label': 'Resgatar'},
    {'icon': Icons.restaurant_menu, 'label': 'Bebidas'},
    {'icon': Icons.cake, 'label': 'Lanches'},
    {'icon': Icons.local_pizza, 'label': 'Outros'},
  ];

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider);
    final cartCount = ref.watch(cartCountProvider);

    // Produtos mais vendidos (primeiros 4)
    final featured = mockProducts.take(4).toList();
    // Destaques da galera
    final highlights = mockProducts.skip(2).take(5).toList();

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
                    const Expanded(
                      child: Text(
                        'Ligeirinho Food',
                        style: TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 16,
                            color: AppColors.textDark),
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
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                  itemCount: _categories.length,
                  itemBuilder: (_, i) {
                    final cat = _categories[i];
                    final active = _selectedCategory == i;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedCategory = i),
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
                                cat['icon'] as IconData,
                                color: active ? Colors.white : AppColors.primary,
                                size: 26,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(cat['label'] as String,
                                style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: active ? AppColors.primary : AppColors.textMedium)),
                          ],
                        ),
                      ),
                    );
                  },
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
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.only(left: 20, right: 8),
                  itemCount: featured.length,
                  itemBuilder: (_, i) {
                    final store = mockStores.firstWhere(
                        (s) => s.id == featured[i].storeId,
                        orElse: () => mockStores.first);
                    return Padding(
                      padding: const EdgeInsets.only(right: 14),
                      child: ProductCard(
                        product: featured[i],
                        onTap: () => context.push('/product/${featured[i].id}',
                            extra: featured[i]),
                        onAdd: () {
                          ref.read(cartProvider.notifier).addItem(
                              featured[i], store.name, 1, [], []);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${featured[i].name} adicionado!'),
                              backgroundColor: AppColors.primary,
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        },
                      ),
                    );
                  },
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
                    final store = mockStores.firstWhere(
                        (s) => s.id == p.storeId,
                        orElse: () => mockStores.first);
                    return ProductCard(
                      product: p,
                      horizontal: true,
                      onTap: () => context.push('/product/${p.id}', extra: p),
                      onAdd: () {
                        ref.read(cartProvider.notifier).addItem(p, store.name, 1, [], []);
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
}
