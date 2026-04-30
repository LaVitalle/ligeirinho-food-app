import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/injection_container.dart';
import '../../../core/theme/app_colors.dart';
import '../bloc/stores_cubit.dart';
import '../bloc/stores_state.dart';

class StoresPage extends StatelessWidget {
  const StoresPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<StoresCubit>()..fetchStores(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Instituições')),
        body: BlocBuilder<StoresCubit, StoresState>(
          builder: (context, state) {
            if (state is StoresLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is StoresError) {
              return Center(child: Text(state.message));
            }
            if (state is StoresLoaded) {
              if (state.institutions.isEmpty) {
                return const Center(child: Text('Nenhuma instituição encontrada.'));
              }

              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemBuilder: (context, index) {
                  final item = state.institutions[index];
                  return ListTile(
                    tileColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    title: Text(item.name),
                    subtitle: Text('ID: ${item.id}'),
                  );
                },
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemCount: state.institutions.length,
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
