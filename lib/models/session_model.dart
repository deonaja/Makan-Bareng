import 'package:cloud_firestore/cloud_firestore.dart';

class SessionModel {
  final String sessionId;
  final String title;
  final String description;

  // Host info (denormalized)
  final String hostId;
  final String hostName;
  final String hostPhotoUrl;

  // Location (selalu custom dari peta)
  final String locationName;
  final String locationAddress;
  final double locationLatitude;
  final double locationLongitude;

  // Waktu
  final DateTime scheduledAt;
  final int durationMinutes;

  // Peserta
  final int maxParticipants;
  final int currentParticipants;
  final List<String> participantIds;

  // Status & media
  final String status;
  final String coverImageUrl;

  // Timestamp
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? completedAt;

  SessionModel({
    required this.sessionId,
    required this.title,
    required this.description,
    required this.hostId,
    required this.hostName,
    required this.hostPhotoUrl,
    required this.locationName,
    required this.locationAddress,
    required this.locationLatitude,
    required this.locationLongitude,
    required this.scheduledAt,
    this.durationMinutes = 60,
    required this.maxParticipants,
    required this.currentParticipants,
    required this.participantIds,
    this.status = 'open',
    this.coverImageUrl = '',
    required this.createdAt,
    required this.updatedAt,
    this.completedAt,
  });

  factory SessionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final location = data['location'] as Map<String, dynamic>? ?? {};

    return SessionModel(
      sessionId: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      hostId: data['hostId'] ?? '',
      hostName: data['hostName'] ?? '',
      hostPhotoUrl: data['hostPhotoUrl'] ?? '',
      locationName: location['name'] ?? '',
      locationAddress: location['address'] ?? '',
      locationLatitude: (location['latitude'] ?? 0.0).toDouble(),
      locationLongitude: (location['longitude'] ?? 0.0).toDouble(),
      scheduledAt: (data['scheduledAt'] as Timestamp).toDate(),
      durationMinutes: data['durationMinutes'] ?? 60,
      maxParticipants: data['maxParticipants'] ?? 2,
      currentParticipants: data['currentParticipants'] ?? 1,
      participantIds: List<String>.from(data['participantIds'] ?? []),
      status: data['status'] ?? 'open',
      coverImageUrl: data['coverImageUrl'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      completedAt: data['completedAt'] != null
          ? (data['completedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'sessionId': sessionId,
      'title': title,
      'description': description,
      'hostId': hostId,
      'hostName': hostName,
      'hostPhotoUrl': hostPhotoUrl,
      'location': {
        'name': locationName,
        'address': locationAddress,
        'latitude': locationLatitude,
        'longitude': locationLongitude,
      },
      'scheduledAt': Timestamp.fromDate(scheduledAt),
      'durationMinutes': durationMinutes,
      'maxParticipants': maxParticipants,
      'currentParticipants': currentParticipants,
      'participantIds': participantIds,
      'status': status,
      'coverImageUrl': coverImageUrl,
    };
  }

  SessionModel copyWith({
    String? title,
    String? description,
    int? currentParticipants,
    List<String>? participantIds,
    String? status,
    DateTime? updatedAt,
    DateTime? completedAt,
  }) {
    return SessionModel(
      sessionId: sessionId,
      title: title ?? this.title,
      description: description ?? this.description,
      hostId: hostId,
      hostName: hostName,
      hostPhotoUrl: hostPhotoUrl,
      locationName: locationName,
      locationAddress: locationAddress,
      locationLatitude: locationLatitude,
      locationLongitude: locationLongitude,
      scheduledAt: scheduledAt,
      durationMinutes: durationMinutes,
      maxParticipants: maxParticipants,
      currentParticipants: currentParticipants ?? this.currentParticipants,
      participantIds: participantIds ?? this.participantIds,
      status: status ?? this.status,
      coverImageUrl: coverImageUrl,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  bool get isFull => currentParticipants >= maxParticipants;
  int get availableSeats => maxParticipants - currentParticipants;
}
