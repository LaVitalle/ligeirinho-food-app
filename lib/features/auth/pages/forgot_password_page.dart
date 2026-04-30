import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/injection_container.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    if (_formKey.currentState?.validate() != true) return;
    context
        .read<AuthBloc>()
        .add(ForgotPasswordSubmitted(email: _emailController.text.trim()));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AuthBloc>(),
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppBar(
          backgroundColor: AppColors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: AppColors.black),
            onPressed: () => context.go('/login'),
          ),
        ),
        body: SafeArea(
          child: BlocConsumer<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is AuthActionSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message)),
                );
                context.go('/login');
              } else if (state is AuthFailure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.error)),
                );
              }
            },
            builder: (context, state) {
              final isLoading = state is AuthLoading;

              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                const SizedBox(height: 16),
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.lock_reset,
                    color: AppColors.white,
                    size: 36,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Esqueceu sua senha?',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Informe seu e-mail cadastrado e enviaremos um código para redefinir sua senha.',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.grey,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 40),
                CustomTextField(
                  label: 'Seu E-mail',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon:
                      const Icon(Icons.email_outlined, color: AppColors.grey),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'E-mail obrigatório';
                    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                    if (!emailRegex.hasMatch(v)) return 'E-mail inválido';
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                CustomButton(
                  label: 'ENVIAR CÓDIGO',
                  onPressed: isLoading ? null : () => _submit(context),
                  isLoading: isLoading,
                ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
