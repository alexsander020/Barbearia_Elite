import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../src/theme/app_colors.dart';
import '../../../src/core/app_constants.dart';
import '../../../src/routing/app_routes.dart';
import 'booking_state.dart';

class ScheduleScreen extends ConsumerWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booking = ref.watch(bookingStateProvider);
    final notifier = ref.read(bookingStateProvider.notifier);

    final morningTimes = ['09:00', '09:30', '10:00', '10:30', '11:00', '11:30'];
    final afternoonTimes = ['13:00', '14:00', '14:30', '15:30', '16:00', '17:30'];

    final selectedDate = booking.date ?? DateTime.now();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.onSurfaceVariant),
          onPressed: () => context.pop(),
        ),
        title: const Text('Agendamento'),
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
                    // ── Professional Info ──
                    Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.primaryContainer.withValues(alpha: 0.4)),
                          ),
                          child: const Icon(Icons.person, color: AppColors.outline, size: 32),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              booking.professionalName,
                              style: const TextStyle(color: AppColors.onSurface, fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              booking.serviceName,
                              style: TextStyle(color: AppColors.onSurfaceVariant.withValues(alpha: 0.8), fontSize: 14),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // ── Date Picker ──
                    const Text(
                      'Selecione a Data',
                      style: TextStyle(color: AppColors.onSurface, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 90,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: 14,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          final date = DateTime.now().add(Duration(days: index));
                          final isSelected = date.day == selectedDate.day && date.month == selectedDate.month;
                          final dayName = DateFormat('E', 'pt_BR').format(date).toUpperCase();
                          final dayNumber = DateFormat('dd').format(date);

                          return GestureDetector(
                            onTap: () => notifier.setDate(date),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 70,
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.primary : AppColors.surfaceContainerLow,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSelected ? AppColors.primaryContainer : AppColors.outlineVariant,
                                ),
                                boxShadow: isSelected
                                    ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.25), blurRadius: 12, offset: const Offset(0, 4))]
                                    : [],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    dayName,
                                    style: TextStyle(
                                      color: isSelected ? AppColors.onPrimary : AppColors.onSurfaceVariant,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    dayNumber,
                                    style: TextStyle(
                                      color: isSelected ? AppColors.onPrimary : AppColors.onSurface,
                                      fontSize: 22,
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

                    const SizedBox(height: 32),

                    // ── Time Slots ──
                    const Text(
                      'Horários Disponíveis',
                      style: TextStyle(color: AppColors.onSurface, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    const Text('Manhã', style: TextStyle(color: AppColors.outline, fontSize: 14)),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: morningTimes.map((time) => _TimeSlot(
                        time: time,
                        isSelected: booking.time == time,
                        onTap: () => notifier.setTime(time),
                      )).toList(),
                    ),
                    const SizedBox(height: 24),
                    const Text('Tarde', style: TextStyle(color: AppColors.outline, fontSize: 14)),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: afternoonTimes.map((time) => _TimeSlot(
                        time: time,
                        isSelected: booking.time == time,
                        onTap: () => notifier.setTime(time),
                      )).toList(),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),

            // ── Footer CTA ──
            Container(
              padding: const EdgeInsets.all(AppSpacing.marginMobile),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainer,
                border: const Border(top: BorderSide(color: AppColors.outlineVariant)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Total Estimado', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12)),
                        const SizedBox(height: 4),
                        Text(
                          'R\$ ${booking.price.toStringAsFixed(2).replaceAll('.', ',')}',
                          style: const TextStyle(color: AppColors.primary, fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: booking.time == null
                            ? null
                            : () => context.push(AppRoutes.appointmentSummary),
                        child: const Text('Avançar', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimeSlot extends StatelessWidget {
  const _TimeSlot({required this.time, required this.isSelected, required this.onTap});
  final String time;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 85,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryContainer.withValues(alpha: 0.15) : AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.outlineVariant,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          time,
          style: TextStyle(
            color: isSelected ? AppColors.primary : AppColors.onSurface,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
