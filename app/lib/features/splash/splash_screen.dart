import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../src/theme/app_colors.dart';
import '../../src/core/app_constants.dart';
import '../../src/routing/app_routes.dart';
import '../../src/core/auth/auth_service.dart';
import '../../src/core/database/firestore_service.dart';

// ══════════════════════════════════════════════════════════
//  SPLASH SCREEN
//  Exibe logo + animação enquanto valida o estado de auth
// ══════════════════════════════════════════════════════════

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnim  = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _scaleAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _controller.forward();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await _checkAuthAndRole();
  }

  Future<void> _checkAuthAndRole() async {
    // Pequeno delay para a animação da splash screen ser vista
    await Future.delayed(const Duration(seconds: 2));
    
    if (!mounted) return;

    final authUser = ref.read(authServiceProvider).currentUser;
    
    if (authUser == null) {
      // Não tem usuário -> Vai pro Login
      context.go(AppRoutes.login);
    } else {
      // Tem usuário -> Busca a Role no Firestore
      final userModel = await ref.read(firestoreServiceProvider).getUser(authUser.uid);
      
      if (!mounted) return;

      if (userModel != null && userModel.role == 'professional') {
        context.go(AppRoutes.professionalDashboard);
      } else {
        context.go(AppRoutes.home);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: ScaleTransition(
            scale: _scaleAnim,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ── Logo ──
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainer,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: AppColors.primaryContainer,
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.2),
                        blurRadius: 40,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.content_cut_rounded,
                    color: AppColors.primary,
                    size: 48,
                  ),
                ),

                const SizedBox(height: 28),

                // ── Brand Name ──
                Text(
                  'BarberFlow',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    color: AppColors.primary,
                    fontSize: 36,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  'ELITE',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppColors.onSurfaceVariant,
                    letterSpacing: 8,
                    fontSize: 13,
                  ),
                ),

                const SizedBox(height: 60),

                // ── Loading indicator ──
                SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: AppColors.primary.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
