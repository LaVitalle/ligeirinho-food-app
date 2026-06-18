import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'auth_provider.dart';
import '../../data/models/user_model.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  /// Verifica se há sessão salva e decide para onde navegar.
  Future<void> _initializeApp() async {
    // Aguarda um mínimo de 1.5s para exibir a splash (branding)
    final minDelay = Future.delayed(const Duration(milliseconds: 1500));

    // Tenta restaurar a sessão em paralelo
    final restored =
        await ref.read(authProvider.notifier).tryRestoreSession();

    // Garante que a splash fique visível por tempo mínimo
    await minDelay;

    if (!mounted) return;

    if (restored) {
      final user = ref.read(authProvider);
      if (user != null && user.role == UserRole.client) {
        context.go('/home');
      } else {
        // Sessão de vendedor no mobile — redireciona para login
        context.go('/onboarding');
      }
    } else {
      context.go('/onboarding');
    }
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
                  radius: 1.2,
                  colors: [Color(0xFFFF6B00), Color(0xFFCC4400)],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/images/mascote.png',
                      width: 220,
                      height: 220,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.fastfood,
                        size: 100,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'LIGEIRINHO',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 3,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 4,
                      ),
                      height: 2,
                      color: Colors.white54,
                    ),
                    const Text(
                      '— FOOD —',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white70,
                        letterSpacing: 6,
                      ),
                    ),
                    const SizedBox(height: 40),
                    const CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

