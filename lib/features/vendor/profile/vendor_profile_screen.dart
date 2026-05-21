import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/auth_provider.dart';
import '../../../data/providers/catalog_providers.dart';

class VendorProfileScreen extends ConsumerStatefulWidget {
  const VendorProfileScreen({super.key});

  @override
  ConsumerState<VendorProfileScreen> createState() =>
      _VendorProfileScreenState();
}

class _VendorProfileScreenState extends ConsumerState<VendorProfileScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _cnpjCtrl = TextEditingController();
  final _blockCtrl = TextEditingController();
  final _roomCtrl = TextEditingController();

  bool _isLoading = false;
  bool _initialized = false;

  void _logout() {
    ref.read(authProvider.notifier).logout();
    context.go('/login');
  }

  void _saveProfile() async {
    setState(() => _isLoading = true);
    try {
      final api = ref.read(catalogApiServiceProvider);
      await api.updateMyCanteen({
        'name': _nameCtrl.text.trim(),
        'cnpj': _cnpjCtrl.text.trim(),
        'block': _blockCtrl.text.trim(),
        'room': _roomCtrl.text.trim(),
      });
      
      ref.invalidate(myCanteenProvider);
      
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
          SnackBar(content: Text('Erro: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final myCanteenAsync = ref.watch(myCanteenProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: myCanteenAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Erro ao carregar perfil: $e')),
          data: (canteen) {
            if (!_initialized) {
              _nameCtrl.text = canteen.name;
              _cnpjCtrl.text = canteen.cnpj ?? '';
              _blockCtrl.text = canteen.block ?? '';
              _initialized = true;
            }

            return SingleChildScrollView(
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
                        child: const Icon(Icons.camera_alt, size: 17, color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(canteen.name,
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark)),
                  Text('ID da Loja #${canteen.id.substring(0, 8)}',
                      style: const TextStyle(fontSize: 12, color: AppColors.textLight)),
                  const SizedBox(height: 28),

                  _field(icon: Icons.store_outlined, label: 'Nome da Loja', controller: _nameCtrl),
                  const SizedBox(height: 14),
                  _field(icon: Icons.email_outlined, label: 'E-mail Comercial (Somente Leitura)', controller: _emailCtrl,
                      keyboard: TextInputType.emailAddress, readOnly: true),
                  const SizedBox(height: 14),

                  Row(
                    children: [
                      Expanded(
                        child: _field(
                            icon: Icons.badge_outlined,
                            label: 'CNPJ',
                            controller: _cnpjCtrl),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _field(
                            icon: Icons.location_on_outlined,
                            label: 'Bloco',
                            controller: _blockCtrl),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _field(
                      icon: Icons.meeting_room_outlined,
                      label: 'Sala',
                      controller: _roomCtrl),
                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _isLoading 
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
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
                    label: const Text('→ SAIR DA CONTA',
                        style: TextStyle(
                            color: AppColors.error, fontWeight: FontWeight.w700)),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _field({
    required IconData icon,
    required String label,
    required TextEditingController controller,
    TextInputType? keyboard,
    bool readOnly = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.primary, size: 16),
          SizedBox(width: 6),
          Expanded(
            child: TextFormField(
              controller: controller,
              keyboardType: keyboard,
              readOnly: readOnly,
              style: const TextStyle(fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                prefixIcon: Icon(icon, color: AppColors.primary, size: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _cnpjCtrl.dispose();
    _blockCtrl.dispose();
    _roomCtrl.dispose();
    super.dispose();
  }
}
