import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../src/theme/app_colors.dart';
import '../../src/core/app_constants.dart';
import '../../src/routing/app_routes.dart';
import '../../src/core/auth/auth_service.dart';
import '../../src/core/database/firestore_service.dart';
import '../../src/core/models/user_model.dart';

// ══════════════════════════════════════════════════════════
//  REGISTER SCREEN
// ══════════════════════════════════════════════════════════

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey          = GlobalKey<FormState>();
  final _nameCtrl         = TextEditingController();
  final _phoneCtrl        = TextEditingController();
  final _emailCtrl        = TextEditingController();
  final _passwordCtrl     = TextEditingController();
  final _confirmPassCtrl  = TextEditingController();
  bool _obscurePass       = true;
  bool _obscureConfirm    = true;
  bool _isLoading         = false;
  int _currentStep        = 0; // Passo do formulário em 2 etapas
  String _selectedRole    = 'client'; // client ou professional

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  // ── Validations ──
  String? _validateName(String? v) {
    if (v == null || v.trim().isEmpty) return AppStrings.fieldRequired;
    if (v.trim().split(' ').length < 2) return 'Informe nome e sobrenome';
    return null;
  }

  String? _validatePhone(String? v) {
    if (v == null || v.isEmpty) return AppStrings.fieldRequired;
    final cleaned = v.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleaned.length < 10) return AppStrings.invalidPhone;
    return null;
  }

  String? _validateEmail(String? v) {
    if (v == null || v.isEmpty) return AppStrings.fieldRequired;
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(v)) return AppStrings.invalidEmail;
    return null;
  }

  String? _validatePassword(String? v) {
    if (v == null || v.isEmpty) return AppStrings.fieldRequired;
    if (v.length < 6) return AppStrings.passwordTooShort;
    return null;
  }

  String? _validateConfirmPassword(String? v) {
    if (v == null || v.isEmpty) return AppStrings.fieldRequired;
    if (v != _passwordCtrl.text) return AppStrings.passwordsDoNotMatch;
    return null;
  }

  // ── Submit ──
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      // 1. Criar Auth User no Firebase
      final cred = await ref.read(authServiceProvider).registerWithEmailAndPassword(
        _emailCtrl.text.trim(),
        _passwordCtrl.text.trim(),
      );

      if (cred.user != null) {
        // 2. Criar Perfil no Firestore
        final newUser = UserModel(
          id: cred.user!.uid,
          name: _nameCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
          role: _selectedRole,
          createdAt: DateTime.now(),
        );

        await ref.read(firestoreServiceProvider).createUserProfile(newUser);
        
        if (mounted) {
          context.go(AppRoutes.splash);
        }
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
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.onSurfaceVariant),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Criar Conta',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.marginMobile),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Progress Indicator ──
              Row(
                children: List.generate(2, (i) {
                  final isActive = i <= _currentStep;
                  return Expanded(
                    child: Container(
                      height: 3,
                      margin: EdgeInsets.only(right: i == 0 ? 8 : 0),
                      decoration: BoxDecoration(
                        color: isActive ? AppColors.primary : AppColors.outlineVariant,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),

              const SizedBox(height: 8),
              Text(
                'Etapa ${_currentStep + 1} de 2 — ${_currentStep == 0 ? "Dados pessoais" : "Segurança"}',
                style: const TextStyle(color: AppColors.outline, fontSize: 12),
              ),

              const SizedBox(height: 32),

              Form(
                key: _formKey,
                child: _currentStep == 0 ? _buildStep1() : _buildStep2(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Step 1: Dados pessoais ──
  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Seletor de Perfil (Segmented Control Premium)
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.outlineVariant),
          ),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedRole = 'client'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: _selectedRole == 'client'
                          ? AppColors.primary
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.person,
                          size: 18,
                          color: _selectedRole == 'client'
                              ? AppColors.onPrimary
                              : AppColors.onSurfaceVariant,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Sou Cliente',
                          style: TextStyle(
                            color: _selectedRole == 'client'
                                ? AppColors.onPrimary
                                : AppColors.onSurfaceVariant,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedRole = 'professional'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: _selectedRole == 'professional'
                          ? AppColors.primary
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.content_cut_rounded,
                          size: 18,
                          color: _selectedRole == 'professional'
                              ? AppColors.onPrimary
                              : AppColors.onSurfaceVariant,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Sou Cabeleireiro',
                          style: TextStyle(
                            color: _selectedRole == 'professional'
                                ? AppColors.onPrimary
                                : AppColors.onSurfaceVariant,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        Text('Sobre você', style: Theme.of(context).textTheme.displayMedium?.copyWith(fontSize: 26)),
        const SizedBox(height: 4),
        Text('Preencha seus dados pessoais', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 14)),

        const SizedBox(height: 32),

        // Nome completo
        TextFormField(
          controller: _nameCtrl,
          textCapitalization: TextCapitalization.words,
          validator: _validateName,
          style: const TextStyle(color: AppColors.onSurface),
          decoration: const InputDecoration(
            labelText: 'Nome completo',
            hintText: 'Ex: João Silva',
            prefixIcon: Icon(Icons.person_outline, color: AppColors.outline),
          ),
        ),

        const SizedBox(height: 16),

        // Telefone
        TextFormField(
          controller: _phoneCtrl,
          keyboardType: TextInputType.phone,
          validator: _validatePhone,
          style: const TextStyle(color: AppColors.onSurface),
          decoration: const InputDecoration(
            labelText: 'Telefone (WhatsApp)',
            hintText: '(11) 99999-9999',
            prefixIcon: Icon(Icons.phone_outlined, color: AppColors.outline),
          ),
        ),

        const SizedBox(height: 16),

        // Email
        TextFormField(
          controller: _emailCtrl,
          keyboardType: TextInputType.emailAddress,
          validator: _validateEmail,
          style: const TextStyle(color: AppColors.onSurface),
          decoration: const InputDecoration(
            labelText: 'E-mail',
            hintText: 'seu@email.com',
            prefixIcon: Icon(Icons.mail_outline, color: AppColors.outline),
          ),
        ),

        const SizedBox(height: 32),

        SizedBox(
          height: 52,
          child: ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                setState(() => _currentStep = 1);
              }
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text('Próximo', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward_rounded),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Já tem conta? ', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 14)),
            GestureDetector(
              onTap: () => context.pop(),
              child: const Text('Entrar', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 14)),
            ),
          ],
        ),
      ],
    );
  }

  // ── Step 2: Senha ──
  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Crie sua senha', style: Theme.of(context).textTheme.displayMedium?.copyWith(fontSize: 26)),
        const SizedBox(height: 4),
        Text('Mínimo de 6 caracteres', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 14)),

        const SizedBox(height: 32),

        // Senha
        TextFormField(
          controller: _passwordCtrl,
          obscureText: _obscurePass,
          validator: _validatePassword,
          style: const TextStyle(color: AppColors.onSurface),
          decoration: InputDecoration(
            labelText: 'Senha',
            prefixIcon: const Icon(Icons.lock_outline, color: AppColors.outline),
            suffixIcon: IconButton(
              icon: Icon(_obscurePass ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: AppColors.outline),
              onPressed: () => setState(() => _obscurePass = !_obscurePass),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Confirmar senha
        TextFormField(
          controller: _confirmPassCtrl,
          obscureText: _obscureConfirm,
          validator: _validateConfirmPassword,
          style: const TextStyle(color: AppColors.onSurface),
          decoration: InputDecoration(
            labelText: 'Confirmar senha',
            prefixIcon: const Icon(Icons.lock_outline, color: AppColors.outline),
            suffixIcon: IconButton(
              icon: Icon(_obscureConfirm ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: AppColors.outline),
              onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
            ),
          ),
        ),

        const SizedBox(height: 32),

        SizedBox(
          height: 52,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _submit,
            child: _isLoading
                ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.onPrimary))
                : const Text('Criar Conta', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          ),
        ),

        const SizedBox(height: 16),

        TextButton.icon(
          onPressed: () => setState(() => _currentStep = 0),
          icon: const Icon(Icons.arrow_back_rounded, size: 18),
          label: const Text('Voltar'),
          style: TextButton.styleFrom(foregroundColor: AppColors.onSurfaceVariant),
        ),
      ],
    );
  }
}
