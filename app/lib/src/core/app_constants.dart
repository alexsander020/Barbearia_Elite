// ══════════════════════════════════════════════════════════
//  BARBERFLOW ELITE — STRINGS DO APP
//  Centralizadas para facilitar futura internacionalização
// ══════════════════════════════════════════════════════════

abstract class AppStrings {
  // ── Brand ──
  static const String appName    = 'BarberFlow Elite';
  static const String tagline    = 'Gestão Premium para Barbearias';

  // ── Auth ──
  static const String login            = 'Entrar';
  static const String register         = 'Criar conta';
  static const String logout           = 'Sair';
  static const String forgotPassword   = 'Esqueci minha senha';
  static const String loginWithGoogle  = 'Entrar com Google';
  static const String emailHint        = 'Seu e-mail';
  static const String passwordHint     = 'Sua senha';
  static const String nameHint         = 'Seu nome completo';
  static const String phoneHint        = 'Seu telefone';
  static const String confirmPassword  = 'Confirmar senha';

  // ── Validation ──
  static const String fieldRequired          = 'Este campo é obrigatório';
  static const String invalidEmail           = 'E-mail inválido';
  static const String invalidPhone           = 'Telefone inválido';
  static const String passwordTooShort       = 'Senha deve ter pelo menos 6 caracteres';
  static const String passwordsDoNotMatch    = 'As senhas não coincidem';

  // ── Appointment Status ──
  static const String statusScheduled  = 'Agendado';
  static const String statusInProgress = 'Em atendimento';
  static const String statusCompleted  = 'Finalizado';
  static const String statusCancelled  = 'Cancelado';

  // ── Actions ──
  static const String confirm         = 'Confirmar';
  static const String cancel          = 'Cancelar';
  static const String save            = 'Salvar';
  static const String edit            = 'Editar';
  static const String delete          = 'Excluir';
  static const String add             = 'Adicionar';
  static const String search          = 'Pesquisar...';
  static const String back            = 'Voltar';
  static const String next            = 'Próximo';
  static const String finish          = 'Finalizar';
  static const String startAttendance = 'Iniciar Atendimento';
  static const String finishAttendance = 'Finalizar Atendimento';
  static const String notifyFiveMin   = 'Avisar: faltam 5 minutos';

  // ── Navigation ──
  static const String navHome          = 'Início';
  static const String navAppointments  = 'Agendamentos';
  static const String navQueue         = 'Fila';
  static const String navProfile       = 'Perfil';
  static const String navDashboard     = 'Dashboard';
  static const String navAgenda        = 'Agenda';
  static const String navFinancial     = 'Financeiro';
  static const String navServices      = 'Serviços';

  // ── Notifications ──
  static const String notifAppointmentConfirmed = 'Agendamento confirmado!';
  static const String notifAppointmentReminder  = 'Lembrete de horário';
  static const String notifFiveMinWarning       = 'Faltam 5 minutos para o seu atendimento';
  static const String notifAttendanceStarted    = 'Seu atendimento foi iniciado';
  static const String notifNewAppointment       = 'Novo agendamento recebido';
  static const String notifCancellation         = 'Agendamento cancelado';
  static const String notifClientLate           = 'Cliente com atraso';

  // ── Placeholders / Empty States ──
  static const String noAppointmentsToday = 'Nenhum atendimento hoje';
  static const String noProfessionals     = 'Nenhum profissional disponível';
  static const String noServices          = 'Nenhum serviço cadastrado';
  static const String emptyQueue          = 'Fila vazia no momento';

  // ── Dashboard Cards ──
  static const String todayRevenue     = 'Faturamento do dia';
  static const String todayClients     = 'Clientes hoje';
  static const String nextAppointment  = 'Próximo atendimento';
  static const String hoursWorked      = 'Horas trabalhadas';
}

// ══════════════════════════════════════════════════════════
//  REGRAS DE NEGÓCIO (Variáveis configuráveis)
// ══════════════════════════════════════════════════════════

abstract class AppConstants {
  // Tempo de tolerância para cliente atraso (minutos)
  static const int lateThresholdMinutes = 5;

  // Antecedência mínima para agendamento (horas)
  static const int minBookingLeadHours = 1;

  // Antecedência máxima para agendamento (dias)
  static const int maxBookingDaysAhead = 60;

  // Duração padrão de serviço caso não especificado (minutos)
  static const int defaultServiceDurationMinutes = 30;

  // Intervalo entre slots de horário (minutos)
  static const int slotIntervalMinutes = 15;

  // Nota mínima para ser exibido como "Top Rated"
  static const double topRatedThreshold = 4.5;

  // Coleções do Firestore
  static const String colUsers         = 'users';
  static const String colProfessionals = 'professionals';
  static const String colServices      = 'services';
  static const String colAppointments  = 'appointments';
  static const String colFinancial     = 'financial';

  // Dias da semana (para workDays dos profissionais)
  static const List<String> weekDays = [
    'Domingo',
    'Segunda-feira',
    'Terça-feira',
    'Quarta-feira',
    'Quinta-feira',
    'Sexta-feira',
    'Sábado',
  ];

  // Slots de horário padrão (para uso na tela de agendamento)
  static const String defaultStartHour = '09:00';
  static const String defaultEndHour   = '19:00';
}
