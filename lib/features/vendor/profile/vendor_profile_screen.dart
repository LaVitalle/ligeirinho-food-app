import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/auth_provider.dart';

class VendorProfileScreen extends ConsumerStatefulWidget {
  const VendorProfileScreen({super.key});

  @override
  ConsumerState<VendorProfileScreen> createState() =>
      _VendorProfileScreenState();
}

class _VendorProfileScreenState extends ConsumerState<VendorProfileScreen> {
  final _nameCtrl =
      TextEditingController(text: 'Ligeirinho Burger & Co.');
  final _emailCtrl =
      TextEditingController(text: 'contato@ligeirinhoburger.com');
  final _cnpjCtrl =
      TextEditingController(text: '12.345.678/0001-99');
  final _blockCtrl = TextEditingController(text: 'Bloco B, Sala 402');

  void _logout() {
    ref.read(authProvider.notifier).logout();
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            children: [
              // Store header
              Row(
                children: [
                  const Expanded(
                    child: Text('Meu Perfil',
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textDark)),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.store,
                            color: AppColors.primary, size: 16),
                        SizedBox(width: 6),
                        Text('Ligeirinho Food',
                            style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                                fontSize: 13)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Foto loja
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  const CircleAvatar(
                    radius: 52,
                    backgroundColor: AppColors.surface,
                    child: Icon(Icons.store,
                        size: 52, color: AppColors.textLight),
                  ),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child:
                        const Icon(Icons.camera_alt, size: 17, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Text('Ligeirinho Burger & Co.',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark)),
              const Text('ID da Loja #LF-8828',
                  style: TextStyle(fontSize: 12, color: AppColors.textLight)),
              const SizedBox(height: 28),

              _field(icon: Icons.store_outlined, label: 'Nome da Loja', controller: _nameCtrl),
              const SizedBox(height: 14),
              _field(icon: Icons.email_outlined, label: 'E-mail Comercial', controller: _emailCtrl,
                  keyboard: TextInputType.emailAddress),
              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: _field(
                        icon: Icons.badge_outlined,
                        label: 'CNPJ/ID',
                        controller: _cnpjCtrl),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _field(
                        icon: Icons.location_on_outlined,
                        label: 'Bloco/Andar',
                        controller: _blockCtrl),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Perfil atualizado!'),
                        backgroundColor: AppColors.open,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('SALVAR ALTERAÇÕES',
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: Colors.white)),
                ),
              ),
              const SizedBox(height: 16),

              TextButton.icon(
                onPressed: _logout,
                icon: const Icon(Icons.logout, color: AppColors.error, size: 18),
                label: const Text('→ SAIR DA CONTA',
                    style: TextStyle(
                        color: AppColors.error, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field({
    required IconData icon,
    required String label,
    required TextEditingController controller,
    TextInputType? keyboard,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textLight)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboard,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppColors.primary, size: 18),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _cnpjCtrl.dispose();
    _blockCtrl.dispose();
    super.dispose();
  }
}
