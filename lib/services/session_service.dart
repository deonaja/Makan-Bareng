import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/session_model.dart';
import 'chat_service.dart';

class SessionService {
  static final SessionService _instance = SessionService._internal();
  factory SessionService() => _instance;
  SessionService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  CollectionReference get _sessions => _firestore.collection('sessions');

  Future<String> createSession({
    required String title,
    required String description,
    required String hostId,
    required String hostName,
    required String hostPhotoUrl,
    required String locationName,
    required String locationAddress,
    required double locationLatitude,
    required double locationLongitude,
    required DateTime scheduledAt,
    required int maxParticipants,
    int durationMinutes = 60,
    String coverImageUrl = '',
  }) async {
    try {
      final docRef = await _sessions.add({
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
        'currentParticipants': 1,
        'participantIds': [hostId],
        'status': 'open',
        'coverImageUrl': coverImageUrl,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'completedAt': null,
      });

      await docRef.update({'sessionId': docRef.id});

      // Buat pesan sistem pembuka agar chat grup langsung "ada"
      try {
        await ChatService().sendSystemMessage(
          sessionId: docRef.id,
          text: '🍽️ Sesi "$title" telah dibuat. Selamat datang!',
        );
      } catch (_) {
        // Non-critical — gagal buat pesan sistem tidak batalkan sesi
      }

      return docRef.id;
    } catch (e) {
      throw Exception('Gagal membuat sesi: $e');
    }
  }

  Future<SessionModel?> getSessionById(String sessionId) async {
    try {
      final doc = await _sessions.doc(sessionId).get();
      if (!doc.exists) return null;
      return SessionModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Gagal mengambil sesi: $e');
    }
  }

  /// Tidak pakai orderBy di Firestore karena butuh composite index yang
  /// belum tentu ada. Sorting dilakukan di sisi Dart.
  Stream<List<SessionModel>> streamActiveSessions() {
    return _sessions
        .where('status', whereIn: ['open', 'full'])
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs
          .map((doc) => SessionModel.fromFirestore(doc))
          .toList();
      list.sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
      return list;
    });
  }

  Stream<List<SessionModel>> streamUserSessions(String userId) {
    return _sessions
        .where('participantIds', arrayContains: userId)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs
          .map((doc) => SessionModel.fromFirestore(doc))
          .toList();
      list.sort((a, b) => b.scheduledAt.compareTo(a.scheduledAt));
      return list;
    });
  }

  Future<void> joinSession({
    required String sessionId,
    required String userId,
  }) async {
    try {
      final sessionRef = _sessions.doc(sessionId);

      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(sessionRef);
        if (!snapshot.exists) throw Exception('Sesi tidak ditemukan');

        final data = snapshot.data() as Map<String, dynamic>;
        final List<String> participants = List<String>.from(data['participantIds']);
        final int current = data['currentParticipants'];
        final int max = data['maxParticipants'];

        if (participants.contains(userId)) {
          throw Exception('Kamu sudah bergabung di sesi ini');
        }
        if (current >= max) throw Exception('Sesi sudah penuh');

        final newCurrent = current + 1;
        transaction.update(sessionRef, {
          'participantIds': FieldValue.arrayUnion([userId]),
          'currentParticipants': newCurrent,
          'status': newCurrent >= max ? 'full' : 'open',
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });
    } catch (e) {
      throw Exception('Gagal join sesi: $e');
    }
  }

  Future<void> leaveSession({
    required String sessionId,
    required String userId,
  }) async {
    try {
      final sessionRef = _sessions.doc(sessionId);
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(sessionRef);
        if (!snapshot.exists) throw Exception('Sesi tidak ditemukan');

        final data = snapshot.data() as Map<String, dynamic>;
        final List<String> participants =
            List<String>.from(data['participantIds'] ?? []);
        if (!participants.contains(userId)) {
          throw Exception('Kamu tidak ada di sesi ini');
        }

        final int current = (data['currentParticipants'] as int?) ?? 1;
        final String currentStatus = (data['status'] as String?) ?? 'open';
        final int newCount = (current - 1).clamp(0, 9999);

        // Hanya kembalikan ke 'open' jika sebelumnya 'full'.
        // Jangan ubah status 'ongoing', 'completed', atau 'canceled'.
        final String newStatus = currentStatus == 'full' ? 'open' : currentStatus;

        transaction.update(sessionRef, {
          'participantIds': FieldValue.arrayRemove([userId]),
          'currentParticipants': newCount,
          'status': newStatus,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });
    } catch (e) {
      throw Exception('Gagal leave sesi: $e');
    }
  }

  Future<void> cancelSession(String sessionId) async {
    try {
      await _sessions.doc(sessionId).update({
        'status': 'canceled',
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Gagal cancel sesi: $e');
    }
  }

  Future<void> completeSession(String sessionId) async {
    try {
      await _sessions.doc(sessionId).update({
        'status': 'completed',
        'completedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Gagal complete sesi: $e');
    }
  }

  Stream<SessionModel?> streamSessionById(String sessionId) {
    return _sessions.doc(sessionId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return SessionModel.fromFirestore(doc);
    });
  }
}
