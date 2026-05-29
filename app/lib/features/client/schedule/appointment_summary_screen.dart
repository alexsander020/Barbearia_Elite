import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../src/theme/app_colors.dart';
import '../../../src/core/app_constants.dart';
import '../../../src/routing/app_routes.dart';
import '../../../src/core/auth/auth_service.dart';
import '../../../src/core/database/firestore_service.dart';
import '../../../src/core/models/appointment_model.dart';
import 'booking_state.dart';

class AppointmentSummaryScreen extends ConsumerStatefulWidget {
  const AppointmentSummaryScreen({super.key});

  @override
  ConsumerState<AppointmentSummaryScreen> createState() => _AppointmentSummaryScreenState();
}

class _AppointmentSummaryScreenState extends ConsumerState<AppointmentSummaryScreen> {
  bool _isLoading = false;

  Future<void> _confirmBooking() async {
    final booking = ref.read(bookingStateProvider);
    final authUser = ref.read(authServiceProvider).currentUser;

    if (booking.combinedDateTime == null || authUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dados de agendamento incompletos. Tente novamente.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Buscar nome do cliente no Firestore
      final userModel = await ref.read(firestoreServiceProvider).getUser(authUser.uid);

      final appointment = AppointmentModel(
        id: '', // Será gerado automaticamente pelo Firestore
        clientId: authUser.uid,
        clientName: userModel?.name ?? authUser.email ?? 'Cliente',
        professionalId: booking.professionalId,
        professionalName: booking.professionalName,
        serviceName: booking.serviceName,
        price: booking.price,
        dateTime: booking.combinedDateTime!,
        status: 'pending',
        createdAt: DateTime.now(),
      );

      await ref.read(firestoreServiceProvider).createAppointment(appointment);

      // Limpar o estado de agendamento após salvar
      ref.read(bookingStateProvider.notifier).clear();

      if (!mounted) return;
      _showSuccessDialog();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao confirmar: ${e.toString()}'), backgroundColor: AppColors.error),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceContainer,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_outline_rounded, color: Colors.green, size: 56),
            ),
            const SizedBox(height: 24),
            const Text(
              'Agendamento Confirmado!',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.onSurface, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Seu horário está reservado. Você pode acompanhar na aba Agendamentos.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  context.pop(); // Fecha dialog
                  context.go(AppRoutes.myAppointments); // Vai direto pra lista de agendamentos
                },
                child: const Text('Ver Meus Agendamentos'),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () {
                  context.pop();
                  context.go(AppRoutes.home);
                },
                child: const Text('Voltar ao Início', style: TextStyle(color: AppColors.onSurfaceVariant)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final booking = ref.watch(bookingStateProvider);
    final dateFormatter = DateFormat("d 'de' MMMM", 'pt_BR');
    final weekDayFormatter = DateFormat("EEEE", 'pt_BR');

    final dateDisplay = booking.date != null
        ? dateFormatter.format(booking.date!)
        : '--';
    final weekDayDisplay = booking.date != null
        ? weekDayFormatter.format(booking.date!).capitalize()
        : '--';
    final timeDisplay = booking.time ?? '--';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.onSurfaceVariant),
          onPressed: () => context.pop(),
        ),
        title: const Text('Resumo do Agendamento'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.marginMobile),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Confirme seus dados',
                      style: TextStyle(color: AppColors.onSurface, fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Revise as informações antes de confirmar.',
                      style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 14),
                    ),
                    const SizedBox(height: 32),

                    // ── Professional ──
                    _buildSectionHeader('Profissional'),
                    _buildCard(
                      child: Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerHigh,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.person, color: AppColors.outline, size: 28),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(booking.professionalName,
                                style: const TextStyle(color: AppColors.onSurface, fontSize: 16, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 2),
                              const Text('Barbearia Elite', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12)),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── Data e Hora ──
                    _buildSectionHeader('Data e Hora'),
                    _buildCard(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              const Icon(Icons.calendar_month_outlined, color: AppColors.primary),
                              const SizedBox(height: 8),
                              Text(dateDisplay, style: const TextStyle(color: AppColors.onSurface, fontWeight: FontWeight.bold)),
                              Text(weekDayDisplay, style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12)),
                            ],
                          ),
                          Container(height: 40, width: 1, color: AppColors.outlineVariant),
                          Column(
                            children: [
                              const Icon(Icons.schedule, color: AppColors.primary),
                              const SizedBox(height: 8),
                              Text(timeDisplay, style: const TextStyle(color: AppColors.onSurface, fontWeight: FontWeight.bold)),
                              const Text('Duração: 60 min', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12)),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── Serviço ──
                    _buildSectionHeader('Serviço Selecionado'),
                    _buildCard(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(booking.serviceName,
                            style: const TextStyle(color: AppColors.onSurface, fontSize: 16)),
                          Text(
                            'R\$ ${booking.price.toStringAsFixed(2).replaceAll('.', ',')}',
                            style: const TextStyle(color: AppColors.onSurface, fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── Total ──
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Valor Total',
                            style: TextStyle(color: AppColors.primary, fontSize: 16, fontWeight: FontWeight.bold)),
                          Text(
                            'R\$ ${booking.price.toStringAsFixed(2).replaceAll('.', ',')}',
                            style: const TextStyle(color: AppColors.primary, fontSize: 26, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),

            // ── CTA ──
            Container(
              padding: const EdgeInsets.all(AppSpacing.marginMobile),
              decoration: const BoxDecoration(
                color: AppColors.surfaceContainer,
                border: Border(top: BorderSide(color: AppColors.outlineVariant)),
              ),
              child: SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _confirmBooking,
                  child: _isLoading
                      ? const SizedBox(width: 24, height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.onPrimary))
                      : const Text('Confirmar Agendamento',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12,
          fontWeight: FontWeight.bold, letterSpacing: 1.2),
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: child,
    );
  }
}

extension StringExt on String {
  String capitalize() => isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
}
