import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/auth_provider.dart';

class ClientProfileScreen extends ConsumerStatefulWidget {
  const ClientProfileScreen({super.key});

  @override
  ConsumerState<ClientProfileScreen> createState() =>
      _ClientProfileScreenState();
}

class _ClientProfileScreenState extends ConsumerState<ClientProfileScreen> {
  late TextEditingController _nameCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _instCtrl;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider);
    _nameCtrl = TextEditingController(text: user?.name ?? '');
    _emailCtrl = TextEditingController(text: user?.email ?? '');
    _phoneCtrl = TextEditingController(text: user?.phoneNumber ?? '');
    _instCtrl = TextEditingController(text: user?.institution ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _instCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _isLoading = true);
    try {
      await ref.read(authProvider.notifier).updateProfile(
            name: _nameCtrl.text,
            phone: _phoneCtrl.text,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Perfil atualizado!'),
            backgroundColor: AppColors.open,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _logout() {
    ref.read(authProvider.notifier).logout();
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => context.pop(),
        ),
        title: const Text('Meu Perfil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined),
            onPressed: () => context.push('/cart'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          children: [
            // Avatar
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                const CircleAvatar(
                  radius: 48,
                  backgroundColor: AppColors.surface,
                  child: Icon(Icons.person, size: 52, color: AppColors.textLight),
                ),
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text('Alterar foto de perfil',
                style: TextStyle(
                    fontSize: 13,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 28),

            _label('Nome Completo'),
            const SizedBox(height: 8),
            TextFormField(controller: _nameCtrl),
            const SizedBox(height: 16),

            _label('E-mail'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _emailCtrl,
              enabled: false,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.email_outlined,
                    color: AppColors.textLight, size: 20),
              ),
            ),
            const SizedBox(height: 16),

            _label('Telefone'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.phone_outlined,
                    color: AppColors.textLight, size: 20),
              ),
            ),
            const SizedBox(height: 16),

            _label('Instituição'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _instCtrl,
              enabled: false,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.school_outlined,
                    color: AppColors.textLight, size: 20),
              ),
            ),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('SALVAR ALTERAÇÕES',
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
              label: const Text('SAIR DA CONTA',
                  style: TextStyle(
                      color: AppColors.error, fontWeight: FontWeight.w700)),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(text,
          style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark)),
    );
  }
}
