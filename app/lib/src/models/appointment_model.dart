import 'service_model.dart';

enum AppointmentStatus {
  scheduled,
  inProgress,
  completed,
  cancelled,
}

class AppointmentModel {
  final String id;
  final String clientId;
  final String professionalId;
  final List<ServiceModel> services;
  final DateTime date;
  final String startTime;
  final String endTime;
  final double totalPrice;
  final AppointmentStatus status;

  AppointmentModel({
    required this.id,
    required this.clientId,
    required this.professionalId,
    required this.services,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.totalPrice,
    required this.status,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    // Handling enum mapping safely
    final statusString = json['status'] as String? ?? 'scheduled';
    final parsedStatus = AppointmentStatus.values.firstWhere(
      (e) => e.name == statusString || e.toString().split('.').last == statusString,
      orElse: () => AppointmentStatus.scheduled,
    );

    return AppointmentModel(
      id: json['id'] as String,
      clientId: json['clientId'] as String,
      professionalId: json['professionalId'] as String,
      services: (json['services'] as List<dynamic>? ?? [])
          .map((e) => ServiceModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      date: json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
      totalPrice: (json['totalPrice'] as num).toDouble(),
      status: parsedStatus,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clientId': clientId,
      'professionalId': professionalId,
      'services': services.map((s) => s.toJson()).toList(),
      'date': date.toIso8601String(),
      'startTime': startTime,
      'endTime': endTime,
      'totalPrice': totalPrice,
      'status': status.name,
    };
  }
}
