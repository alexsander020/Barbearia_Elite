// UserModel — BarberFlow Elite

/// Define the role of the user within the system
enum UserRole {
  client,
  professional,
  admin,
}

/// Base User Model based on the JSON specification
class UserModel {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String photoUrl;
  final UserRole role;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.photoUrl,
    required this.role,
    required this.createdAt,
  });

  /// Creates a UserModel from a JSON map (Firestore Document)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String,
      photoUrl: json['photoUrl'] as String? ?? '',
      role: UserRole.values.firstWhere(
        (e) => e.name == json['role'],
        orElse: () => UserRole.client,
      ),
      // Firestore stores dates as Timestamp, we convert or parse string
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'].toString()) 
          : DateTime.now(),
    );
  }

  /// Converts the UserModel into a JSON map (for Firestore)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'photoUrl': photoUrl,
      'role': role.name,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? photoUrl,
    UserRole? role,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
