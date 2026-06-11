import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/providers/orders_provider.dart';

final _currency = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
final _dateFmt = DateFormat('dd/MM - HH:mm');

class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({super.key});

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

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
    final openOrdersAsync = ref.watch(clientOrdersProvider('open'));
    final historyOrdersAsync = ref.watch(clientOrdersProvider('history'));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  const Expanded(
                    child: Text('Meus Pedidos',
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textDark)),
                  ),
                  IconButton(
                    icon: const Icon(Icons.shopping_cart_outlined),
                    onPressed: () => context.push('/cart'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Pedidos em Aberto
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text('Pedidos em Aberto',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark)),
            ),
            const SizedBox(height: 12),

            openOrdersAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Center(child: Text('Erro: $e')),
              data: (orders) {
                if (orders.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text('Nenhum pedido em aberto.', style: TextStyle(color: AppColors.textMedium)),
                  );
                }
                return Column(
                  children: orders.map((o) => _OpenOrderCard(order: o)).toList(),
                );
              },
            ),

            const SizedBox(height: 20),

            // Histórico
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text('Histórico de Pedidos',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark)),
            ),
            const SizedBox(height: 12),

            Expanded(
              child: historyOrdersAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, st) => Center(child: Text('Erro: $e')),
                data: (orders) {
                  if (orders.isEmpty) {
                    return const Center(child: Text('Nenhum pedido no histórico.'));
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 80),
                    itemCount: orders.length,
                    itemBuilder: (_, i) => _HistoryOrderCard(order: orders[i]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OpenOrderCard extends StatelessWidget {
  final Map<String, dynamic> order;
  const _OpenOrderCard({required this.order});

  String get _statusLabel {
    final status = order['status'] ?? '';
    switch (status) {
      case 'AGUARDANDO':
      case 'EM_PREPARO':
        return 'Em processo';
      case 'PRONTO':
      case 'AGUARDANDO_RETIRADA':
        return 'Aguardando retirada';
      default:
        return 'Processando';
    }
  }

  Color get _statusColor {
    final status = order['status'] ?? '';
    switch (status) {
      case 'AGUARDANDO':
        return AppColors.primary;
      case 'EM_PREPARO':
        return const Color(0xFF2196F3);
      case 'AGUARDANDO_RETIRADA':
        return AppColors.open;
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.storefront, color: AppColors.textMedium),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Pedido #${order['id'].toString().substring(0, 6)}',
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(order['createdAt'] != null ? _dateFmt.format(DateTime.parse(order['createdAt'])) : '',
                        style: const TextStyle(fontSize: 12, color: AppColors.textMedium)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(_statusLabel,
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _statusColor)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          ...((order['items'] as List<dynamic>?) ?? []).map((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Text('${item['quantity']}x ',
                      style: const TextStyle(
                          color: AppColors.primary, fontWeight: FontWeight.w700)),
                  Expanded(
                    child: Text(item['productNameSnapshot'] ?? '',
                        style: const TextStyle(color: AppColors.textDark)),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total:', style: TextStyle(color: AppColors.textMedium)),
              Text(_currency.format(double.tryParse(order['total']?.toString() ?? '0')),
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark)),
            ],
          ),
        ],
      ),
    );
  }
}

class _HistoryOrderCard extends StatelessWidget {
  final Map<String, dynamic> order;
  const _HistoryOrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final status = order['status'] ?? '';
    final isCanceled = status == 'CANCELADO';
    final color = isCanceled ? AppColors.error : AppColors.textMedium;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(isCanceled ? Icons.cancel_outlined : Icons.check_circle_outline, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Pedido #${order['id'].toString().substring(0, 6)}',
                    style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(order['createdAt'] != null ? _dateFmt.format(DateTime.parse(order['createdAt'])) : '',
                    style: const TextStyle(fontSize: 12, color: AppColors.textMedium)),
              ],
            ),
          ),
          Text(_currency.format(double.tryParse(order['total']?.toString() ?? '0')),
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark)),
        ],
      ),
    );
  }
}
