import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/restaurant_model.dart';
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
    int joinDeadlineMinutes = 30,
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
        'joinDeadlineMinutes': joinDeadlineMinutes,
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
          text: 'Sesi "$title" telah dibuat. Selamat datang!',
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

  Stream<List<SessionModel>> streamAllSessions() {
    return _sessions.snapshots().map((snapshot) {
      final list = snapshot.docs
          .map((doc) => SessionModel.fromFirestore(doc))
          .toList();
      list.sort((a, b) => b.scheduledAt.compareTo(a.scheduledAt));
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

        // Tolak join jika sudah lewat batas waktu (scheduledAt - joinDeadlineMinutes).
        final scheduledTs = data['scheduledAt'] as Timestamp?;
        final deadlineMin = (data['joinDeadlineMinutes'] ?? 30).toInt();
        if (scheduledTs != null) {
          final closeAt =
              scheduledTs.toDate().subtract(Duration(minutes: deadlineMin));
          if (DateTime.now().isAfter(closeAt)) {
            throw Exception('Pendaftaran sesi sudah ditutup');
          }
        }

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

  // -------------------------------------------------------------------------
  // One-time migration: perbaiki sesi lama yang koordinatnya masih di titik
  // default hardcoded (-6.9732, 107.6310 — "Danau Galau").
  //
  // Hanya memperbaiki sesi milik [hostId] agar tidak melanggar Firestore rules.
  // Cocokkan nama lokasi ke daftar resto preset; kalau tidak cocok, pakai
  // resto pertama (koordinat tersebut memang lokasi Warung Nasi Ampera).
  // -------------------------------------------------------------------------
  Future<Map<String, int>> migrateDefaultLocations({
    required String hostId,
    required List<RestaurantModel> restaurants,
  }) async {
    const defaultLat = -6.9732;
    const defaultLng = 107.6310;
    const tolerance = 0.0001;

    // Ambil semua sesi milik host ini
    final snapshot = await _sessions
        .where('hostId', isEqualTo: hostId)
        .get();

    int fixed = 0;
    int skipped = 0;

    final batch = _firestore.batch();

    for (final doc in snapshot.docs) {
      try {
        final data = doc.data() as Map<String, dynamic>;
        final loc = (data['location'] as Map<String, dynamic>?) ?? {};
        final lat = ((loc['latitude']) ?? 0.0).toDouble();
        final lng = ((loc['longitude']) ?? 0.0).toDouble();

        // Lewati sesi yang koordinatnya sudah benar
        final isDefault = (lat - defaultLat).abs() < tolerance &&
            (lng - defaultLng).abs() < tolerance;
        if (!isDefault) {
          skipped++;
          continue;
        }

        final rawName = ((loc['name'] ?? '') as String).toLowerCase().trim();

        // Cari kecocokan nama resto
        RestaurantModel? match;

        // Pass 1 — exact atau contains
        for (final r in restaurants) {
          final n = r.name.toLowerCase();
          if (rawName == n || rawName.contains(n) || n.contains(rawName)) {
            match = r;
            break;
          }
        }

        // Pass 2 — kata-kata kunci (min 4 huruf)
        if (match == null && rawName.isNotEmpty) {
          final words = rawName
              .split(RegExp(r'\s+'))
              .where((w) => w.length >= 4)
              .toList();
          for (final r in restaurants) {
            final n = r.name.toLowerCase();
            if (words.any((w) => n.contains(w))) {
              match = r;
              break;
            }
          }
        }

        // Fallback — resto pertama (koordinatnya memang di sana)
        match ??= restaurants.first;

        batch.update(doc.reference, {
          'location': {
            'name': match.name,
            'address': match.address,
            'latitude': match.location.latitude,
            'longitude': match.location.longitude,
          },
          'updatedAt': FieldValue.serverTimestamp(),
        });
        fixed++;
      } catch (_) {
        skipped++;
      }
    }

    if (fixed > 0) await batch.commit();
    return {'fixed': fixed, 'skipped': skipped};
  }
}
