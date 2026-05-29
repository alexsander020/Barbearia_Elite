class ServiceModel {
  final String id;
  final String professionalId;
  final String name;
  final double price;
  final int durationMinutes;
  final bool active;

  ServiceModel({
    required this.id,
    required this.professionalId,
    required this.name,
    required this.price,
    required this.durationMinutes,
    required this.active,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'] as String,
      professionalId: json['professionalId'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      durationMinutes: json['durationMinutes'] as int? ?? 30,
      active: json['active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'professionalId': professionalId,
      'name': name,
      'price': price,
      'durationMinutes': durationMinutes,
      'active': active,
    };
  }
}
