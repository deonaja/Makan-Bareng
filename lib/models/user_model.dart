import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String photoUrl;
  final String bio;
  final List<String> foodPreferences;
  final bool isAdmin;
  final double averageRating;
  final int totalReviews;
  final int sessionsCreated;
  final int sessionsJoined;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime lastLoginAt;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.photoUrl = '',
    this.bio = '',
    this.foodPreferences = const [],
    this.isAdmin = false,
    this.averageRating = 0.0,
    this.totalReviews = 0,
    this.sessionsCreated = 0,
    this.sessionsJoined = 0,
    required this.createdAt,
    required this.updatedAt,
    required this.lastLoginAt,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    DateTime parseDateTime(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is Timestamp) return value.toDate();
      if (value is String) {
        return DateTime.tryParse(value) ?? DateTime.now();
      }
      return DateTime.now();
    }

    return UserModel(
      uid: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      photoUrl: data['photoUrl'] ?? '',
      bio: data['bio'] ?? '',
      foodPreferences: List<String>.from(data['foodPreferences'] ?? []),
      isAdmin: data['isAdmin'] ?? false,
      averageRating: (data['averageRating'] ?? 0.0).toDouble(),
      totalReviews: data['totalReviews'] ?? 0,
      sessionsCreated: data['sessionsCreated'] ?? 0,
      sessionsJoined: data['sessionsJoined'] ?? 0,
      createdAt: parseDateTime(data['createdAt']),
      updatedAt: parseDateTime(data['updatedAt']),
      lastLoginAt: parseDateTime(data['lastLoginAt']),
    );
  }

  /// Konversi ke Map untuk dikirim ke Firestore.
  /// createdAt, updatedAt, lastLoginAt di-handle di service pakai FieldValue.serverTimestamp().
  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'bio': bio,
      'foodPreferences': foodPreferences,
      'isAdmin': isAdmin,
      'averageRating': averageRating,
      'totalReviews': totalReviews,
      'sessionsCreated': sessionsCreated,
      'sessionsJoined': sessionsJoined,
    };
  }

  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? photoUrl,
    String? bio,
    List<String>? foodPreferences,
    bool? isAdmin,
    double? averageRating,
    int? totalReviews,
    int? sessionsCreated,
    int? sessionsJoined,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastLoginAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      bio: bio ?? this.bio,
      foodPreferences: foodPreferences ?? this.foodPreferences,
      isAdmin: isAdmin ?? this.isAdmin,
      averageRating: averageRating ?? this.averageRating,
      totalReviews: totalReviews ?? this.totalReviews,
      sessionsCreated: sessionsCreated ?? this.sessionsCreated,
      sessionsJoined: sessionsJoined ?? this.sessionsJoined,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
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
