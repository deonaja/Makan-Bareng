import 'dart:async';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../models/session_model.dart';
import 'preferences_service.dart';
import 'session_service.dart';

/// Handles local notifications for session updates.
///
/// This service is intentionally not wrapped by a Provider because it owns
/// app-level listeners and does not expose UI state.
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  static const _channelId = 'makanbareng_channel';
  static const _channelName = 'MakanBareng Notifications';
  static const _channelDescription = 'Notifikasi aktivitas sesi MakanBareng';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  final SessionService _sessionService = SessionService();
  final Map<String, StreamSubscription<SessionModel?>> _sessionSubscriptions =
      {};
  final Map<String, int> _previousParticipantCounts = {};
  final Set<String> _initializedSessions = {};

  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(initSettings);
    await _requestAndroidNotificationPermission();

    _isInitialized = true;
  }

  Future<void> showLocalNotification({
    required String title,
    required String body,
  }) async {
    // Cek apakah notifikasi diizinkan user
    final enabled = await PreferencesService().isNotificationEnabled();
    if (!enabled) return;

    if (!_isInitialized) {
      await init();
    }

    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
    );
    const details = NotificationDetails(android: androidDetails);

    await _plugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
    );
  }

  void subscribeToSessionUpdates({
    required List<SessionModel> hostedSessions,
  }) {
    final hostedSessionIds = hostedSessions.map((s) => s.sessionId).toSet();

    for (final sessionId in _sessionSubscriptions.keys.toList()) {
      if (!hostedSessionIds.contains(sessionId)) {
        _sessionSubscriptions.remove(sessionId)?.cancel();
        _previousParticipantCounts.remove(sessionId);
        _initializedSessions.remove(sessionId);
      }
    }

    for (final session in hostedSessions) {
      if (_sessionSubscriptions.containsKey(session.sessionId)) continue;

      _previousParticipantCounts[session.sessionId] =
          session.currentParticipants;
      _sessionSubscriptions[session.sessionId] = _sessionService
          .streamSessionById(session.sessionId)
          .listen(
        _handleSessionUpdate,
        // Stream dokumen sesi bisa melempar error, mis. permission-denied saat
        // user logout (Firestore rules menolak akses). Tanpa onError, error ini
        // menjadi unhandled exception dan meng-crash aplikasi. Subscription akan
        // dibersihkan via clearSubscriptions()/dispose() saat logout.
        onError: (_) {},
      );
    }
  }

  void _handleSessionUpdate(SessionModel? session) {
    if (session == null) return;

    final sessionId = session.sessionId;
    final currentCount = session.currentParticipants;
    final previousCount = _previousParticipantCounts[sessionId];

    if (!_initializedSessions.contains(sessionId)) {
      _initializedSessions.add(sessionId);
      _previousParticipantCounts[sessionId] = currentCount;
      return;
    }

    if (previousCount != null && currentCount > previousCount) {
      showLocalNotification(
        title: 'Ada yang bergabung!',
        body: 'Seseorang baru saja bergabung ke sesi "${session.title}"',
      );
    }

    _previousParticipantCounts[sessionId] = currentCount;
  }

  Future<void> _requestAndroidNotificationPermission() async {
    final androidImplementation =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidImplementation?.requestNotificationsPermission();
  }

  Future<void> dispose() async {
    for (final subscription in _sessionSubscriptions.values) {
      await subscription.cancel();
    }
    _sessionSubscriptions.clear();
    _previousParticipantCounts.clear();
    _initializedSessions.clear();
  }
}
