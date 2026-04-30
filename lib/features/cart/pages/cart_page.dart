import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/injection_container.dart';
import '../../../core/widgets/custom_button.dart';
import '../bloc/cart_cubit.dart';
import '../bloc/cart_state.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<CartCubit>(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Carrinho')),
        body: BlocBuilder<CartCubit, CartState>(
          builder: (context, state) {
            if (state.items.isEmpty) {
              return const Center(child: Text('Seu carrinho está vazio.'));
            }

            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: state.items.length,
                      itemBuilder: (context, index) {
                        final item = state.items[index];
                        return ListTile(
                          title: Text(item.name),
                          subtitle: Text('Qtd: ${item.quantity}'),
                          trailing: Text('R\$ ${item.total.toStringAsFixed(2)}'),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text('Total: R\$ ${state.total.toStringAsFixed(2)}'),
                  const SizedBox(height: 12),
                  CustomButton(
                    label: 'FINALIZAR PEDIDO',
                    onPressed: () {},
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
