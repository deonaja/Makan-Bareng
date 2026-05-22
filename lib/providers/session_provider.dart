import 'dart:async';
import 'package:flutter/material.dart';
import '../models/session_model.dart';
import '../services/session_service.dart';

class SessionProvider extends ChangeNotifier {
  final SessionService _service = SessionService();

  List<SessionModel> _activeSessions = [];
  List<SessionModel> _userSessions = [];
  bool _isLoading = false;
  String? _error;

  StreamSubscription<List<SessionModel>>? _activeSessionsSub;
  StreamSubscription<List<SessionModel>>? _userSessionsSub;

  List<SessionModel> get activeSessions => _activeSessions;
  List<SessionModel> get userSessions => _userSessions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void listenActiveSessions() {
    _activeSessionsSub?.cancel();
    _activeSessionsSub = _service.streamActiveSessions().listen(
      (sessions) {
        _activeSessions = sessions;
        notifyListeners();
      },
      onError: (e) {
        _error = e.toString();
        notifyListeners();
      },
    );
  }

  void listenUserSessions(String userId) {
    _userSessionsSub?.cancel();
    _userSessionsSub = _service.streamUserSessions(userId).listen(
      (sessions) {
        _userSessions = sessions;
        notifyListeners();
      },
      onError: (e) {
        _error = e.toString();
        notifyListeners();
      },
    );
  }

  Future<String?> createSession({
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
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final sessionId = await _service.createSession(
        title: title,
        description: description,
        hostId: hostId,
        hostName: hostName,
        hostPhotoUrl: hostPhotoUrl,
        locationName: locationName,
        locationAddress: locationAddress,
        locationLatitude: locationLatitude,
        locationLongitude: locationLongitude,
        scheduledAt: scheduledAt,
        maxParticipants: maxParticipants,
        durationMinutes: durationMinutes,
        coverImageUrl: coverImageUrl,
      );
      return sessionId;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> joinSession({
    required String sessionId,
    required String userId,
  }) async {
    try {
      await _service.joinSession(sessionId: sessionId, userId: userId);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> leaveSession({
    required String sessionId,
    required String userId,
  }) async {
    try {
      await _service.leaveSession(sessionId: sessionId, userId: userId);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> cancelSession(String sessionId) async {
    try {
      await _service.cancelSession(sessionId);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> completeSession(String sessionId) async {
    try {
      await _service.completeSession(sessionId);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  SessionModel? getSessionById(String sessionId) {
    try {
      return _activeSessions.firstWhere((s) => s.sessionId == sessionId);
    } catch (_) {
      return null;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _activeSessionsSub?.cancel();
    _userSessionsSub?.cancel();
    super.dispose();
  }
}
