class AppointmentModel {
  final String id;
  final String clientId;
  final String clientName;
  final String professionalId;
  final String professionalName;
  final String serviceName;
  final double price;
  final DateTime dateTime;
  final String status; // 'pending', 'confirmed', 'completed', 'canceled'
  final DateTime createdAt;

  AppointmentModel({
    required this.id,
    required this.clientId,
    required this.clientName,
    required this.professionalId,
    required this.professionalName,
    required this.serviceName,
    required this.price,
    required this.dateTime,
    required this.status,
    required this.createdAt,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json, String id) {
    return AppointmentModel(
      id: id,
      clientId: json['clientId'] ?? '',
      clientName: json['clientName'] ?? '',
      professionalId: json['professionalId'] ?? '',
      professionalName: json['professionalName'] ?? '',
      serviceName: json['serviceName'] ?? '',
      price: (json['price'] ?? 0.0).toDouble(),
      dateTime: json['dateTime'] != null 
          ? DateTime.parse(json['dateTime']) 
          : DateTime.now(),
      status: json['status'] ?? 'pending',
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'clientId': clientId,
      'clientName': clientName,
      'professionalId': professionalId,
      'professionalName': professionalName,
      'serviceName': serviceName,
      'price': price,
      'dateTime': dateTime.toIso8601String(),
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
