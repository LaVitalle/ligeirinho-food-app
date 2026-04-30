import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/injection_container.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_button.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/models/user_model.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  UserModel? _user;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await sl<AuthBloc>().getCurrentUser();
    if (!mounted) return;
    setState(() => _user = user);
  }

  Future<void> _logout(BuildContext context) async {
    await sl<AuthBloc>().logout();
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: const Text(
          'Meu Perfil',
          style: TextStyle(
            color: AppColors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(context),
            const SizedBox(height: 16),
            _buildInfoSection(),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: CustomButton(
                label: 'SAIR',
                variant: CustomButtonVariant.outline,
                onPressed: () async => _logout(context),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(
                radius: 52,
                backgroundColor: AppColors.lightGrey,
                child: const Icon(
                  Icons.person,
                  size: 56,
                  color: AppColors.grey,
                ),
              ),
              GestureDetector(
                onTap: () {
                  // TODO: open image picker
                },
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    color: AppColors.white,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          TextButton(
            onPressed: () {
              // TODO: open image picker
            },
            child: const Text(
              'Editar Foto',
              style: TextStyle(color: AppColors.primary, fontSize: 13),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _user?.fullName ?? 'Nome do Usuário',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _user?.role ?? 'Cliente',
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'INFORMAÇÕES',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.grey,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            Icons.person_outline,
            'Nome',
            _user?.fullName ?? 'Nome do Usuário',
          ),
          const Divider(height: 24),
          _buildInfoRow(
            Icons.email_outlined,
            'E-mail',
            _user?.email ?? 'usuario@email.com',
          ),
          const Divider(height: 24),
          _buildInfoRow(
            Icons.business_outlined,
            'Instituição',
            _user?.institutionId ?? 'Não informado',
          ),
          const Divider(height: 24),
          _buildInfoRow(
            Icons.badge_outlined,
            'Tipo de conta',
            _user?.role ?? 'Cliente',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.grey,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
