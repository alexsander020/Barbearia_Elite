import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../src/theme/app_colors.dart';
import '../../../src/core/app_constants.dart';

class DailyAgendaScreen extends StatefulWidget {
  const DailyAgendaScreen({super.key});

  @override
  State<DailyAgendaScreen> createState() => _DailyAgendaScreenState();
}

class _DailyAgendaScreenState extends State<DailyAgendaScreen> {
  DateTime _selectedDate = DateTime.now();

  // Mock data for appointments
  final List<Map<String, dynamic>> _appointments = [
    {
      'time': '09:00',
      'client': 'Thiago Mendonça',
      'service': 'Corte Clássico',
      'status': 'Finalizado',
      'duration': '30 min',
    },
    {
      'time': '09:30',
      'client': 'Livre',
      'service': '',
      'status': 'Livre',
      'duration': '30 min',
    },
    {
      'time': '10:00',
      'client': 'Lucas Oliveira',
      'service': 'Corte + Barba',
      'status': 'Em atendimento',
      'duration': '60 min',
    },
    {
      'time': '11:00',
      'client': 'Marcos Silva',
      'service': 'Sobrancelha',
      'status': 'Agendado',
      'duration': '15 min',
    },
    {
      'time': '11:15',
      'client': 'João Mendes',
      'service': 'Platinado',
      'status': 'Cancelado',
      'duration': '90 min',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Agenda do Dia'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {},
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        onPressed: () {
          // TODO: Open dialog to block time manually
        },
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ── Horizontal Date Picker ──
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: const BoxDecoration(
                color: AppColors.surfaceContainer,
                border: Border(bottom: BorderSide(color: AppColors.outlineVariant)),
              ),
              child: SizedBox(
                height: 75,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.marginMobile),
                  scrollDirection: Axis.horizontal,
                  itemCount: 14,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final date = DateTime.now().subtract(const Duration(days: 3)).add(Duration(days: index));
                    final isSelected = date.day == _selectedDate.day && date.month == _selectedDate.month;
                    final dayName = DateFormat('E', 'pt_BR').format(date).toUpperCase();
                    final dayNumber = DateFormat('dd').format(date);

                    return GestureDetector(
                      onTap: () => setState(() => _selectedDate = date),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 65,
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? AppColors.primaryContainer : AppColors.outlineVariant,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              dayName,
                              style: TextStyle(
                                color: isSelected ? AppColors.onPrimary : AppColors.onSurfaceVariant,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              dayNumber,
                              style: TextStyle(
                                color: isSelected ? AppColors.onPrimary : AppColors.onSurface,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // ── Agenda Timeline ──
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(AppSpacing.marginMobile),
                itemCount: _appointments.length,
                itemBuilder: (context, index) {
                  final appt = _appointments[index];
                  return _buildTimelineItem(appt);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineItem(Map<String, dynamic> appt) {
    final status = appt['status'] as String;
    final isFree = status == 'Livre';
    final isCancelled = status == 'Cancelado';

    // Definir cores com base no status
    Color statusColor;
    switch (status) {
      case 'Finalizado':
        statusColor = Colors.grey;
        break;
      case 'Em atendimento':
        statusColor = Colors.green;
        break;
      case 'Agendado':
        statusColor = AppColors.primary;
        break;
      case 'Cancelado':
        statusColor = AppColors.error;
        break;
      default:
        statusColor = AppColors.outlineVariant;
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Coluna do Horário ──
          SizedBox(
            width: 60,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const SizedBox(height: 16),
                Text(
                  appt['time'],
                  style: TextStyle(
                    color: isFree ? AppColors.outline : AppColors.onSurface,
                    fontWeight: isFree ? FontWeight.normal : FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  appt['duration'],
                  style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 10),
                ),
              ],
            ),
          ),
          
          const SizedBox(width: 12),

          // ── Linha do Tempo e Bolinha ──
          Column(
            children: [
              Container(
                width: 16,
                height: 16,
                margin: const EdgeInsets.only(top: 18),
                decoration: BoxDecoration(
                  color: isFree ? AppColors.background : statusColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isFree ? AppColors.outlineVariant : statusColor,
                    width: 2,
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  width: 2,
                  color: AppColors.outlineVariant.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
          
          const SizedBox(width: 12),

          // ── Card do Agendamento ──
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24.0, top: 8.0),
              child: isFree
                  ? _buildFreeSlot()
                  : _buildAppointmentCard(appt, statusColor, isCancelled),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFreeSlot() {
    return GestureDetector(
      onTap: () {
        // TODO: Action for free slot (e.g., manual booking)
      },
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.outlineVariant, style: BorderStyle.solid),
        ),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: const Text(
          'Horário Livre',
          style: TextStyle(color: AppColors.outline, fontStyle: FontStyle.italic),
        ),
      ),
    );
  }

  Widget _buildAppointmentCard(Map<String, dynamic> appt, Color statusColor, bool isCancelled) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isCancelled ? AppColors.error.withValues(alpha: 0.5) : AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  appt['client'],
                  style: TextStyle(
                    color: isCancelled ? AppColors.outline : AppColors.onSurface,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    decoration: isCancelled ? TextDecoration.lineThrough : null,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  appt['status'],
                  style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.content_cut, color: AppColors.onSurfaceVariant, size: 14),
              const SizedBox(width: 6),
              Text(
                appt['service'],
                style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13),
              ),
            ],
          ),
          if (appt['status'] == 'Agendado' || appt['status'] == 'Em atendimento') ...[
            const SizedBox(height: 12),
            const Divider(color: AppColors.outlineVariant),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text('Ações', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ]
        ],
      ),
    );
  }
}
