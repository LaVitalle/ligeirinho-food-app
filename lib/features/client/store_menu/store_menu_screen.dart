import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/product_card.dart';
import '../../../data/mock/mock_data.dart';
import '../../../data/models/store_model.dart';
import '../cart/cart_provider.dart';

class StoreMenuScreen extends ConsumerStatefulWidget {
  final StoreModel store;
  const StoreMenuScreen({super.key, required this.store});

  @override
  ConsumerState<StoreMenuScreen> createState() => _StoreMenuScreenState();
}

class _StoreMenuScreenState extends ConsumerState<StoreMenuScreen> {
  int _filterIndex = 0;
  final _filters = ['Todos', 'Bebidas', 'Doces', 'Promos'];

  @override
  Widget build(BuildContext context) {
    final products = mockProducts
        .where((p) => p.storeId == widget.store.id)
        .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Header com imagem da loja
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
                onPressed: () {},
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(color: Colors.grey.shade300),
                  const Center(
                    child: Icon(Icons.store, size: 80, color: Colors.white54),
                  ),
                  // Gradient overlay
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

          // Loja info
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.store.name,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.w800,
                          color: AppColors.textDark)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, color: AppColors.starYellow, size: 16),
                      const SizedBox(width: 4),
                      Text('${widget.store.rating} • ${widget.store.reviewCount} avaliações',
                          style: const TextStyle(
                              fontSize: 13, color: AppColors.textMedium)),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Busca
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: TextField(
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

          // Filtros
          SliverToBoxAdapter(
            child: SizedBox(
              height: 48,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                itemCount: _filters.length,
                itemBuilder: (_, i) {
                  final active = _filterIndex == i;
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
                        _filters[i],
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: active ? Colors.white : AppColors.textMedium,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Destaques label
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Text('Destaques',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w700,
                      color: AppColors.textDark)),
            ),
          ),

          // Produtos
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) => ProductCard(
                  product: products[i],
                  horizontal: true,
                  onTap: () => context.push(
                      '/product/${products[i].id}', extra: products[i]),
                  onAdd: () {
                    ref.read(cartProvider.notifier).addItem(
                        products[i], widget.store.name, 1, [], []);
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
            ),
          ),
        ],
      ),
    );
  }
}
