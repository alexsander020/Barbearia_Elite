import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../src/theme/app_colors.dart';
import '../../../src/core/app_constants.dart';
import '../../../src/routing/app_routes.dart';
import '../../../src/core/database/firestore_service.dart';
import '../../../src/core/models/appointment_model.dart';
import '../../../src/core/auth/auth_service.dart';

const _mockProfessionalId = 'prof_001_mock';

// Provider: todos os agendamentos de HOJE do profissional
final todayAppointmentsProvider = StreamProvider<List<AppointmentModel>>((ref) {
  final now = DateTime.now();
  final startOfDay = DateTime(now.year, now.month, now.day);
  return ref
      .watch(firestoreServiceProvider)
      .getProfessionalAppointments(_mockProfessionalId, startOfDay)
      .map((list) => list
          .where((a) => a.dateTime.isBefore(DateTime(now.year, now.month, now.day + 1)))
          .toList());
});

// ══════════════════════════════════════════════════════════
//  PROFESSIONAL DASHBOARD SCREEN — Real Data
// ══════════════════════════════════════════════════════════

class ProfessionalDashboardScreen extends ConsumerWidget {
  const ProfessionalDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayAsync = ref.watch(todayAppointmentsProvider);
    final currentUserAsync = ref.watch(currentUserProvider);
    final professionalName = currentUserAsync.value?.name ?? 'Profissional';
    final firstName = professionalName.split(' ').first;
    final now = DateTime.now();
    final dateStr = DateFormat("EEEE, d MMM", 'pt_BR').format(now);
    final currency = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Dashboard'),
        actions: [
          IconButton(icon: const Icon(Icons.notifications_outlined), onPressed: () {}),
          IconButton(icon: const Icon(Icons.settings_outlined), onPressed: () {}),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async => ref.invalidate(todayAppointmentsProvider),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AppSpacing.marginMobile),
            child: todayAsync.when(
              loading: () => _buildBody(
                context: context,
                dateStr: dateStr,
                currency: currency,
                appointments: null,
                isLoading: true,
                firstName: firstName,
              ),
              error: (e, _) => _buildBody(
                context: context,
                dateStr: dateStr,
                currency: currency,
                appointments: [],
                isLoading: false,
                firstName: firstName,
              ),
              data: (appointments) => _buildBody(
                context: context,
                dateStr: dateStr,
                currency: currency,
                appointments: appointments,
                isLoading: false,
                firstName: firstName,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody({
    required BuildContext context,
    required String dateStr,
    required NumberFormat currency,
    required List<AppointmentModel>? appointments,
    required bool isLoading,
    required String firstName,
  }) {
    final now = DateTime.now();

    // Calcular métricas
    final totalHoje = appointments?.fold(0.0, (s, a) => s + a.price) ?? 0.0;
    final countHoje = appointments?.length ?? 0;

    // Próximo agendamento = primeiro no futuro com status != canceled
    final upcoming = appointments
        ?.where((a) => a.dateTime.isAfter(now) && a.status != 'canceled')
        .toList();
    final nextAppt = (upcoming != null && upcoming.isNotEmpty) ? upcoming.first : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        // ── Greeting ──
        Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHigh,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primaryContainer),
              ),
              child: const Icon(Icons.person, color: AppColors.primary, size: 28),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Olá, $firstName!',
                  style: const TextStyle(color: AppColors.onSurface, fontSize: 22, fontWeight: FontWeight.bold)),
                Text(
                  dateStr[0].toUpperCase() + dateStr.substring(1),
                  style: TextStyle(color: AppColors.primary.withValues(alpha: 0.8), fontSize: 14),
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 28),

        // ── Métricas do Dia ──
        Row(
          children: [
            _StatCard(
              title: 'Faturamento Hoje',
              value: isLoading ? '...' : currency.format(totalHoje),
              icon: Icons.attach_money_rounded,
              color: Colors.green,
            ),
            const SizedBox(width: 14),
            _StatCard(
              title: 'Agendamentos',
              value: isLoading ? '...' : '$countHoje hoje',
              icon: Icons.people_outline_rounded,
              color: AppColors.primary,
            ),
          ],
        ),

