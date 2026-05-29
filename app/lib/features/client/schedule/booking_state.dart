import 'package:flutter_riverpod/flutter_riverpod.dart';

// Este provider manterá o estado do agendamento atual enquanto o usuário navega
// entre as telas de seleção de data/hora e a tela de resumo.

class BookingState {
  final DateTime? date;
  final String? time;
  final String serviceName;
  final double price;
  final String professionalId;
  final String professionalName;

  BookingState({
    this.date,
    this.time,
    this.serviceName = 'Corte Premium + Barba',
    this.price = 85.00,
    this.professionalId = 'prof_001_mock',
    this.professionalName = 'Arthur Master',
  });

  BookingState copyWith({
    DateTime? date,
    String? time,
    String? serviceName,
    double? price,
    String? professionalId,
    String? professionalName,
  }) {
    return BookingState(
      date: date ?? this.date,
      time: time ?? this.time,
      serviceName: serviceName ?? this.serviceName,
      price: price ?? this.price,
      professionalId: professionalId ?? this.professionalId,
      professionalName: professionalName ?? this.professionalName,
    );
  }

  // Gera o DateTime combinado de (data + hora)
  DateTime? get combinedDateTime {
    if (date == null || time == null) return null;
    
    // O formato do time é 'HH:mm'
    final parts = time!.split(':');
    if (parts.length != 2) return date;

    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = int.tryParse(parts[1]) ?? 0;

    return DateTime(
      date!.year,
      date!.month,
      date!.day,
      hour,
      minute,
    );
  }
}

// O Notifier que vai expor esse estado
class BookingStateNotifier extends StateNotifier<BookingState> {
  BookingStateNotifier() : super(BookingState());

  void setDate(DateTime date) {
    state = state.copyWith(date: date, time: null); // Reseta o horário ao mudar de data
  }

  void setTime(String time) {
    state = state.copyWith(time: time);
  }

  void clear() {
    state = BookingState(); // Restaura pros valores padrão do mock (Corte + Profissional)
  }
}

// O provider global para usar nas telas
final bookingStateProvider = StateNotifierProvider<BookingStateNotifier, BookingState>((ref) {
  return BookingStateNotifier();
});
