import 'package:cloud_firestore/cloud_firestore.dart';

/// Model class untuk chat message di subcollection sessions/{sessionId}/messages
/// Mengikuti SPEC Section 5.5 dan Section 7 (Model Class Template)
class ChatMessageModel {
  final String messageId;
  final String senderId;
  final String senderName;
  final String senderPhotoUrl;
  final String text;
  final String type; // "text" | "system"
  final DateTime sentAt;
  final List<String> readBy;

  const ChatMessageModel({
    required this.messageId,
    required this.senderId,
    required this.senderName,
    this.senderPhotoUrl = '',
    required this.text,
    this.type = 'text',
    required this.sentAt,
    this.readBy = const [],
  });

  /// Konversi dari Firestore document ke ChatMessageModel
  /// Defensive dengan ?? untuk default value (Section 7.2 rule 2)
  factory ChatMessageModel.fromFirestore(DocumentSnapshot doc) {
    final data = (doc.data() as Map<String, dynamic>?) ?? const <String, dynamic>{};

    return ChatMessageModel(
      messageId: doc.id,
      senderId: data['senderId'] ?? '',
      senderName: data['senderName'] ?? '',
      senderPhotoUrl: data['senderPhotoUrl'] ?? '',
      text: data['text'] ?? '',
      type: data['type'] ?? 'text',
      sentAt: data['sentAt'] != null
          ? (data['sentAt'] as Timestamp).toDate()
          : DateTime.now(),
      readBy: List<String>.from(data['readBy'] ?? []),
    );
  }

  /// Konversi ke Map untuk dikirim ke Firestore
  /// Catatan: sentAt pakai FieldValue.serverTimestamp() di service,
  /// JANGAN di sini. (Section 7.2 rule 3)
  Map<String, dynamic> toFirestore() {
    return {
      'messageId': messageId,
      'senderId': senderId,
      'senderName': senderName,
      'senderPhotoUrl': senderPhotoUrl,
      'text': text,
      'type': type,
      'readBy': readBy,
      // sentAt di-handle di service pakai FieldValue.serverTimestamp()
    };
  }

  /// Buat copy dengan beberapa field di-override
  ChatMessageModel copyWith({
    String? messageId,
    String? senderId,
    String? senderName,
    String? senderPhotoUrl,
    String? text,
    String? type,
    DateTime? sentAt,
    List<String>? readBy,
  }) {
    return ChatMessageModel(
      messageId: messageId ?? this.messageId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderPhotoUrl: senderPhotoUrl ?? this.senderPhotoUrl,
      text: text ?? this.text,
      type: type ?? this.type,
      sentAt: sentAt ?? this.sentAt,
      readBy: readBy ?? this.readBy,
    );
  }

  @override
  String toString() {
    return 'ChatMessageModel(messageId: $messageId, senderId: $senderId, '
        'senderName: $senderName, text: $text, type: $type, sentAt: $sentAt)';
  }
}
