import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../src/theme/app_colors.dart';
import '../../../src/core/database/firestore_service.dart';
import '../../../src/core/models/appointment_model.dart';

const _mockProfessionalId = 'prof_001_mock';

// Provider da agenda por data selecionada
final agendaDateProvider = StateProvider<DateTime>((ref) => DateTime.now());

final agendaAppointmentsProvider = StreamProvider<List<AppointmentModel>>((ref) {
  final selectedDate = ref.watch(agendaDateProvider);
  final startOfDay = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);

  return ref
      .watch(firestoreServiceProvider)
      .getProfessionalAppointments(_mockProfessionalId, startOfDay.subtract(const Duration(seconds: 1)))
      .map((list) => list
          .where((a) =>
              a.dateTime.year == selectedDate.year &&
              a.dateTime.month == selectedDate.month &&
              a.dateTime.day == selectedDate.day)
          .toList());
});

// ══════════════════════════════════════════════════════════
//  DAILY AGENDA SCREEN — Real Data
// ══════════════════════════════════════════════════════════

class DailyAgendaScreen extends ConsumerWidget {
  const DailyAgendaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(agendaDateProvider);
    final agendaAsync = ref.watch(agendaAppointmentsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Agenda'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ── Seletor de Data Horizontal ──
            Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: const BoxDecoration(
                color: AppColors.surfaceContainer,
                border: Border(bottom: BorderSide(color: AppColors.outlineVariant)),
              ),
              child: SizedBox(
                height: 75,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: 14,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    final date = DateTime.now().subtract(const Duration(days: 2)).add(Duration(days: index));
                    final isSelected = date.day == selectedDate.day &&
                        date.month == selectedDate.month &&
                        date.year == selectedDate.year;
                    final dayName = DateFormat('E', 'pt_BR').format(date).toUpperCase();
                    final dayNumber = DateFormat('dd').format(date);

                    return GestureDetector(
                      onTap: () => ref.read(agendaDateProvider.notifier).state = date,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 62,
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : Colors.transparent,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected ? AppColors.primaryContainer : AppColors.outlineVariant,
                            width: isSelected ? 1.5 : 1,
                          ),
                          boxShadow: isSelected
                              ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.25), blurRadius: 8)]
                              : [],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(dayName,
                                style: TextStyle(
                                  color: isSelected ? AppColors.onPrimary : AppColors.onSurfaceVariant,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                )),
                            const SizedBox(height: 4),
                            Text(dayNumber,
                                style: TextStyle(
                                  color: isSelected ? AppColors.onPrimary : AppColors.onSurface,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                )),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // ── Resumo do dia ──
            agendaAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
              data: (appts) {
                final total = appts.fold(0.0, (s, a) => s + a.price);
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  color: AppColors.surfaceContainerLow,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${appts.length} agendamentos',
                          style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13)),
                      Text(
                        'Total: R\$ ${total.toStringAsFixed(2).replaceAll('.', ',')}',
                        style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ],
                  ),
                );
              },
            ),

            // ── Lista / Timeline de Agendamentos ──
            Expanded(
              child: agendaAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
                error: (e, _) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.wifi_off_rounded, color: AppColors.outline, size: 48),
                      const SizedBox(height: 12),
                      const Text('Erro ao carregar agenda', style: TextStyle(color: AppColors.onSurfaceVariant)),
                    ],
                  ),
                ),
                data: (appointments) {
                  if (appointments.isEmpty) {
                    return _buildEmptyDay(selectedDate);
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: appointments.length,
                    itemBuilder: (context, index) {
                      return _TimelineItem(
                        appointment: appointments[index],
                        isLast: index == appointments.length - 1,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyDay(DateTime date) {
    final isToday = date.day == DateTime.now().day &&
        date.month == DateTime.now().month &&
        date.year == DateTime.now().year;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: AppColors.surfaceContainerLow,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.event_available_outlined, color: AppColors.outline, size: 48),
          ),
          const SizedBox(height: 20),
          Text(
            isToday ? 'Nenhum agendamento hoje' : 'Nenhum agendamento neste dia',
            style: const TextStyle(color: AppColors.onSurface, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text('Dia livre!', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 14)),
        ],
      ),
    );
  }
}

