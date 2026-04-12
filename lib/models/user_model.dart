class UserModel {
  final String id;
  final String name;
  final String email;
  final String photoUrl;
  final String bio;
  final List<String> foodPreferences;
  final double rating;
  final int totalSessions;
  final int sessionsCreated;
  final int sessionsJoined;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.photoUrl = '',
    this.bio = '',
    this.foodPreferences = const [],
    this.rating = 0.0,
    this.totalSessions = 0,
    this.sessionsCreated = 0,
    this.sessionsJoined = 0,
    required this.createdAt,
  });

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? photoUrl,
    String? bio,
    List<String>? foodPreferences,
    double? rating,
    int? totalSessions,
    int? sessionsCreated,
    int? sessionsJoined,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      bio: bio ?? this.bio,
      foodPreferences: foodPreferences ?? this.foodPreferences,
      rating: rating ?? this.rating,
      totalSessions: totalSessions ?? this.totalSessions,
      sessionsCreated: sessionsCreated ?? this.sessionsCreated,
      sessionsJoined: sessionsJoined ?? this.sessionsJoined,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }
}
