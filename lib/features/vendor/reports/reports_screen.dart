import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/providers/reports_provider.dart';

final _currency = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final revenueAsync = ref.watch(revenueProvider);
    final ordersCountAsync = ref.watch(ordersCountProvider);
    final revenueTrendAsync = ref.watch(revenueTrendProvider);
    final topProductsAsync = ref.watch(topProductsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 80),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  const Expanded(
                    child: Text('Relatórios',
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textDark)),
                  ),
                  IconButton(
                    icon: const Icon(Icons.person_outline),
                    onPressed: () => context.push('/vendor/profile'),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Cards de métricas
              Row(
                children: [
                  Expanded(
                    child: revenueAsync.when(
                      data: (data) => _MetricBig(
                        icon: Icons.attach_money,
                        label: 'RECEITA TOTAL',
                        value: _currency.format(data['current']),
                        change: '${data['deltaPercent'] > 0 ? '+' : ''}${data['deltaPercent']}%',
                        color: AppColors.primary,
                        changeNegative: data['deltaPercent'] < 0,
                      ),
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (e, _) => const Text('Erro'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ordersCountAsync.when(
                      data: (data) => _MetricBig(
                        icon: Icons.shopping_bag_outlined,
                        label: 'TOTAL PEDIDOS',
                        value: '${data['current']}',
                        change: '${data['deltaPercent'] > 0 ? '+' : ''}${data['deltaPercent']}%',
                        color: const Color(0xFF2196F3),
                        changeNegative: data['deltaPercent'] < 0,
                      ),
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (e, _) => const Text('Erro'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Gráfico
              revenueTrendAsync.when(
                data: (trendData) {
                  if (trendData.isEmpty) {
                    return const SizedBox.shrink();
                  }

                  // Extract dates and totals from backend response
                  // Expected format: [{date: '2023-10-01', total: 100}, ...] (already sorted past to present)
                  final spots = <FlSpot>[];
                  final daysLabels = <String>[];
                  double maxTotal = 0;
                  double todayTotal = 0;

                  for (int i = 0; i < trendData.length; i++) {
                    final totalStr = trendData[i]['total']?.toString() ?? '0';
                    final total = double.tryParse(totalStr) ?? 0;
                    if (total > maxTotal) maxTotal = total;
                    if (i == trendData.length - 1) todayTotal = total;

                    spots.add(FlSpot(i.toDouble(), total));

                    // Simple short day name or DD/MM
                    final dateStr = trendData[i]['date']?.toString() ?? '';
                    if (dateStr.isNotEmpty) {
                      try {
                        final dt = DateTime.parse(dateStr);
                        final dayStr = DateFormat('E', 'pt_BR').format(dt).substring(0, 1).toUpperCase();
                        daysLabels.add(dayStr);
                      } catch (_) {
                        daysLabels.add('');
                      }
                    } else {
                      daysLabels.add('');
                    }
                  }

                  // Add 20% margin to max Y axis
                  final maxY = maxTotal > 0 ? maxTotal * 1.2 : 100.0;

                  return Container(
                    padding: const EdgeInsets.all(16),
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
                        const Text('Tendência de Receita',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textDark)),
                        const Text('Últimos 7 dias',
                            style: TextStyle(
                                fontSize: 11, color: AppColors.textLight)),
                        const SizedBox(height: 4),
                        Align(
                          alignment: Alignment.topRight,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text('${_currency.format(todayTotal)} hoje',
                                style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary)),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 160,
                          child: LineChart(
                            LineChartData(
                              gridData: FlGridData(
                                show: true,
                                drawVerticalLine: false,
                                getDrawingHorizontalLine: (value) => const FlLine(
                                  color: AppColors.divider,
                                  strokeWidth: 1,
                                ),
                              ),
                              titlesData: FlTitlesData(
                                leftTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false)),
                                rightTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false)),
                                topTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false)),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (value, meta) {
                                      final i = value.toInt();
                                      if (i < 0 || i >= daysLabels.length) {
                                        return const SizedBox.shrink();
                                      }
                                      return Text(daysLabels[i],
                                          style: const TextStyle(
                                              fontSize: 11,
                                              color: AppColors.textLight));
                                    },
                                  ),
                                ),
                              ),
                              borderData: FlBorderData(show: false),
                              lineBarsData: [
                                LineChartBarData(
                                  spots: spots,
                                  isCurved: true,
                                  color: AppColors.primary,
                                  barWidth: 3,
                                  dotData: const FlDotData(show: false),
                                  belowBarData: BarAreaData(
                                    show: true,
                                    color: AppColors.primary.withValues(alpha: 0.1),
                                  ),
                                ),
                              ],
                              minX: 0,
                              maxX: spots.length > 0 ? (spots.length - 1).toDouble() : 6.0,
                              minY: 0,
                              maxY: maxY,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => const Center(child: Text('Erro ao carregar gráfico')),
              ),

              const SizedBox(height: 20),

              // Produtos mais vendidos
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Produtos mais vendidos',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark)),
                  TextButton(
                    onPressed: () {},
                    child: const Text('Ver tudo',
                        style: TextStyle(color: AppColors.primary, fontSize: 13)),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              topProductsAsync.when(
                data: (products) {
                  if (products.isEmpty) {
                    return const Center(child: Text('Nenhum dado de vendas ainda'));
                  }
                  return Column(
                    children: products.map((p) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _TopProduct(
                          name: p['name'],
                          info: '${p['quantity']} vendidos esta mês',
                          value: _currency.format(p['revenue']),
                          change: '',
                          positive: true,
                        ),
                      );
                    }).toList(),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => const Center(child: Text('Erro ao carregar produtos')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetricBig extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String change;
  final Color color;
  final bool changeNegative;

  const _MetricBig({
    required this.icon,
    required this.label,
    required this.value,
    required this.change,
    required this.color,
    this.changeNegative = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
              const SizedBox(width: 6),
              Text(label,
                  style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textLight,
                      letterSpacing: 0.5)),
            ],
          ),
          const SizedBox(height: 8),
          Text(value,
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.w800, color: color)),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(changeNegative ? Icons.arrow_downward : Icons.arrow_upward, size: 12, color: changeNegative ? AppColors.error : AppColors.open),
              Text(change,
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: changeNegative ? AppColors.error : AppColors.open)),
            ],
          ),
        ],
      ),
    );
  }
}

class _TopProduct extends StatelessWidget {
  final String name;
  final String info;
  final String value;
  final String change;
  final bool positive;

  const _TopProduct({
    required this.name,
    required this.info,
    required this.value,
    required this.change,
    required this.positive,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
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
            width: 48,
            height: 48,
            decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.fastfood,
                color: AppColors.textLight, size: 26),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark)),
                Text(info,
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textLight)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(value,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark)),
              Text(change,
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: positive ? AppColors.open : AppColors.error)),
            ],
          ),
        ],
      ),
    );
  }
}
