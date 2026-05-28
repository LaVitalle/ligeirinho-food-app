import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/order_model.dart';
import '../../../data/providers/orders_provider.dart';

class OrdersPanelScreen extends ConsumerStatefulWidget {
  const OrdersPanelScreen({super.key});

  @override
  ConsumerState<OrdersPanelScreen> createState() => _OrdersPanelScreenState();
}

class _OrdersPanelScreenState extends ConsumerState<OrdersPanelScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.store, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text('Ligeirinho Food',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark)),
                  ),
                  IconButton(
                    icon: const Icon(Icons.help_outline, color: AppColors.textLight),
                    onPressed: () {},
                  ),
                ],
              ),
            ),

            // Métricas
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  _MetricCard(
                    title: 'PEDIDOS ATIVOS',
                    value: '12',
                    change: '+10%',
                    icon: Icons.receipt_long,
                    color: AppColors.primary,
                  ),
                  SizedBox(width: 12),
                  _MetricCard(
                    title: 'VENDAS HOJE',
                    value: 'R\$ 450',
                    change: '-4%',
                    icon: Icons.attach_money,
                    color: AppColors.open,
                    changeNegative: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // TabBar
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                controller: _tabCtrl,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textLight,
                labelStyle: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w700),
                indicator: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 4,
                    ),
                  ],
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                tabs: const [
                  Tab(text: 'Pendentes'),
                  Tab(text: 'Em Preparo'),
                  Tab(text: 'Prontos'),
                ],
              ),
            ),

            const SizedBox(height: 8),

            Expanded(
              child: ref.watch(vendorOrdersProvider).when(
                    data: (orders) {
                      final pendentes = orders.where((o) => o['status'] == 'open').toList();
                      final preparo = orders.where((o) => o['status'] == 'preparing').toList();
                      final prontos = orders.where((o) => o['status'] == 'ready').toList();

                      return TabBarView(
                        controller: _tabCtrl,
                        children: [
                          // Pendentes
                          pendentes.isEmpty
                              ? const Center(child: Text('Nenhum pedido pendente'))
                              : ListView.builder(
                                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 80),
                                  itemCount: pendentes.length,
                                  itemBuilder: (_, i) => _VendorOrderCard(order: pendentes[i]),
                                ),
                          // Em Preparo
                          preparo.isEmpty
                              ? const Center(child: Text('Nenhum pedido em preparo'))
                              : ListView.builder(
                                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 80),
                                  itemCount: preparo.length,
                                  itemBuilder: (_, i) => _VendorOrderCard(order: preparo[i]),
                                ),
                          // Prontos
                          prontos.isEmpty
                              ? const Center(child: Text('Nenhum pedido pronto'))
                              : ListView.builder(
                                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 80),
                                  itemCount: prontos.length,
                                  itemBuilder: (_, i) => _VendorOrderCard(order: prontos[i]),
                                ),
                        ],
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(child: Text('Erro: $e')),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String change;
  final IconData icon;
  final Color color;
  final bool changeNegative;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.change,
    required this.icon,
    required this.color,
    this.changeNegative = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 18),
                const Spacer(),
                Text(change,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: changeNegative ? AppColors.error : AppColors.open)),
              ],
            ),
            const SizedBox(height: 8),
            Text(value,
                style: TextStyle(
                    fontSize: 22, fontWeight: FontWeight.w800, color: color)),
            Text(title,
                style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textLight)),
          ],
        ),
      ),
    );
  }
}

class _VendorOrderCard extends ConsumerWidget {
  final Map<String, dynamic> order;

  const _VendorOrderCard({required this.order});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = order['status'] as String? ?? 'unknown';
    final items = order['items'] as List<dynamic>? ?? [];
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
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
          Row(
            children: [
              const Text('Cliente',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark)),
              const SizedBox(width: 8),
              Text('Pedido #${order['id'].toString().substring(0, 4)}',
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textLight)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(status.toUpperCase(),
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...items.map((item) => Text('• ${item['quantity']}x ${item['productNameSnapshot']}',
              style: const TextStyle(fontSize: 13, color: AppColors.textMedium))),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.access_time, size: 14, color: AppColors.primary),
              const SizedBox(width: 4),
              const Text('Aguardando',
                  style: TextStyle(
                      fontSize: 12, color: AppColors.primary,
                      fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: ElevatedButton(
                    onPressed: () async {
                      try {
                        await ref.read(ordersApiProvider).advanceOrder(order['id']);
                        ref.invalidate(vendorOrdersProvider);
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro: $e')));
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Avançar Status',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.white)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
            ],
          ),
        ],
      ),
    );
  }
}
