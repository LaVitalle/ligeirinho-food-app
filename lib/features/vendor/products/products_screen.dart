import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/auth_provider.dart';
import '../../../data/models/product_model.dart';
import '../../../data/providers/catalog_providers.dart';

final _currency = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

class ProductsScreen extends ConsumerStatefulWidget {
  const ProductsScreen({super.key});

  @override
  ConsumerState<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends ConsumerState<ProductsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  final Map<String, bool> _active = {};

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider);
    final canteenId = user?.institution ?? ''; // Note: User model has canteenId mapped or we need to fetch myCanteen. Let's use myCanteenProvider.

    final myCanteenAsync = ref.watch(myCanteenProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text('Produtos',
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textDark)),
                  ),
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.surface,
                    child: Icon(Icons.person, color: AppColors.textLight),
                  ),
                ],
              ),
            ),

            // Search
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Buscar produtos por nome...',
                  prefixIcon:
                      const Icon(Icons.search, color: AppColors.textLight),
                  fillColor: AppColors.surface,
                  filled: true,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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

            const SizedBox(height: 12),

            // Tabs
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                controller: _tabCtrl,
                labelColor: Colors.white,
                unselectedLabelColor: AppColors.textMedium,
                labelStyle: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w700),
                indicator: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                tabs: const [
                  Tab(text: 'Produtos'),
                  Tab(text: 'Adicionais'),
                ],
              ),
            ),

            const SizedBox(height: 8),

            Expanded(
              child: myCanteenAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Erro: $e')),
                data: (canteen) {
                  final productsAsync = ref.watch(vendorProductsProvider(canteen.id));
                  final additionalsAsync = ref.watch(vendorAdditionalsProvider(canteen.id));

                  return TabBarView(
                    controller: _tabCtrl,
                    children: [
                      // Produtos tab
                      Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
                            child: Row(
                              children: [
                                const Text('CARDÁPIO ATIVO',
                                    style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textLight,
                                        letterSpacing: 1)),
                                const Spacer(),
                                TextButton.icon(
                                  onPressed: () {},
                                  icon: const Icon(Icons.add,
                                      size: 16, color: AppColors.primary),
                                  label: const Text('Novo',
                                      style: TextStyle(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w700)),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: productsAsync.when(
                              loading: () => const Center(child: CircularProgressIndicator()),
                              error: (e, _) => Center(child: Text('Erro: $e')),
                              data: (vendorProducts) => ListView.separated(
                                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                                itemCount: vendorProducts.length,
                                separatorBuilder: (_, __) => const SizedBox(height: 12),
                                itemBuilder: (context, i) {
                                  final p = vendorProducts[i];
                                  final isActive = _active[p.id] ?? p.isActive;

                                  return Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: AppColors.surface,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 52,
                                          height: 52,
                                          decoration: BoxDecoration(
                                            color: AppColors.surface,
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: const Icon(Icons.fastfood,
                                              color: AppColors.textLight, size: 28),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(p.name,
                                                  style: const TextStyle(
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.w600,
                                                      color: AppColors.textDark)),
                                              Text(_currency.format(p.price),
                                                  style: const TextStyle(
                                                      fontSize: 12,
                                                      color: AppColors.primary,
                                                      fontWeight:
                                                          FontWeight.w600)),
                                              Container(
                                                margin: const EdgeInsets.only(top: 4),
                                                padding: const EdgeInsets.symmetric(
                                                    horizontal: 8, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: isActive
                                                      ? AppColors.open.withOpacity(0.12)
                                                      : AppColors.closed.withOpacity(0.12),
                                                  borderRadius: BorderRadius.circular(20),
                                                ),
                                                child: Text(
                                                  isActive ? 'EM ESTOQUE' : 'INDISPONÍVEL',
                                                  style: TextStyle(
                                                      fontSize: 9,
                                                      fontWeight: FontWeight.w700,
                                                      color: isActive
                                                          ? AppColors.open : AppColors.closed),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Switch(
                                          value: isActive,
                                          onChanged: (val) {
                                            setState(() => _active[p.id] = val);
                                            // TODO: Call API to update status
                                          },
                                          activeColor: AppColors.primary,
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Adicionais tab
                      Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
                            child: Row(
                              children: [
                                const Text('ADICIONAIS',
                                    style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textLight,
                                        letterSpacing: 1)),
                                const Spacer(),
                                TextButton.icon(
                                  onPressed: () {},
                                  icon: const Icon(Icons.add,
                                      size: 16, color: AppColors.primary),
                                  label: const Text('Novo',
                                      style: TextStyle(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w700)),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: additionalsAsync.when(
                              loading: () => const Center(child: CircularProgressIndicator()),
                              error: (e, _) => Center(child: Text('Erro ao carregar adicionais')),
                              data: (vendorAdditionals) => ListView.separated(
                                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                                itemCount: vendorAdditionals.length,
                                separatorBuilder: (_, __) => const SizedBox(height: 12),
                                itemBuilder: (context, i) {
                                  final a = vendorAdditionals[i];
                                  final idKey = 'add_${a.id}';
                                  final isActive = _active[idKey] ?? a.isActive;

                                  return Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    decoration: BoxDecoration(
                                      color: AppColors.surface,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 36,
                                          height: 36,
                                          decoration: BoxDecoration(
                                            color: AppColors.primary
                                                .withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: const Icon(Icons.add_circle,
                                              color: AppColors.primary, size: 20),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            children: [
                                              Switch(
                                                value: isActive,
                                                onChanged: (val) {
                                                  setState(() => _active[idKey] = val);
                                                  // TODO: Call API to update additional
                                                },
                                                activeColor: AppColors.primary,
                                              ),
                                              Text(isActive ? 'Ativo' : 'Inativo',
                                                  style: const TextStyle(
                                                      fontSize: 12,
                                                      color: AppColors.primary,
                                                      fontWeight: FontWeight.w600)),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _tabCtrl.index == 0
            ? context.push('/vendor/create-product')
            : context.push('/vendor/create-additional'),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class _ProductListItem extends StatelessWidget {
  final ProductModel product;
  final bool active;
  final ValueChanged<bool> onToggle;
  final VoidCallback onTap;

  const _ProductListItem({
    required this.product,
    required this.active,
    required this.onToggle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 6,
                offset: const Offset(0, 2))
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.fastfood,
                  color: AppColors.textLight, size: 28),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark)),
                  Text(_currency.format(product.price),
                      style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600)),
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: active
                          ? AppColors.open.withOpacity(0.12)
                          : AppColors.closed.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      active ? 'EM ESTOQUE' : 'INDISPONÍVEL',
                      style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: active ? AppColors.open : AppColors.closed),
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: active,
              onChanged: onToggle,
              activeThumbColor: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}
