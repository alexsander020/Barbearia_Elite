import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/splash/splash_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/register_screen.dart';
import '../../features/client/home/home_screen.dart';
import '../../features/client/schedule/schedule_screen.dart';
import '../../features/client/schedule/appointment_summary_screen.dart';
import '../../features/client/appointments/my_appointments_screen.dart';
import '../../features/client/queue/queue_realtime_screen.dart';
import '../../features/professional/dashboard/professional_dashboard_screen.dart';
import '../../features/professional/agenda/daily_agenda_screen.dart';
import '../../features/professional/financial/financial_dashboard_screen.dart';
import '../../features/professional/services/manage_services_screen.dart';
import '../../src/core/auth/auth_service.dart';
import 'app_routes.dart';

// ── GoRouter Provider (Riverpod) ──
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateChangesProvider);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    redirect: (context, state) {
      if (authState.isLoading || authState.hasError) return null;

      final isAuth = authState.value != null;
      final isGoingToAuth = state.matchedLocation == AppRoutes.login || state.matchedLocation == AppRoutes.register;
      final isGoingToSplash = state.matchedLocation == AppRoutes.splash;

      // Se não está autenticado e tenta acessar área restrita -> Manda pro Login
      if (!isAuth && !isGoingToAuth && !isGoingToSplash) {
        return AppRoutes.login;
      }

      // Se está autenticado e tenta acessar Login/Register -> Manda pro Splash (que decide a role)
      if (isAuth && isGoingToAuth) {
        return AppRoutes.splash;
      }

      return null;
    },
    routes: [

      // ── Splash / Auth ──
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.schedule,
        builder: (context, state) => const ScheduleScreen(),
      ),
      GoRoute(
        path: AppRoutes.appointmentSummary,
        builder: (context, state) => const AppointmentSummaryScreen(),
      ),

      // ── Client Shell ──
      ShellRoute(
        builder: (context, state, child) => ClientShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: AppRoutes.myAppointments,
            builder: (context, state) => const MyAppointmentsScreen(),
          ),
          GoRoute(
            path: AppRoutes.queueRealtime,
            builder: (context, state) => const QueueRealtimeScreen(),
          ),
        ],
      ),

      // ── Professional Shell ──
      ShellRoute(
        builder: (context, state, child) => ProfessionalShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.professionalDashboard,
            builder: (context, state) => const ProfessionalDashboardScreen(),
          ),
          GoRoute(
            path: AppRoutes.dailyAgenda,
            builder: (context, state) => const DailyAgendaScreen(),
          ),
          GoRoute(
            path: AppRoutes.financialDashboard,
            builder: (context, state) => const FinancialDashboardScreen(),
          ),
          GoRoute(
            path: AppRoutes.manageServices,
            builder: (context, state) => const ManageServicesScreen(),
          ),
        ],
      ),
    ],
  );
});

// ══════════════════════════════════════════════════════════
//  CLIENT SHELL — Bottom Navigation (4 tabs)
// ══════════════════════════════════════════════════════════

class ClientShell extends StatelessWidget {
  const ClientShell({super.key, required this.child});
  final Widget child;

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith(AppRoutes.myAppointments)) return 1;
    if (location.startsWith(AppRoutes.queueRealtime)) return 2;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex(context),
        onDestinationSelected: (i) {
          switch (i) {
            case 0: context.go(AppRoutes.home); break;
            case 1: context.go(AppRoutes.myAppointments); break;
            case 2: context.go(AppRoutes.queueRealtime); break;
          }
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Início'),
          NavigationDestination(icon: Icon(Icons.calendar_today_outlined), selectedIcon: Icon(Icons.calendar_today), label: 'Agendamentos'),
          NavigationDestination(icon: Icon(Icons.people_outline), selectedIcon: Icon(Icons.people), label: 'Fila'),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════
//  PROFESSIONAL SHELL — Bottom Navigation (4 tabs)
// ══════════════════════════════════════════════════════════

class ProfessionalShell extends StatelessWidget {
  const ProfessionalShell({super.key, required this.child});
  final Widget child;

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith(AppRoutes.dailyAgenda))      return 1;
    if (location.startsWith(AppRoutes.financialDashboard)) return 2;
    if (location.startsWith(AppRoutes.manageServices))   return 3;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex(context),
        onDestinationSelected: (i) {
          switch (i) {
            case 0: context.go(AppRoutes.professionalDashboard); break;
            case 1: context.go(AppRoutes.dailyAgenda); break;
            case 2: context.go(AppRoutes.financialDashboard); break;
            case 3: context.go(AppRoutes.manageServices); break;
          }
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Dashboard'),
          NavigationDestination(icon: Icon(Icons.calendar_month_outlined), selectedIcon: Icon(Icons.calendar_month), label: 'Agenda'),
          NavigationDestination(icon: Icon(Icons.attach_money), selectedIcon: Icon(Icons.attach_money), label: 'Financeiro'),
          NavigationDestination(icon: Icon(Icons.content_cut_outlined), selectedIcon: Icon(Icons.content_cut), label: 'Serviços'),
        ],
      ),
    );
  }
}
