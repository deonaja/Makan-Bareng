import 'package:latlong2/latlong.dart';

enum SessionStatus { open, ongoing, completed, cancelled }

class SessionModel {
  final String id;
  final String creatorId;
  final String creatorName;
  final String creatorPhotoUrl;
  final String title;
  final String description;
  final String restaurantName;
  final String restaurantAddress;
  final LatLng location;
  final DateTime startTime;
  final int maxParticipants;
  final List<String> participantIds;
  final SessionStatus status;
  final bool isPublic;
  final DateTime createdAt;
  final String? category;

  const SessionModel({
    required this.id,
    required this.creatorId,
    required this.creatorName,
    this.creatorPhotoUrl = '',
    required this.title,
    this.description = '',
    required this.restaurantName,
    this.restaurantAddress = '',
    required this.location,
    required this.startTime,
    this.maxParticipants = 4,
    this.participantIds = const [],
    this.status = SessionStatus.open,
    this.isPublic = true,
    required this.createdAt,
    this.category,
  });

  int get currentParticipants => participantIds.length;
  int get availableSeats => maxParticipants - currentParticipants;
  bool get isFull => currentParticipants >= maxParticipants;

  String get statusText {
    switch (status) {
      case SessionStatus.open:
        return 'Terbuka';
      case SessionStatus.ongoing:
        return 'Berlangsung';
      case SessionStatus.completed:
        return 'Selesai';
      case SessionStatus.cancelled:
        return 'Dibatalkan';
    }
  }

  SessionModel copyWith({
    String? id,
    String? creatorId,
    String? creatorName,
    String? creatorPhotoUrl,
    String? title,
    String? description,
    String? restaurantName,
    String? restaurantAddress,
    LatLng? location,
    DateTime? startTime,
    int? maxParticipants,
    List<String>? participantIds,
    SessionStatus? status,
    bool? isPublic,
    DateTime? createdAt,
    String? category,
  }) {
    return SessionModel(
      id: id ?? this.id,
      creatorId: creatorId ?? this.creatorId,
      creatorName: creatorName ?? this.creatorName,
      creatorPhotoUrl: creatorPhotoUrl ?? this.creatorPhotoUrl,
      title: title ?? this.title,
      description: description ?? this.description,
      restaurantName: restaurantName ?? this.restaurantName,
      restaurantAddress: restaurantAddress ?? this.restaurantAddress,
      location: location ?? this.location,
      startTime: startTime ?? this.startTime,
      maxParticipants: maxParticipants ?? this.maxParticipants,
      participantIds: participantIds ?? this.participantIds,
      status: status ?? this.status,
      isPublic: isPublic ?? this.isPublic,
      createdAt: createdAt ?? this.createdAt,
      category: category ?? this.category,
    );
  }
}
