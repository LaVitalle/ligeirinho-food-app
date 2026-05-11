import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/mock/mock_data.dart';

final _currency = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  final Map<String, bool> _active = {};

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    for (final p in mockProducts) {
      _active[p.id] = p.isActive;
    }
    for (final a in mockAdditionals) {
      _active['add_${a.id}'] = a.isActive;
    }
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vendorProducts =
        mockProducts.where((p) => p.storeId == 's2').toList();

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
              child: TabBarView(
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
                        child: ListView.builder(
                          padding:
                              const EdgeInsets.fromLTRB(20, 0, 20, 80),
                          itemCount: vendorProducts.length,
                          itemBuilder: (_, i) {
                            final p = vendorProducts[i];
                            return _ProductListItem(
                              product: p,
                              active: _active[p.id] ?? true,
                              onToggle: (v) =>
                                  setState(() => _active[p.id] = v),
                              onTap: () =>
                                  context.push('/vendor/create-product'),
                            );
                          },
                        ),
                      ),
                    ],
                  ),

                  // Adicionais tab
                  Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          padding:
                              const EdgeInsets.fromLTRB(20, 8, 20, 80),
                          itemCount: mockAdditionals.length,
                          itemBuilder: (_, i) {
                            final a = mockAdditionals[i];
                            final key = 'add_${a.id}';
                            return Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                      color:
                                          Colors.black.withOpacity(0.05),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2))
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                        color: AppColors.primary
                                            .withOpacity(0.1),
                                        borderRadius:
                                            BorderRadius.circular(8)),
                                    child: const Icon(Icons.add_circle,
                                        color: AppColors.primary, size: 20),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(a.name,
                                            style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.textDark)),
                                        Text(_currency.format(a.price),
                                            style: const TextStyle(
                                                fontSize: 12,
                                                color: AppColors.primary,
                                                fontWeight:
                                                    FontWeight.w600)),
                                      ],
                                    ),
                                  ),
                                  Switch(
                                    value: _active[key] ?? a.isActive,
                                    onChanged: (v) =>
                                        setState(() => _active[key] = v),
                                    activeThumbColor: AppColors.primary,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
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
