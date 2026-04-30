import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/injection_container.dart';
import '../bloc/orders_cubit.dart';
import '../bloc/orders_state.dart';

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<OrdersCubit>()..fetchOrders(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Meus Pedidos')),
        body: BlocBuilder<OrdersCubit, OrdersState>(
          builder: (context, state) {
            if (state is OrdersLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is OrdersError) {
              return Center(child: Text(state.message));
            }
            if (state is OrdersLoaded) {
              if (state.orders.isEmpty) {
                return const Center(child: Text('Nenhum pedido encontrado.'));
              }

              return ListView.builder(
                itemCount: state.orders.length,
                itemBuilder: (context, index) {
                  final order = state.orders[index];
                  return ListTile(
                    title: Text('Pedido #${order.id}'),
                    subtitle: Text(order.status),
                    trailing: Text('R\$ ${order.total.toStringAsFixed(2)}'),
                  );
                },
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
