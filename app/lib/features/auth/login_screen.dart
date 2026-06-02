import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../src/theme/app_colors.dart';
import '../../src/core/app_constants.dart';
import '../../src/routing/app_routes.dart';
import '../../src/core/auth/auth_service.dart';

// ══════════════════════════════════════════════════════════
//  LOGIN SCREEN
// ══════════════════════════════════════════════════════════

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey        = GlobalKey<FormState>();
  final _emailCtrl      = TextEditingController();
  final _passwordCtrl   = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading       = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  // ── Validation ──
  String? _validateEmail(String? v) {
    if (v == null || v.isEmpty) return AppStrings.fieldRequired;
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!emailRegex.hasMatch(v)) return AppStrings.invalidEmail;
    return null;
  }

  String? _validatePassword(String? v) {
    if (v == null || v.isEmpty) return AppStrings.fieldRequired;
    if (v.length < 6) return AppStrings.passwordTooShort;
    return null;
  }

  // ── Submit ──
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      await ref.read(authServiceProvider).signInWithEmailAndPassword(
        _emailCtrl.text.trim(),
        _passwordCtrl.text.trim(),
      );
      // Sucesso: O AuthService notificará o authStateChangesProvider
      // e o GoRouter (quando configurado) redirecionará automaticamente.
      // Por enquanto, não chamamos context.go() manualmente caso queiramos
      // que o Router cuide do redirecionamento reativo. Mas se não estiver
      // configurado ainda, mantemos:
      if (mounted) {
        context.go(AppRoutes.splash);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.marginMobile),
          child: Column(
            children: [
              const SizedBox(height: 60),

              // ── Header ──
              Column(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainer,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.primaryContainer, width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          blurRadius: 30,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.content_cut_rounded, color: AppColors.primary, size: 36),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    AppStrings.appName,
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      color: AppColors.primary,
                      fontSize: 28,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Bem-vindo de volta',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 48),

              // ── Form ──
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [

                    // Email
                    TextFormField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      validator: _validateEmail,
                      style: const TextStyle(color: AppColors.onSurface),
                      decoration: InputDecoration(
                        labelText: 'E-mail',
                        hintText: AppStrings.emailHint,
                        prefixIcon: const Icon(Icons.mail_outline, color: AppColors.outline),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Senha
                    TextFormField(
                      controller: _passwordCtrl,
                      obscureText: _obscurePassword,
                      validator: _validatePassword,
                      style: const TextStyle(color: AppColors.onSurface),
                      decoration: InputDecoration(
                        labelText: 'Senha',
                        hintText: AppStrings.passwordHint,
                        prefixIcon: const Icon(Icons.lock_outline, color: AppColors.outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                            color: AppColors.outline,
                          ),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Forgot password
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {/* TODO */},
                        child: Text(
                          AppStrings.forgotPassword,
                          style: const TextStyle(color: AppColors.primary, fontSize: 13),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── CTA: Entrar ──
                    SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submit,
                        child: _isLoading
                            ? const SizedBox(
                                width: 22, height: 22,
                                child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.onPrimary),
                              )
                            : Text(AppStrings.login, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── Divisor ──
                    Row(
                      children: [
                        const Expanded(child: Divider(color: AppColors.outlineVariant)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text('ou', style: TextStyle(color: AppColors.outline, fontSize: 12)),
                        ),
                        const Expanded(child: Divider(color: AppColors.outlineVariant)),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // ── Google Login ──
                    SizedBox(
                      height: 52,
                      child: OutlinedButton.icon(
                        onPressed: () {/* TODO: Google Sign-In */},
                        icon: const Icon(Icons.g_mobiledata_rounded, size: 26),
                        label: const Text(AppStrings.loginWithGoogle),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── Trocar de Tela ──
                    OutlinedButton.icon(
                      onPressed: () => context.go(AppRoutes.proLogin),
                      icon: const Icon(Icons.content_cut_rounded),
                      label: const Text('Sou Profissional'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── Criar conta ──
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Não tem uma conta? ', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 14)),
                        GestureDetector(
                          onTap: () => context.push(AppRoutes.register),
                          child: const Text(
                            'Criar agora',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