        const SizedBox(height: 28),

        // ── Próximo Atendimento ──
        const Text('Próximo Atendimento',
          style: TextStyle(color: AppColors.onSurface, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),

        if (isLoading)
          _buildNextApptSkeleton()
        else if (nextAppt == null)
          _buildNoNextAppt()
        else
          _buildNextApptCard(nextAppt, now),

        const SizedBox(height: 28),

        // ── Agenda de Hoje ──
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Agenda de Hoje',
              style: TextStyle(color: AppColors.onSurface, fontSize: 18, fontWeight: FontWeight.bold)),
            TextButton(
              onPressed: () => context.go(AppRoutes.dailyAgenda),
              child: const Text('Ver tudo', style: TextStyle(color: AppColors.primary)),
            ),
          ],
        ),
        const SizedBox(height: 12),

        if (isLoading)
          const Center(child: CircularProgressIndicator(color: AppColors.primary))
        else if (appointments == null || appointments.isEmpty)
          _buildEmptyAgenda()
        else
          ...appointments.take(4).map((a) => _AgendaRow(appointment: a)),

        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildNextApptCard(AppointmentModel appt, DateTime now) {
    final diff = appt.dateTime.difference(now);
    final timeStr = DateFormat('HH:mm').format(appt.dateTime);
    final String diffStr;
    if (diff.inMinutes < 60) {
      diffStr = 'Daqui ${diff.inMinutes}min';
    } else {
      diffStr = 'Daqui ${diff.inHours}h';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.surfaceContainerHigh, AppColors.surfaceContainerLow],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.35)),
        boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.08), blurRadius: 16, offset: const Offset(0, 6))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
            ),
            child: Column(
              children: [
                Text(timeStr, style: const TextStyle(color: AppColors.primary, fontSize: 20, fontWeight: FontWeight.bold)),
                Text(diffStr, style: const TextStyle(color: AppColors.primary, fontSize: 10)),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(appt.clientName,
                  style: const TextStyle(color: AppColors.onSurface, fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(appt.serviceName,
                  style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13)),
                const SizedBox(height: 4),
                Text(
                  'R\$ ${appt.price.toStringAsFixed(2).replaceAll('.', ',')}',
                  style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoNextAppt() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: const Row(
        children: [
          Icon(Icons.check_circle_outline_rounded, color: Colors.green, size: 28),
          SizedBox(width: 14),
          Text('Sem próximos agendamentos hoje', style: TextStyle(color: AppColors.onSurfaceVariant)),
        ],
      ),
    );
  }

  Widget _buildNextApptSkeleton() {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: const Center(child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2.5)),
    );
  }

  Widget _buildEmptyAgenda() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: const Center(
        child: Text('Nenhum agendamento hoje', style: TextStyle(color: AppColors.onSurfaceVariant)),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.title, required this.value, required this.icon, required this.color});
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainer,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 18),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(title, style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 11),
                    overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(value, style: const TextStyle(color: AppColors.onSurface, fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class _AgendaRow extends StatelessWidget {
  const _AgendaRow({required this.appointment});
  final AppointmentModel appointment;

  @override
  Widget build(BuildContext context) {
    final timeStr = DateFormat('HH:mm').format(appointment.dateTime);
    Color statusColor;
    switch (appointment.status) {
      case 'confirmed': statusColor = Colors.green; break;
      case 'completed': statusColor = AppColors.outline; break;
      case 'canceled':  statusColor = AppColors.error;  break;
      default:          statusColor = AppColors.primary;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Row(
        children: [
          Text(timeStr,
            style: const TextStyle(color: AppColors.onSurface, fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(width: 14),
          Container(width: 2, height: 28, color: AppColors.outlineVariant),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(appointment.clientName,
                  style: const TextStyle(color: AppColors.onSurface, fontWeight: FontWeight.bold)),
                Text(appointment.serviceName,
                  style: const TextStyle(color: AppColors.outline, fontSize: 12)),
              ],
            ),
          ),
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
          ),
        ],
      ),
    );
  }
}
