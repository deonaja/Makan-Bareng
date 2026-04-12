import 'package:flutter/material.dart';
import '../models/chat_message_model.dart';
import '../data/mock_data.dart';

class ChatProvider extends ChangeNotifier {
  List<ChatMessageModel> _messages = [];

  List<ChatMessageModel> get messages => _messages;

  ChatProvider() {
    loadMessages();
  }

  void loadMessages() {
    _messages = List.from(MockData.chatMessages);
    notifyListeners();
  }

  List<ChatMessageModel> getMessagesBySession(String sessionId) {
    final sessionMessages =
        _messages.where((m) => m.sessionId == sessionId).toList();
    sessionMessages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return sessionMessages;
  }

  ChatMessageModel? getLastMessage(String sessionId) {
    final sessionMessages = getMessagesBySession(sessionId);
    if (sessionMessages.isEmpty) return null;
    return sessionMessages.last;
  }

  int getUnreadCount(String sessionId, String userId) {
    return _messages
        .where((m) =>
            m.sessionId == sessionId &&
            m.senderId != userId &&
            !m.isRead)
        .length;
  }

  void sendMessage({
    required String sessionId,
    required String senderId,
    required String senderName,
    required String message,
    String senderPhotoUrl = '',
  }) {
    final newMessage = ChatMessageModel(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      sessionId: sessionId,
      senderId: senderId,
      senderName: senderName,
      senderPhotoUrl: senderPhotoUrl,
      message: message,
      timestamp: DateTime.now(),
      isRead: false,
    );
    _messages.add(newMessage);
    notifyListeners();
  }

  void markAsRead(String sessionId, String userId) {
    for (int i = 0; i < _messages.length; i++) {
      if (_messages[i].sessionId == sessionId &&
          _messages[i].senderId != userId &&
          !_messages[i].isRead) {
        _messages[i] = _messages[i].copyWith(isRead: true);
      }
    }
    notifyListeners();
  }
}
