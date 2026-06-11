import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../cart/cart_provider.dart';
import '../../../data/providers/orders_provider.dart';

final _currency = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final Map<String, String> _selectedTime = {};
  final Map<String, String> _selectedPayment = {};

  final _timeSlots = ['12:30 - 13:00', '13:00 - 13:30', '13:30 - 14:00'];
  bool _isLoading = false;

  Future<void> _sendOrder() async {
    final stores = ref.read(cartProvider);
    if (stores.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      final ordersApi = ref.read(ordersApiProvider);

      for (final store in stores) {
        await ordersApi.clearCart();

        for (final item in store.items) {
          String? note;
          if (item.removedIngredients.isNotEmpty) {
            note = 'Remover: ${item.removedIngredients.join(', ')}';
          }
          final extraIds =
              item.additionals.map((a) => a.additional.id).toList();

          await ordersApi.addCartItem(
            productId: item.product.id,
            quantity: item.quantity,
            note: note,
            extraIds: extraIds,
          );
        }

        await ordersApi.createOrder();
      }

      ref.read(cartProvider.notifier).clear();

      if (!mounted) return;
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.open.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle,
                    color: AppColors.open, size: 40),
              ),
              const SizedBox(height: 16),
              const Text('Pedido enviado!',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              const Text('Seu pedido foi recebido e está sendo preparado.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textMedium)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                context.go('/orders');
              },
              child: const Text('Ver Pedidos',
                  style: TextStyle(
                      color: AppColors.primary, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao enviar pedido: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final stores = ref.watch(cartProvider);
    final total = ref.watch(cartTotalProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => context.pop(),
        ),
        title: const Text('Confirmar Pedido'),
        actions: [
          IconButton(
              icon: const Icon(Icons.shopping_cart_outlined), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              children: [
                ...stores.map((store) {
                  final timeKey = store.storeId;
                  final payKey = store.storeId;
                  _selectedTime.putIfAbsent(timeKey, () => _timeSlots[0]);
                  _selectedPayment.putIfAbsent(payKey, () => 'PIX');

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 8,
                            offset: const Offset(0, 2))
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Store header
                        Padding(
                          padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
                          child: Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.store,
                                    color: AppColors.primary, size: 20),
                              ),
                              const SizedBox(width: 10),
                              Text(store.storeName,
                                  style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700)),
                            ],
                          ),
                        ),
                        const Divider(height: 1),

                        // Items
                        ...store.items.map((item) => Padding(
                              padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
                              child: Row(
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                        color: AppColors.surface,
                                        borderRadius: BorderRadius.circular(8)),
                                    child: const Icon(Icons.fastfood,
                                        color: AppColors.textLight),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                        '${item.quantity}x ${item.product.name}',
                                        style: const TextStyle(
                                            fontSize: 13,
                                            color: AppColors.textDark)),
                                  ),
                                  Text(_currency.format(item.total),
                                      style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700)),
                                ],
                              ),
                            )),

                        const SizedBox(height: 10),
                        const Divider(height: 1),

                        // Horário
                        const Padding(
                          padding: EdgeInsets.fromLTRB(14, 12, 14, 4),
                          child: Text('AGEND RETIRADA',
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textLight,
                                  letterSpacing: 1)),
                        ),
                        SizedBox(
                          height: 40,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            itemCount: _timeSlots.length,
                            itemBuilder: (_, i) {
                              final t = _timeSlots[i];
                              final active = _selectedTime[timeKey] == t;
                              return GestureDetector(
                                onTap: () =>
                                    setState(() => _selectedTime[timeKey] = t),
                                child: Container(
                                  margin: const EdgeInsets.only(right: 8),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: active
                                        ? AppColors.primary
                                        : AppColors.surface,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                        color: active
                                            ? AppColors.primary
                                            : AppColors.inputBorder),
                                  ),
                                  child: Text(t,
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: active
                                              ? Colors.white
                                              : AppColors.textMedium)),
                                ),
                              );
                            },
                          ),
                        ),

                        // Pagamento
                        const Padding(
                          padding: EdgeInsets.fromLTRB(14, 12, 14, 4),
                          child: Text('FORMA DE PAGAMENTO',
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textLight,
                                  letterSpacing: 1)),
                        ),
                        _PaymentOption(
                          label: 'PIX',
                          icon: Icons.pix,
                          selected: _selectedPayment[payKey] == 'PIX',
                          onTap: () =>
                              setState(() => _selectedPayment[payKey] = 'PIX'),
                        ),
                        _PaymentOption(
                          label: 'Cartão',
                          icon: Icons.credit_card,
                          selected: _selectedPayment[payKey] == 'Cartão',
                          onTap: () => setState(
                              () => _selectedPayment[payKey] = 'Cartão'),
                        ),
                        const SizedBox(height: 14),
                      ],
                    ),
                  );
                }),

                // Total
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total do Pedido',
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textDark)),
                      Text(_currency.format(total),
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textDark)),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, -2))
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _sendOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : const Text('ENVIAR PEDIDO →',
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: Colors.white)),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Total a pagar',
                        style: TextStyle(color: AppColors.textMedium)),
                    Text(_currency.format(total),
                        style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary)),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: _isLoading ? null : _sendOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : const Text('Confirmar',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PaymentOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _PaymentOption({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 4, 14, 4),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.textMedium),
            const SizedBox(width: 10),
            Expanded(
                child: Text(label,
                    style: const TextStyle(
                        fontSize: 14, color: AppColors.textDark))),
            Radio<bool>(
              value: true,
              groupValue: selected,
              onChanged: (_) => onTap(),
              activeColor: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}
