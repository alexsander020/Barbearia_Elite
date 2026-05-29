import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../src/theme/app_colors.dart';
import '../../../src/core/app_constants.dart';
import '../../../src/routing/app_routes.dart';

class ProfessionalDashboardScreen extends StatelessWidget {
  const ProfessionalDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.marginMobile),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header Greeting ──
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
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
                      const Text(
                        'Olá, Arthur',
                        style: TextStyle(color: AppColors.onSurface, fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Sexta-feira, 15 Out',
                        style: TextStyle(color: AppColors.primary.withValues(alpha: 0.8), fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 32),

              // ── Key Metrics (Stats) ──
              Row(
                children: [
                  _buildStatCard(
                    title: 'Faturamento Hoje',
                    value: 'R\$ 450',
                    icon: Icons.attach_money,
                    color: Colors.green,
                  ),
                  const SizedBox(width: 16),
                  _buildStatCard(
                    title: 'Clientes',
                    value: '8 / 12',
                    icon: Icons.people_outline,
                    color: AppColors.primary,
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // ── Next Appointment Banner ──
              const Text(
                'Próximo Atendimento',
                style: TextStyle(color: AppColors.onSurface, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.surfaceContainerHigh, AppColors.surfaceContainerLow],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Column(
                        children: [
                          Text('14:30', style: TextStyle(color: AppColors.primary, fontSize: 18, fontWeight: FontWeight.bold)),
                          Text('Daqui 15m', style: TextStyle(color: AppColors.primary, fontSize: 10)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Marcos Silva', style: TextStyle(color: AppColors.onSurface, fontSize: 16, fontWeight: FontWeight.bold)),
                          SizedBox(height: 4),
                          Text('Corte Premium + Barba', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // ── Quick Actions ──
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // TODO: Iniciar atendimento flow
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Atendimento iniciado')));
                      },
                      icon: const Icon(Icons.play_circle_fill),
                      label: const Text('Iniciar Atendimento'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // ── Today's Queue ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Agenda de Hoje',
                    style: TextStyle(color: AppColors.onSurface, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () => context.go(AppRoutes.dailyAgenda), // Navigate to full agenda tab
                    child: const Text('Ver tudo', style: TextStyle(color: AppColors.primary)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 3,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final times = ['15:30', '16:00', '17:00'];
                  final names = ['Lucas Oliveira', 'Pedro Santos', 'João Mendes'];
                  final services = ['Degradê', 'Barba', 'Corte Infantil'];
                  
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.outlineVariant),
                    ),
                    child: Row(
                      children: [
                        Text(
                          times[index],
                          style: const TextStyle(color: AppColors.onSurfaceVariant, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(width: 16),
                        Container(width: 2, height: 30, color: AppColors.outlineVariant),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(names[index], style: const TextStyle(color: AppColors.onSurface, fontWeight: FontWeight.bold)),
                              Text(services[index], style: const TextStyle(color: AppColors.outline, fontSize: 12)),
                            ],
                          ),
                        ),
                        const Icon(Icons.more_vert, color: AppColors.outlineVariant),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({required String title, required String value, required IconData icon, required Color color}) {
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
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(color: AppColors.onSurface, fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