// ── Item da Timeline ──
class _TimelineItem extends ConsumerWidget {
  const _TimelineItem({required this.appointment, required this.isLast});
  final AppointmentModel appointment;
  final bool isLast;

  void _showActions(BuildContext context, WidgetRef ref) {
    final status = appointment.status;
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceContainer,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                child: Column(
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.outlineVariant,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Agendamento de ${appointment.clientName}',
                      style: const TextStyle(
                        color: AppColors.onSurface,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${appointment.serviceName} • R\$ ${appointment.price.toStringAsFixed(2).replaceAll('.', ',')}',
                      style: const TextStyle(
                        color: AppColors.onSurfaceVariant,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(color: AppColors.outlineVariant, height: 1),
              if (status == 'pending') ...[
                ListTile(
                  leading: const Icon(Icons.check_circle_outline, color: Colors.green),
                  title: const Text('Confirmar Agendamento', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                  onTap: () async {
                    Navigator.pop(context);
                    await ref.read(firestoreServiceProvider).updateAppointmentStatus(appointment.id, 'confirmed');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.cancel_outlined, color: AppColors.error),
                  title: const Text('Cancelar Agendamento', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
                  onTap: () async {
                    Navigator.pop(context);
                    await ref.read(firestoreServiceProvider).updateAppointmentStatus(appointment.id, 'canceled');
                  },
                ),
              ],
              if (status == 'confirmed') ...[
                ListTile(
                  leading: const Icon(Icons.done_all, color: AppColors.primary),
                  title: const Text('Finalizar Serviço', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                  onTap: () async {
                    Navigator.pop(context);
                    await ref.read(firestoreServiceProvider).updateAppointmentStatus(appointment.id, 'completed');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.cancel_outlined, color: AppColors.error),
                  title: const Text('Cancelar Agendamento', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
                  onTap: () async {
                    Navigator.pop(context);
                    await ref.read(firestoreServiceProvider).updateAppointmentStatus(appointment.id, 'canceled');
                  },
                ),
              ],
              if (status == 'completed' || status == 'canceled') ...[
                ListTile(
                  leading: const Icon(Icons.restart_alt, color: AppColors.outline),
                  title: const Text('Voltar para Pendente', style: TextStyle(color: AppColors.onSurface)),
                  onTap: () async {
                    Navigator.pop(context);
                    await ref.read(firestoreServiceProvider).updateAppointmentStatus(appointment.id, 'pending');
                  },
                ),
              ],
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timeStr = DateFormat('HH:mm').format(appointment.dateTime);
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
        statusLabel = 'Finalizado';
        break;
      case 'canceled':
        statusColor = AppColors.error;
        statusLabel = 'Cancelado';
        break;
      default:
        statusColor = AppColors.primary;
        statusLabel = 'Pendente';
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Horário
          SizedBox(
            width: 56,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const SizedBox(height: 14),
                Text(timeStr,
                    style: TextStyle(
                      color: isCanceled ? AppColors.outline : AppColors.onSurface,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    )),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Linha do tempo + bolinha
          Column(
            children: [
              Container(
                width: 14, height: 14,
                margin: const EdgeInsets.only(top: 16),
                decoration: BoxDecoration(
                  color: isCanceled ? AppColors.background : statusColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: statusColor, width: 2),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: AppColors.outlineVariant.withValues(alpha: 0.5),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),

          // Card do agendamento
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 8 : 20, top: 6),
              child: GestureDetector(
                onTap: () => _showActions(context, ref),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainer,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isCanceled
                          ? AppColors.error.withValues(alpha: 0.4)
                          : AppColors.outlineVariant,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(appointment.clientName,
                                style: TextStyle(
                                  color: isCanceled ? AppColors.outline : AppColors.onSurface,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  decoration: isCanceled ? TextDecoration.lineThrough : null,
                                ),
                                overflow: TextOverflow.ellipsis),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(statusLabel,
                                style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.content_cut_rounded, color: AppColors.onSurfaceVariant, size: 13),
                          const SizedBox(width: 6),
                          Text(appointment.serviceName,
                              style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13)),
                          const Spacer(),
                          Text(
                            'R\$ ${appointment.price.toStringAsFixed(2).replaceAll('.', ',')}',
                            style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
