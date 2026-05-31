import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../src/theme/app_colors.dart';
import '../../src/core/auth/auth_service.dart';
import '../../src/core/database/firestore_service.dart';
import '../../src/core/models/user_model.dart';
import '../../src/routing/app_routes.dart';

// ══════════════════════════════════════════════════════════
//  SETTINGS SCREEN — Cliente & Profissional
// ══════════════════════════════════════════════════════════

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  bool _isLoading = false;
  bool _isEditing = false;
  UserModel? _user;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final authUser = ref.read(authServiceProvider).currentUser;
    if (authUser == null) return;
    final user = await ref.read(firestoreServiceProvider).getUser(authUser.uid);
    if (mounted && user != null) {
      setState(() {
        _user = user;
        _nameCtrl.text = user.name;
        _phoneCtrl.text = user.phone;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final updatedUser = _user!.copyWith(
        name: _nameCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
      );
      await ref.read(firestoreServiceProvider).updateUserProfile(updatedUser);
      setState(() {
        _user = updatedUser;
        _isEditing = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.green,
            content: Text('Perfil atualizado com sucesso!',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.error,
            content: Text('Erro ao atualizar perfil: $e',
                style: const TextStyle(color: Colors.white)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceContainer,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Sair da Conta',
            style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.onSurface)),
        content: const Text(
          'Tem certeza que deseja sair da sua conta?',
          style: TextStyle(color: AppColors.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: AppColors.outline)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error, foregroundColor: AppColors.onError),
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(authServiceProvider).signOut();
              if (mounted) context.go(AppRoutes.login);
            },
            child: const Text('Sair', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isProfessional = _user?.role == 'professional';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Configurações'),
        centerTitle: true,
        actions: [
          if (_isEditing)
            TextButton(
              onPressed: () {
                setState(() {
                  _isEditing = false;
                  _nameCtrl.text = _user?.name ?? '';
                  _phoneCtrl.text = _user?.phone ?? '';
                });
              },
              child: const Text('Cancelar', style: TextStyle(color: AppColors.outline)),
            ),
        ],
      ),
      body: _user == null
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── Avatar + Nome + Tipo ──
                    Center(
                      child: Column(
                        children: [
                          Container(
                            width: 88,
                            height: 88,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerHigh,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.primary.withValues(alpha: 0.4),
                                width: 2,
                              ),
                            ),
                            child: Icon(
                              isProfessional
                                  ? Icons.content_cut_rounded
                                  : Icons.person_rounded,
                              color: AppColors.primary,
                              size: 40,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            _user!.name,
                            style: const TextStyle(
                              color: AppColors.onSurface,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              isProfessional ? 'Cabeleireiro' : 'Cliente',
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // ── Seção: Meu Perfil ──
                    _SectionHeader(
                      icon: Icons.person_outline_rounded,
                      title: 'Meu Perfil',
                      trailing: !_isEditing
                          ? GestureDetector(
                              onTap: () => setState(() => _isEditing = true),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.edit_outlined, color: AppColors.primary, size: 16),
                                  SizedBox(width: 4),
                                  Text('Editar',
                                      style: TextStyle(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13)),
                                ],
                              ),
                            )
                          : null,
                    ),

                    const SizedBox(height: 12),

                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.outlineVariant),
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            // Nome
                            _isEditing
                                ? TextFormField(
                                    controller: _nameCtrl,
                                    style: const TextStyle(color: AppColors.onSurface),
                                    textCapitalization: TextCapitalization.words,
                                    decoration: const InputDecoration(
                                      labelText: 'Nome completo',
                                      prefixIcon: Icon(Icons.person_outline, color: AppColors.outline),
                                    ),
                                    validator: (v) {
                                      if (v == null || v.trim().isEmpty) return 'Informe seu nome';
                                      return null;
                                    },
                                  )
                                : _InfoRow(
                                    icon: Icons.person_outline,
                                    label: 'Nome',
                                    value: _user!.name,
                                  ),

                            const SizedBox(height: 12),

                            // Email (somente leitura)
                            _InfoRow(
                              icon: Icons.mail_outline,
                              label: 'E-mail',
                              value: _user!.email,
                              readOnly: true,
                            ),

                            const SizedBox(height: 12),

                            // Telefone
                            _isEditing
                                ? TextFormField(
                                    controller: _phoneCtrl,
                                    style: const TextStyle(color: AppColors.onSurface),
                                    keyboardType: TextInputType.phone,
                                    decoration: const InputDecoration(
                                      labelText: 'Telefone (WhatsApp)',
                                      prefixIcon: Icon(Icons.phone_outlined, color: AppColors.outline),
                                      hintText: '(11) 99999-9999',
                                    ),
                                  )
                                : _InfoRow(
                                    icon: Icons.phone_outlined,
                                    label: 'Telefone',
                                    value: _user!.phone.isEmpty ? 'Não informado' : _user!.phone,
                                  ),
                          ],
                        ),
                      ),
                    ),

                    if (_isEditing) ...[
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _saveProfile,
                          child: _isLoading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2.5, color: AppColors.onPrimary),
                                )
                              : const Text('Salvar Alterações',
                                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],

                    const SizedBox(height: 28),

                    // ── Seção: Atalhos ──
                    _SectionHeader(
                      icon: Icons.grid_view_rounded,
                      title: isProfessional ? 'Ferramentas' : 'Acesso Rápido',
                    ),
                    const SizedBox(height: 12),

                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.outlineVariant),
                      ),
                      child: Column(
                        children: isProfessional
                            ? [
                                _SettingsTile(
                                  icon: Icons.content_cut,
                                  label: 'Catálogo de Serviços',
                                  onTap: () => context.go(AppRoutes.manageServices),
                                ),
                                const Divider(height: 1, color: AppColors.outlineVariant, indent: 56),
                                _SettingsTile(
                                  icon: Icons.attach_money,
                                  label: 'Dashboard Financeiro',
                                  onTap: () => context.go(AppRoutes.financialDashboard),
                                ),
                                const Divider(height: 1, color: AppColors.outlineVariant, indent: 56),
                                _SettingsTile(
                                  icon: Icons.calendar_month_outlined,
                                  label: 'Agenda do Dia',
                                  onTap: () => context.go(AppRoutes.dailyAgenda),
                                ),
                              ]
                            : [
                                _SettingsTile(
                                  icon: Icons.calendar_today_outlined,
                                  label: 'Meus Agendamentos',
                                  onTap: () => context.go(AppRoutes.myAppointments),
                                ),
                                const Divider(height: 1, color: AppColors.outlineVariant, indent: 56),
                                _SettingsTile(
                                  icon: Icons.event_available_outlined,
                                  label: 'Agendar Horário',
                                  onTap: () => context.go(AppRoutes.schedule),
                                ),
                              ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    // ── Seção: Conta ──
                    _SectionHeader(icon: Icons.manage_accounts_outlined, title: 'Conta'),
                    const SizedBox(height: 12),

                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.outlineVariant),
                      ),
                      child: _SettingsTile(
                        icon: Icons.logout_rounded,
                        label: 'Sair da Conta',
                        isDestructive: true,
                        onTap: _confirmLogout,
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }
}

// ── Widgets Auxiliares ──

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.icon, required this.title, this.trailing});
  final IconData icon;
  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 18),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: AppColors.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        const Spacer(),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.readOnly = false,
  });
  final IconData icon;
  final String label;
  final String value;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: readOnly ? AppColors.outlineVariant : AppColors.outline, size: 20),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: TextStyle(
                    color: readOnly ? AppColors.outlineVariant : AppColors.onSurfaceVariant,
                    fontSize: 11)),
            Text(
              value,
              style: TextStyle(
                color: readOnly ? AppColors.outlineVariant : AppColors.onSurface,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? AppColors.error : AppColors.onSurface;
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDestructive
              ? AppColors.error.withValues(alpha: 0.1)
              : AppColors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: isDestructive ? AppColors.error : AppColors.primary, size: 20),
      ),
      title: Text(label,
          style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 14)),
      trailing: isDestructive
          ? null
          : const Icon(Icons.chevron_right_rounded, color: AppColors.outline, size: 20),
      onTap: onTap,
    );
  }
}
