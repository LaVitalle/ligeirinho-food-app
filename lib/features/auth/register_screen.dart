import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_button.dart';
import '../../data/models/user_model.dart';
import 'auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();
  bool _obscure = true;
  bool _obscureConfirm = true;

  void _register() {
    final user = UserModel(
      id: 'u1',
      name: _nameCtrl.text.isNotEmpty ? _nameCtrl.text : 'Usuário',
      email: _emailCtrl.text.isNotEmpty ? _emailCtrl.text : 'usuario@email.com',
      registration: _codeCtrl.text,
      institution: 'Universidade Federal',
      role: UserRole.client,
    );
    ref.read(authProvider.notifier).login(user);
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/bg_login.jpg',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.5,
                  colors: [Color(0xFFFF8C00), Color(0xFFBB3000)],
                ),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  // Mascote
                  Image.asset(
                    'assets/images/mascote.png',
                    width: 160,
                    height: 160,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Icon(
                        Icons.lunch_dining, size: 72, color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  // Badge LIGEIRINHO FOOD
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF5C1A00),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFD4880A), width: 2.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Text('LIGEIRINHO',
                            style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFFFFD600),
                                letterSpacing: 2,
                                height: 1.1)),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(width: 26, height: 1.5, color: const Color(0xFFD4880A)),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              child: Text('FOOD',
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFFFFD600),
                                      letterSpacing: 4)),
                            ),
                            Container(width: 26, height: 1.5, color: const Color(0xFFD4880A)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  _buildInput(controller: _nameCtrl, hint: 'Nome', icon: Icons.person_outline),
                  const SizedBox(height: 10),
                  _buildInput(controller: _emailCtrl, hint: 'Seu e-mail', icon: Icons.email_outlined,
                      keyboard: TextInputType.emailAddress),
                  const SizedBox(height: 10),
                  _buildInput(controller: _passCtrl, hint: 'Sua senha', icon: Icons.lock_outline,
                      obscure: _obscure, suffixIcon: GestureDetector(
                        onTap: () => setState(() => _obscure = !_obscure),
                        child: Icon(_obscure ? Icons.visibility_off : Icons.visibility,
                            color: Colors.white70),
                      )),
                  const SizedBox(height: 10),
                  _buildInput(controller: _confirmCtrl, hint: 'Confirmar Senha',
                      icon: Icons.lock_outline, obscure: _obscureConfirm,
                      suffixIcon: GestureDetector(
                        onTap: () => setState(() => _obscureConfirm = !_obscureConfirm),
                        child: Icon(_obscureConfirm ? Icons.visibility_off : Icons.visibility,
                            color: Colors.white70),
                      )),
                  const SizedBox(height: 10),
                  _buildInput(controller: _codeCtrl, hint: 'Código da Instituição',
                      icon: Icons.school_outlined),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _register,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                        elevation: 4,
                      ),
                      child: const Text('CADASTRAR',
                          style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                              letterSpacing: 1)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => context.pop(),
                    child: const Text('Já tem uma conta? Entrar',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14)),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    Widget? suffixIcon,
    TextInputType? keyboard,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.20),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboard,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white60),
          prefixIcon: Icon(icon, color: Colors.white70),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          filled: false,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    _codeCtrl.dispose();
    super.dispose();
  }
}
