import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_message_model.dart';

/// Service untuk chat messages via Firestore subcollection
/// Mengikuti SPEC Section 8 (Service Layer Pattern) dan Section 5.5 (messages schema)
///
/// Path: sessions/{sessionId}/messages/{messageId}
/// Semua Firebase call HANYA di sini (Section 12 DO's)
class ChatService {
  // Singleton pattern (Section 8.3 rule 1)
  static final ChatService _instance = ChatService._internal();
  factory ChatService() => _instance;
  ChatService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Helper: reference ke subcollection messages di bawah session tertentu
  CollectionReference _messagesRef(String sessionId) =>
      _firestore.collection('sessions').doc(sessionId).collection('messages');

  /// Kirim pesan text ke chat sesi
  /// Section 8.3: async, try-catch, FieldValue.serverTimestamp()
  Future<void> sendMessage({
    required String sessionId,
    required String senderId,
    required String senderName,
    required String senderPhotoUrl,
    required String text,
  }) async {
    try {
      final docRef = await _messagesRef(sessionId).add({
        'senderId': senderId,
        'senderName': senderName,
        'senderPhotoUrl': senderPhotoUrl,
        'text': text,
        'type': 'text',
        'sentAt': FieldValue.serverTimestamp(),
        'readBy': [senderId], // Sender otomatis sudah baca
      });

      // Update messageId field jadi sama dengan document ID
      await docRef.update({'messageId': docRef.id});
    } catch (e) {
      throw Exception('Gagal mengirim pesan: $e');
    }
  }

  /// Kirim pesan system (contoh: "Deon bergabung ke sesi")
  /// senderId = "system" untuk pesan otomatis (Section 5.5)
  Future<void> sendSystemMessage({
    required String sessionId,
    required String text,
  }) async {
    try {
      final docRef = await _messagesRef(sessionId).add({
        'senderId': 'system',
        'senderName': 'System',
        'senderPhotoUrl': '',
        'text': text,
        'type': 'system',
        'sentAt': FieldValue.serverTimestamp(),
        'readBy': [],
      });

      await docRef.update({'messageId': docRef.id});
    } catch (e) {
      throw Exception('Gagal mengirim pesan system: $e');
    }
  }

  /// Stream chat messages per sesi, urut by sentAt (realtime)
  /// Section 5.5: orderBy('sentAt', descending: false).limit(50)
  /// Section 8.3: pakai Stream untuk data realtime
  Stream<List<ChatMessageModel>> streamMessages(String sessionId) {
    return _messagesRef(sessionId)
        .orderBy('sentAt', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatMessageModel.fromFirestore(doc))
            .toList());
  }

  /// Ambil pesan terakhir di sesi (untuk preview di chat list)
  Stream<ChatMessageModel?> streamLastMessage(String sessionId) {
    return _messagesRef(sessionId)
        .orderBy('sentAt', descending: true)
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return null;
      return ChatMessageModel.fromFirestore(snapshot.docs.first);
    });
  }

  /// Hitung jumlah pesan yang belum dibaca oleh userId di sesi tertentu
  Stream<int> streamUnreadCount(String sessionId, String userId) {
    return _messagesRef(sessionId)
        .orderBy('sentAt', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .where((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final readBy = List<String>.from(data['readBy'] ?? []);
              final senderId = data['senderId'] ?? '';
              return senderId != userId && !readBy.contains(userId);
            })
            .length);
  }

  /// Mark pesan sebagai sudah dibaca oleh userId
  /// Pakai FieldValue.arrayUnion (Section 12 DO's)
  Future<void> markAsRead({
    required String sessionId,
    required String messageId,
    required String userId,
  }) async {
    try {
      await _messagesRef(sessionId).doc(messageId).update({
        'readBy': FieldValue.arrayUnion([userId]),
      });
    } catch (e) {
      throw Exception('Gagal menandai pesan sudah dibaca: $e');
    }
  }

  /// Mark semua pesan di sesi sebagai sudah dibaca oleh userId
  Future<void> markAllAsRead({
    required String sessionId,
    required String userId,
  }) async {
    try {
      final snapshot = await _messagesRef(sessionId).get();
      final batch = _firestore.batch();

      for (final doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final readBy = List<String>.from(data['readBy'] ?? []);
        final senderId = data['senderId'] ?? '';

        if (senderId != userId && !readBy.contains(userId)) {
          batch.update(doc.reference, {
            'readBy': FieldValue.arrayUnion([userId]),
          });
        }
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Gagal menandai semua pesan sudah dibaca: $e');
    }
  }
}
