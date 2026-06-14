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
                    child: Text('Nenhum pedido em aberto.',
                        style: TextStyle(color: AppColors.textMedium)),
                  );
                }
                return Column(
                  children: orders.map((o) => _OpenOrderCard(order: o)).toList(),
                );
              },
            ),
            const SizedBox(height: 20),
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

class _OpenOrderCard extends ConsumerStatefulWidget {
  final Map<String, dynamic> order;
  const _OpenOrderCard({required this.order});

  @override
  ConsumerState<_OpenOrderCard> createState() => _OpenOrderCardState();
}

class _OpenOrderCardState extends ConsumerState<_OpenOrderCard> {
  bool _loading = false;

  String get _status => widget.order['status'] ?? '';

  String get _statusLabel {
    switch (_status) {
      case 'AGUARDANDO':
        return 'Aguardando';
      case 'EM_PREPARO':
        return 'Em preparo';
      case 'PRONTO':
      case 'AGUARDANDO_RETIRADA':
        return 'Pronto para retirada';
      default:
        return 'Processando';
    }
  }

  Color get _statusColor {
    switch (_status) {
      case 'AGUARDANDO':
        return AppColors.primary;
      case 'EM_PREPARO':
        return const Color(0xFF2196F3);
      case 'PRONTO':
      case 'AGUARDANDO_RETIRADA':
        return AppColors.open;
      default:
        return AppColors.primary;
    }
  }

  Future<void> _pickup() async {
    setState(() => _loading = true);
    try {
      await ref.read(ordersApiProvider).pickupOrder(widget.order['id']);
      ref.invalidate(clientOrdersProvider('open'));
      ref.invalidate(clientOrdersProvider('history'));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _cancel() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancelar pedido'),
        content: const Text('Tem certeza que deseja cancelar este pedido?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Não'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sim, cancelar',
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    setState(() => _loading = true);
    try {
      await ref.read(ordersApiProvider).cancelOrder(widget.order['id']);
      ref.invalidate(clientOrdersProvider('open'));
      ref.invalidate(clientOrdersProvider('history'));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final canPickup = _status == 'AGUARDANDO_RETIRADA' || _status == 'PRONTO';
    final canCancel = _status == 'AGUARDANDO';

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
                    Text('Pedido #${widget.order['id'].toString().substring(0, 6)}',
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(
                        widget.order['createdAt'] != null
                            ? _dateFmt.format(DateTime.parse(widget.order['createdAt']))
                            : '',
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textMedium)),
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
          ...((widget.order['items'] as List<dynamic>?) ?? []).map((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Text('${item['quantity']}x ',
                      style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700)),
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
              Text(
                  _currency.format(
                      double.tryParse(widget.order['total']?.toString() ?? '0')),
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark)),
            ],
          ),
          if (canPickup || canCancel) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                if (canCancel)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _loading ? null : _cancel,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Cancelar'),
                    ),
                  ),
                if (canCancel && canPickup) const SizedBox(width: 8),
                if (canPickup)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _loading ? null : _pickup,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.open,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: _loading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : const Text('Confirmar retirada',
                              style: TextStyle(color: Colors.white)),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _HistoryOrderCard extends ConsumerStatefulWidget {
  final Map<String, dynamic> order;
  const _HistoryOrderCard({required this.order});

  @override
  ConsumerState<_HistoryOrderCard> createState() => _HistoryOrderCardState();
}

class _HistoryOrderCardState extends ConsumerState<_HistoryOrderCard> {
  bool _loading = false;

  bool get _canRate =>
      widget.order['status'] == 'FINALIZADO' && widget.order['rating'] == null;

  Future<void> _showRatingDialog() async {
    int selectedRating = 5;
    final commentCtrl = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Avaliar pedido'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) {
                  return GestureDetector(
                    onTap: () => setDialogState(() => selectedRating = i + 1),
                    child: Icon(
                      i < selectedRating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 36,
                    ),
                  );
                }),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: commentCtrl,
                maxLines: 2,
                decoration: const InputDecoration(
                  hintText: 'Comentário (opcional)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary),
              child: const Text('Enviar', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );

    if (confirmed != true) return;

    setState(() => _loading = true);
    try {
      await ref.read(ordersApiProvider).rateOrder(
            widget.order['id'],
            selectedRating,
            comment: commentCtrl.text.trim().isEmpty ? null : commentCtrl.text.trim(),
          );
      ref.invalidate(clientOrdersProvider('history'));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
      commentCtrl.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = widget.order['status'] ?? '';
    final isCanceled = status == 'CANCELADO';
    final color = isCanceled ? AppColors.error : AppColors.textMedium;
    final existingRating = widget.order['rating'] as int?;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                    isCanceled ? Icons.cancel_outlined : Icons.check_circle_outline,
                    color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Pedido #${widget.order['id'].toString().substring(0, 6)}',
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(
                        widget.order['createdAt'] != null
                            ? _dateFmt.format(DateTime.parse(widget.order['createdAt']))
                            : '',
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textMedium)),
                    if (existingRating != null)
                      Row(
                        children: List.generate(
                          5,
                          (i) => Icon(
                            i < existingRating ? Icons.star : Icons.star_border,
                            color: Colors.amber,
                            size: 14,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Text(
                  _currency.format(
                      double.tryParse(widget.order['total']?.toString() ?? '0')),
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark)),
            ],
          ),
          if (_canRate) ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _loading ? null : _showRatingDialog,
                icon: const Icon(Icons.star_outline, size: 16),
                label: const Text('Avaliar pedido'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
