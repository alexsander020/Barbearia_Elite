// ProfessionalModel — BarberFlow Elite

class ProfessionalModel {
  final String id;
  final String userId;
  final String bio;
  final double rating;
  final List<String> specialties;
  final List<String> workDays;
  final String startHour;
  final String endHour;

  ProfessionalModel({
    required this.id,
    required this.userId,
    required this.bio,
    required this.rating,
    required this.specialties,
    required this.workDays,
    required this.startHour,
    required this.endHour,
  });

  factory ProfessionalModel.fromJson(Map<String, dynamic> json) {
    return ProfessionalModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      bio: json['bio'] as String? ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
      specialties: List<String>.from(json['specialties'] ?? []),
      workDays: List<String>.from(json['workDays'] ?? []),
      startHour: json['startHour'] as String? ?? '09:00',
      endHour: json['endHour'] as String? ?? '18:00',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'bio': bio,
      'rating': rating,
      'specialties': specialties,
      'workDays': workDays,
      'startHour': startHour,
      'endHour': endHour,
    };
  }
}
