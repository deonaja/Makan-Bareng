import 'package:flutter/material.dart';
import '../models/chat_message_model.dart';
import '../services/chat_service.dart';

/// Provider untuk state management chat.
/// Wrap ChatService sesuai SPEC Section 8.5.
/// Widget pakai `context.watch<ChatProvider>()` untuk rebuild otomatis.
class ChatProvider extends ChangeNotifier {
  final ChatService _chatService = ChatService();

  // Loading & error state
  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Stream messages untuk session tertentu (expose stream dari service)
  /// Digunakan oleh StreamBuilder di widget
  Stream<List<ChatMessageModel>> streamMessages(String sessionId) {
    return _chatService.streamMessages(sessionId);
  }

  /// Stream pesan terakhir (untuk chat list preview)
  Stream<ChatMessageModel?> streamLastMessage(String sessionId) {
    return _chatService.streamLastMessage(sessionId);
  }

  /// Stream unread count
  Stream<int> streamUnreadCount(String sessionId, String userId) {
    return _chatService.streamUnreadCount(sessionId, userId);
  }

  /// Kirim pesan text
  /// Section 8.5: one-shot operation, tapi tetap lewat provider biar UI consistent
  Future<void> sendMessage({
    required String sessionId,
    required String senderId,
    required String senderName,
    required String senderPhotoUrl,
    required String text,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _chatService.sendMessage(
        sessionId: sessionId,
        senderId: senderId,
        senderName: senderName,
        senderPhotoUrl: senderPhotoUrl,
        text: text,
      );
      _error = null;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Kirim pesan system
  Future<void> sendSystemMessage({
    required String sessionId,
    required String text,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _chatService.sendSystemMessage(
        sessionId: sessionId,
        text: text,
      );
      _error = null;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Mark semua pesan di sesi sebagai sudah dibaca
  Future<void> markAllAsRead({
    required String sessionId,
    required String userId,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _chatService.markAllAsRead(
        sessionId: sessionId,
        userId: userId,
      );
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
