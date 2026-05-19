import 'dart:async';
import 'package:flutter/material.dart';
import '../models/chat_message_model.dart';
import '../services/chat_service.dart';

/// Provider untuk state management chat.
/// Wrap ChatService sesuai SPEC Section 8.5.
/// Widget pakai `context.watch<ChatProvider>()` untuk rebuild otomatis.
class ChatProvider extends ChangeNotifier {
  final ChatService _chatService = ChatService();

  // Stream subscriptions per session untuk cleanup
  final Map<String, StreamSubscription> _subscriptions = {};

  // Cache messages per session
  final Map<String, List<ChatMessageModel>> _messagesCache = {};

  // Loading & error state
  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Ambil messages dari cache untuk session tertentu
  List<ChatMessageModel> getMessages(String sessionId) {
    return _messagesCache[sessionId] ?? [];
  }

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

  /// Subscribe ke messages stream dan update cache
  /// Panggil saat masuk chat room
  void subscribeToMessages(String sessionId) {
    // Jangan subscribe ganda
    if (_subscriptions.containsKey(sessionId)) return;

    _isLoading = true;
    notifyListeners();

    _subscriptions[sessionId] =
        _chatService.streamMessages(sessionId).listen(
      (messages) {
        _messagesCache[sessionId] = messages;
        _isLoading = false;
        _error = null;
        notifyListeners();
      },
      onError: (e) {
        _error = 'Gagal memuat pesan: $e';
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  /// Unsubscribe dari messages stream
  /// Panggil saat keluar chat room
  void unsubscribeFromMessages(String sessionId) {
    _subscriptions[sessionId]?.cancel();
    _subscriptions.remove(sessionId);
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
    try {
      await _chatService.sendMessage(
        sessionId: sessionId,
        senderId: senderId,
        senderName: senderName,
        senderPhotoUrl: senderPhotoUrl,
        text: text,
      );
      // Stream akan auto-update cache via subscription
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Kirim pesan system
  Future<void> sendSystemMessage({
    required String sessionId,
    required String text,
  }) async {
    try {
      await _chatService.sendSystemMessage(
        sessionId: sessionId,
        text: text,
      );
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Mark semua pesan di sesi sebagai sudah dibaca
  Future<void> markAllAsRead({
    required String sessionId,
    required String userId,
  }) async {
    try {
      await _chatService.markAllAsRead(
        sessionId: sessionId,
        userId: userId,
      );
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  @override
  void dispose() {
    // Cancel semua subscriptions
    for (final sub in _subscriptions.values) {
      sub.cancel();
    }
    _subscriptions.clear();
    super.dispose();
  }
}
