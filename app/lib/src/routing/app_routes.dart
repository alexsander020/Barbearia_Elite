// ══════════════════════════════════════════════════════════
//  BARBERFLOW ELITE — ROTAS
//  Todas as rotas do app em um único lugar
// ══════════════════════════════════════════════════════════

abstract class AppRoutes {
  // ── Auth ──
  static const String splash   = '/';
  static const String login    = '/login';
  static const String register = '/register';

  // ── Client ──
  static const String home                = '/home';
  static const String professionalDetails = '/professional/:id';
  static const String schedule            = '/schedule';
  static const String appointmentSummary  = '/appointment-summary';
  static const String myAppointments      = '/my-appointments';
  static const String queueRealtime       = '/queue';

  // ── Professional ──
  static const String professionalDashboard = '/pro/dashboard';
  static const String dailyAgenda           = '/pro/agenda';
  static const String attendance            = '/pro/attendance';
  static const String financialDashboard    = '/pro/financial';
  static const String manageServices        = '/pro/services';
  static const String proSettings           = '/pro/settings';

  // ── Settings ──
  static const String clientSettings        = '/settings';

  // ── Admin ──
  static const String adminDashboard     = '/admin/dashboard';
  static const String adminUsers         = '/admin/users';
  static const String adminNotifications = '/admin/notifications';
  static const String adminBroadcast     = '/admin/broadcast';
}
