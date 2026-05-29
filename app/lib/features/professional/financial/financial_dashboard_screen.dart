import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../src/theme/app_colors.dart';
import '../../../src/core/app_constants.dart';
import '../../../src/core/database/firestore_service.dart';
import '../../../src/core/models/appointment_model.dart';

// ── Período selecionado ──
enum FinancialPeriod { today, week, month }

final financialPeriodProvider = StateProvider<FinancialPeriod>(
  (ref) => FinancialPeriod.today,
);

// ── Provider da stream de agendamentos do profissional ──
// No MVP usamos o ID do profissional mock. Quando o profissional real logar,
// basta trocar pela ID real do authServiceProvider.
const _mockProfessionalId = 'prof_001_mock';

final professionalAppointmentsProvider = StreamProvider.family<List<AppointmentModel>, DateTime>(
  (ref, from) => ref.watch(firestoreServiceProvider).getProfessionalAppointments(
        _mockProfessionalId,
        from,
      ),
);

// ── Provider derivado com os dados financeiros calculados ──
final financialDataProvider = Provider<({
  AsyncValue<List<AppointmentModel>> appointmentsAsync,
  DateTime fromDate,
})>((ref) {
  final period = ref.watch(financialPeriodProvider);
  final now = DateTime.now();

  final DateTime fromDate;
  switch (period) {
    case FinancialPeriod.today:
      fromDate = DateTime(now.year, now.month, now.day);
      break;
    case FinancialPeriod.week:
      fromDate = now.subtract(const Duration(days: 7));
      break;
    case FinancialPeriod.month:
      fromDate = DateTime(now.year, now.month, 1);
      break;
  }

  final appointmentsAsync = ref.watch(professionalAppointmentsProvider(fromDate));
  return (appointmentsAsync: appointmentsAsync, fromDate: fromDate);
});

// ══════════════════════════════════════════════════════════
//  FINANCIAL DASHBOARD SCREEN
// ══════════════════════════════════════════════════════════

class FinancialDashboardScreen extends ConsumerWidget {
  const FinancialDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final period = ref.watch(financialPeriodProvider);
    final financial = ref.watch(financialDataProvider);
    final currency = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Financeiro'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async => ref.invalidate(professionalAppointmentsProvider),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AppSpacing.marginMobile),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [

                // ── Filtros de Período ──
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _PeriodChip(
                        label: 'Hoje',
                        isSelected: period == FinancialPeriod.today,
                        onTap: () => ref.read(financialPeriodProvider.notifier).state = FinancialPeriod.today,
                      ),
                      const SizedBox(width: 8),
                      _PeriodChip(
                        label: 'Semana',
                        isSelected: period == FinancialPeriod.week,
                        onTap: () => ref.read(financialPeriodProvider.notifier).state = FinancialPeriod.week,
                      ),
                      const SizedBox(width: 8),
                      _PeriodChip(
                        label: 'Mês',
                        isSelected: period == FinancialPeriod.month,
                        onTap: () => ref.read(financialPeriodProvider.notifier).state = FinancialPeriod.month,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // ── Card Principal de Faturamento ──
                financial.appointmentsAsync.when(
                  loading: () => _RevenueCardSkeleton(),
                  error: (e, _) => _ErrorCard(message: e.toString()),
                  data: (appointments) {
                    final total = appointments.fold(0.0, (sum, a) => sum + a.price);
                    final commission = total * 0.50;
                    final count = appointments.length;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Total Card
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.surfaceContainerHigh, AppColors.surfaceContainerLow],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.08),
                                blurRadius: 24,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              const Text('Faturamento Bruto',
                                style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 14)),
                              const SizedBox(height: 8),
                              Text(
                                currency.format(total),
                                style: const TextStyle(color: AppColors.primary, fontSize: 36, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '$count ${count == 1 ? 'atendimento' : 'atendimentos'}',
                                style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13),
                              ),
                              const SizedBox(height: 20),
                              const Divider(color: AppColors.outlineVariant),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Sua Comissão (50%)',
                                    style: TextStyle(color: AppColors.onSurfaceVariant)),
                                  Text(
                                    currency.format(commission),
                                    style: const TextStyle(
                                      color: Colors.green,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // ── Métricas Rápidas ──
                        Row(
                          children: [
                            _MetricCard(
                              label: 'Ticket Médio',
                              value: count > 0 ? currency.format(total / count) : 'R\$ 0,00',
                              icon: Icons.show_chart_rounded,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 12),
                            _MetricCard(
                              label: 'Atendimentos',
                              value: count.toString(),
                              icon: Icons.content_cut_rounded,
                              color: Colors.blue,
                            ),
                          ],
                        ),

                        const SizedBox(height: 32),

                        // ── Últimos Atendimentos ──
                        const Text('Últimos Atendimentos',
                          style: TextStyle(color: AppColors.onSurface, fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),

                        if (appointments.isEmpty)
                          _buildEmptyTransactions()
                        else
                          ...appointments.take(10).map((a) => _TransactionTile(
                            appointment: a,
                            currency: currency,
                          )),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyTransactions() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: const Column(
        children: [
          Icon(Icons.receipt_long_outlined, color: AppColors.outline, size: 40),
          SizedBox(height: 12),
          Text(
            'Nenhum atendimento neste período',
            style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

// ── Chip de período ──
class _PeriodChip extends StatelessWidget {
  const _PeriodChip({required this.label, required this.isSelected, required this.onTap});
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryContainer.withValues(alpha: 0.2) : AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.outlineVariant,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.primary : AppColors.onSurfaceVariant,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

// ── Card de métrica ──
class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.label, required this.value, required this.icon, required this.color});
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.outlineVariant),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(value,
                    style: const TextStyle(color: AppColors.onSurface, fontSize: 18, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(label,
                    style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 11)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Linha de transação ──
class _TransactionTile extends StatelessWidget {
  const _TransactionTile({required this.appointment, required this.currency});
  final AppointmentModel appointment;
  final NumberFormat currency;

  @override
  Widget build(BuildContext context) {
    final timeStr = DateFormat('dd/MM · HH:mm', 'pt_BR').format(appointment.dateTime);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.content_cut_rounded, color: Colors.green, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(appointment.clientName,
                  style: const TextStyle(color: AppColors.onSurface, fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 3),
                Text(appointment.serviceName,
                  style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                currency.format(appointment.price),
                style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const SizedBox(height: 3),
              Text(timeStr, style: const TextStyle(color: AppColors.outline, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Skeleton de loading ──
class _RevenueCardSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: const Center(
        child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2.5),
      ),
    );
  }
}

// ── Card de erro ──
class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.wifi_off_rounded, color: AppColors.error),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Erro ao carregar dados. Puxe para atualizar.',
              style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
