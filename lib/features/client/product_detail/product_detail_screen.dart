import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/mock/mock_data.dart';
import '../../../data/models/cart_model.dart';
import '../../../data/models/product_model.dart';
import '../cart/cart_provider.dart';

final _currency = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

class ProductDetailScreen extends ConsumerStatefulWidget {
  final ProductModel product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  ConsumerState<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  int _qty = 1;
  final Map<String, int> _addQty = {};
  final Set<String> _removed = {};

  double get _total {
    final addTotal = widget.product.additionals.fold<double>(
        0.0,
        (sum, a) =>
            sum + a.price * (_addQty[a.id] ?? 0));
    return (widget.product.price + addTotal) * _qty;
  }

  void _addToCart() {
    final selected = widget.product.additionals
        .where((a) => (_addQty[a.id] ?? 0) > 0)
        .map((a) =>
            SelectedAdditional(additional: a, qty: _addQty[a.id]!))
        .toList();

    final store = mockStores.firstWhere(
        (s) => s.id == widget.product.storeId,
        orElse: () => mockStores.first);

    ref.read(cartProvider.notifier).addItem(
        widget.product, store.name, _qty, selected, _removed.toList());

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${widget.product.name} adicionado ao carrinho!'),
        backgroundColor: AppColors.primary,
        duration: const Duration(seconds: 1),
      ),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              slivers: [
                // App bar + imagem
                SliverAppBar(
                  expandedHeight: 220,
                  pinned: true,
                  backgroundColor: AppColors.background,
                  leading: IconButton(
                    icon: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.arrow_back_ios,
                          size: 18, color: AppColors.textDark),
                    ),
                    onPressed: () => context.pop(),
                  ),
                  actions: [
                    IconButton(
                      icon: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.search, size: 20,
                            color: AppColors.textDark),
                      ),
                      onPressed: () {},
                    ),
                    const SizedBox(width: 8),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      color: AppColors.surface,
                      child: product.imageUrl != null
                          ? Image.network(product.imageUrl!, fit: BoxFit.cover)
                          : const Center(
                              child: Icon(Icons.fastfood,
                                  size: 100, color: AppColors.textLight),
                            ),
                    ),
                  ),
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Nome + preço
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(product.name,
                                      style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.textDark)),
                                  const SizedBox(height: 4),
                                  Text('Caracterizado por ${_getStoreName()}',
                                      style: const TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textLight)),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(_currency.format(product.price),
                                    style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.textDark)),
                              ],
                            ),
                          ],
                        ),

                        // Adicionais
                        if (product.additionals.isNotEmpty) ...[
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Adicionais',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textDark)),
                              Text('OPCIONAL',
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textLight,
                                      fontWeight: FontWeight.w600)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ...product.additionals.map((add) {
                            final qty = _addQty[add.id] ?? 0;
                            return Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(add.name,
                                            style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.textDark)),
                                        Text(
                                            '+ ${_currency.format(add.price)}',
                                            style: const TextStyle(
                                                fontSize: 12,
                                                color: AppColors.primary,
                                                fontWeight: FontWeight.w600)),
                                      ],
                                    ),
                                  ),
                                  _QtyControl(
                                    qty: qty,
                                    onMinus: () {
                                      if (qty > 0) {
                                        setState(() =>
                                            _addQty[add.id] = qty - 1);
                                      }
                                    },
                                    onPlus: () {
                                      setState(
                                          () => _addQty[add.id] = qty + 1);
                                    },
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],

                        // Remover ingredientes
                        if (product.removableIngredients.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Remover Ingredientes',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textDark)),
                              const Text('Remova até você!',
                                  style: TextStyle(
                                      fontSize: 11, color: AppColors.textLight)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: product.removableIngredients.map((ing) {
                              final selected = _removed.contains(ing);
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    if (selected) {
                                      _removed.remove(ing);
                                    } else {
                                      _removed.add(ing);
                                    }
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: selected
                                        ? AppColors.error.withOpacity(0.1)
                                        : AppColors.surface,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: selected
                                          ? AppColors.error
                                          : AppColors.inputBorder,
                                    ),
                                  ),
                                  child: Text(ing,
                                      style: TextStyle(
                                          fontSize: 13,
                                          color: selected
                                              ? AppColors.error
                                              : AppColors.textMedium,
                                          fontWeight: FontWeight.w500)),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 100),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bottom bar
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Qty selector
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.inputBorder),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove, size: 18),
                        onPressed: () {
                          if (_qty > 1) setState(() => _qty--);
                        },
                        color: AppColors.textMedium,
                      ),
                      Text('$_qty',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w700)),
                      IconButton(
                        icon: const Icon(Icons.add, size: 18),
                        onPressed: () => setState(() => _qty++),
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _addToCart,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        'ADICIONAR ${_currency.format(_total)}',
                        style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getStoreName() {
    return mockStores
        .firstWhere((s) => s.id == widget.product.storeId,
            orElse: () => mockStores.first)
        .name;
  }
}

class _QtyControl extends StatelessWidget {
  final int qty;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  const _QtyControl(
      {required this.qty, required this.onMinus, required this.onPlus});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: onMinus,
          child: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.inputBorder),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.remove, size: 16, color: AppColors.textMedium),
          ),
        ),
        SizedBox(
          width: 32,
          child: Text('$qty',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w700)),
        ),
        GestureDetector(
          onTap: onPlus,
          child: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.add, size: 16, color: Colors.white),
          ),
        ),
      ],
    );
  }
}
