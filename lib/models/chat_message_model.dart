class ChatMessageModel {
  final String id;
  final String sessionId;
  final String senderId;
  final String senderName;
  final String senderPhotoUrl;
  final String message;
  final DateTime timestamp;
  final bool isRead;

  const ChatMessageModel({
    required this.id,
    required this.sessionId,
    required this.senderId,
    required this.senderName,
    this.senderPhotoUrl = '',
    required this.message,
    required this.timestamp,
    this.isRead = false,
  });

  ChatMessageModel copyWith({
    String? id,
    String? sessionId,
    String? senderId,
    String? senderName,
    String? senderPhotoUrl,
    String? message,
    DateTime? timestamp,
    bool? isRead,
  }) {
    return ChatMessageModel(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderPhotoUrl: senderPhotoUrl ?? this.senderPhotoUrl,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
    );
  }
}
