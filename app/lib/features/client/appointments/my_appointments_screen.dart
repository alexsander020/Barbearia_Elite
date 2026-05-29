import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../src/theme/app_colors.dart';
import '../../../src/core/auth/auth_service.dart';
import '../../../src/core/database/firestore_service.dart';
import '../../../src/core/models/appointment_model.dart';

// Provider da stream de agendamentos do cliente logado
final clientAppointmentsProvider = StreamProvider<List<AppointmentModel>>((ref) {
  final authUser = ref.watch(authStateChangesProvider).value;
  if (authUser == null) return const Stream.empty();
  return ref.watch(firestoreServiceProvider).getClientAppointments(authUser.uid);
});

class MyAppointmentsScreen extends ConsumerWidget {
  const MyAppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appointmentsAsync = ref.watch(clientAppointmentsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Meus Agendamentos'),
        centerTitle: true,
      ),
      body: appointmentsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.wifi_off_rounded, color: AppColors.outline, size: 48),
              const SizedBox(height: 16),
              Text('Erro ao carregar: ${e.toString()}',
                style: const TextStyle(color: AppColors.onSurfaceVariant),
                textAlign: TextAlign.center),
            ],
          ),
        ),
        data: (appointments) {
          if (appointments.isEmpty) {
            return _buildEmptyState();
          }

          // Separar em próximos e histórico
          final now = DateTime.now();
          final upcoming = appointments
              .where((a) => a.dateTime.isAfter(now) && a.status != 'canceled')
              .toList();
          final past = appointments
              .where((a) => a.dateTime.isBefore(now) || a.status == 'canceled')
              .toList()
              ..sort((a, b) => b.dateTime.compareTo(a.dateTime));

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (upcoming.isNotEmpty) ...[
                _sectionTitle('Próximos Agendamentos'),
                const SizedBox(height: 12),
                ...upcoming.map((a) => _AppointmentCard(appointment: a, isUpcoming: true)),
                const SizedBox(height: 24),
              ],
              if (past.isNotEmpty) ...[
                _sectionTitle('Histórico'),
                const SizedBox(height: 12),
                ...past.map((a) => _AppointmentCard(appointment: a, isUpcoming: false)),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.calendar_today_outlined, color: AppColors.outline, size: 48),
          ),
          const SizedBox(height: 20),
          const Text(
            'Nenhum agendamento ainda',
            style: TextStyle(color: AppColors.onSurface, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Seus agendamentos aparecerão aqui.',
            style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
        color: AppColors.onSurfaceVariant,
        fontSize: 11,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.4,
      ),
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  const _AppointmentCard({required this.appointment, required this.isUpcoming});
  final AppointmentModel appointment;
  final bool isUpcoming;

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat("d 'de' MMM · HH:mm", 'pt_BR').format(appointment.dateTime);
    final isCanceled = appointment.status == 'canceled';

    Color statusColor;
    String statusLabel;
    switch (appointment.status) {
      case 'confirmed':
        statusColor = Colors.green;
        statusLabel = 'Confirmado';
        break;
      case 'completed':
        statusColor = AppColors.outline;
        statusLabel = 'Concluído';
        break;
      case 'canceled':
        statusColor = AppColors.error;
        statusLabel = 'Cancelado';
        break;
      default:
        statusColor = AppColors.primary;
        statusLabel = 'Pendente';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isUpcoming ? AppColors.primary.withValues(alpha: 0.25) : AppColors.outlineVariant,
        ),
        boxShadow: isUpcoming
            ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.08), blurRadius: 12, offset: const Offset(0, 4))]
            : [],
      ),
      child: Row(
        children: [
          // Data
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: isUpcoming ? AppColors.primaryContainer.withValues(alpha: 0.15) : AppColors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isUpcoming ? AppColors.primary.withValues(alpha: 0.3) : AppColors.outlineVariant,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  DateFormat('dd').format(appointment.dateTime),
                  style: TextStyle(
                    color: isUpcoming ? AppColors.primary : AppColors.onSurfaceVariant,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  DateFormat('MMM', 'pt_BR').format(appointment.dateTime).toUpperCase(),
                  style: TextStyle(
                    color: isUpcoming ? AppColors.primary : AppColors.outline,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 16),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appointment.serviceName,
                  style: TextStyle(
                    color: isCanceled ? AppColors.onSurfaceVariant : AppColors.onSurface,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    decoration: isCanceled ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  appointment.professionalName,
                  style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.schedule, size: 13, color: AppColors.outline),
                    const SizedBox(width: 4),
                    Text(
                      dateStr,
                      style: const TextStyle(color: AppColors.outline, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Status + Preço
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'R\$ ${appointment.price.toStringAsFixed(2).replaceAll('.', ',')}',
                style: const TextStyle(color: AppColors.primary, fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
