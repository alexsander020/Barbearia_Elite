class FinancialModel {
  final String id;
  final String professionalId;
  final String appointmentId;
  final double amount;
  final DateTime createdAt;

  FinancialModel({
    required this.id,
    required this.professionalId,
    required this.appointmentId,
    required this.amount,
    required this.createdAt,
  });

  factory FinancialModel.fromJson(Map<String, dynamic> json) {
    return FinancialModel(
      id: json['id'] as String,
      professionalId: json['professionalId'] as String,
      appointmentId: json['appointmentId'] as String,
      amount: (json['amount'] as num).toDouble(),
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'professionalId': professionalId,
      'appointmentId': appointmentId,
      'amount': amount,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
