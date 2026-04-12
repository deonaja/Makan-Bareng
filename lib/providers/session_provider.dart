import 'package:flutter/material.dart';
import '../models/session_model.dart';
import '../data/mock_data.dart';

class SessionProvider extends ChangeNotifier {
  List<SessionModel> _sessions = [];
  final bool _isLoading = false;

  List<SessionModel> get sessions => _sessions;
  bool get isLoading => _isLoading;

  List<SessionModel> get activeSessions =>
      _sessions.where((s) => s.status == SessionStatus.open).toList();

  List<SessionModel> get ongoingSessions =>
      _sessions.where((s) => s.status == SessionStatus.ongoing).toList();

  List<SessionModel> get completedSessions =>
      _sessions.where((s) => s.status == SessionStatus.completed).toList();

  SessionProvider() {
    loadSessions();
  }

  void loadSessions() {
    _sessions = List.from(MockData.sessions);
    notifyListeners();
  }

  List<SessionModel> getSessionsByUser(String userId) {
    return _sessions
        .where((s) =>
            s.creatorId == userId || s.participantIds.contains(userId))
        .toList();
  }

  List<SessionModel> getCreatedByUser(String userId) {
    return _sessions.where((s) => s.creatorId == userId).toList();
  }

  List<SessionModel> getJoinedByUser(String userId) {
    return _sessions
        .where((s) =>
            s.creatorId != userId && s.participantIds.contains(userId))
        .toList();
  }

  SessionModel? getSessionById(String sessionId) {
    try {
      return _sessions.firstWhere((s) => s.id == sessionId);
    } catch (_) {
      return null;
    }
  }

  void createSession(SessionModel session) {
    _sessions.insert(0, session);
    notifyListeners();
  }

  bool joinSession(String sessionId, String userId) {
    final index = _sessions.indexWhere((s) => s.id == sessionId);
    if (index == -1) return false;

    final session = _sessions[index];
    if (session.isFull || session.participantIds.contains(userId)) {
      return false;
    }

    final updatedParticipants = List<String>.from(session.participantIds)
      ..add(userId);
    _sessions[index] = session.copyWith(participantIds: updatedParticipants);
    notifyListeners();
    return true;
  }

  bool leaveSession(String sessionId, String userId) {
    final index = _sessions.indexWhere((s) => s.id == sessionId);
    if (index == -1) return false;

    final session = _sessions[index];
    if (!session.participantIds.contains(userId) ||
        session.creatorId == userId) {
      return false;
    }

    final updatedParticipants = List<String>.from(session.participantIds)
      ..remove(userId);
    _sessions[index] = session.copyWith(participantIds: updatedParticipants);
    notifyListeners();
    return true;
  }

  void updateSessionStatus(String sessionId, SessionStatus status) {
    final index = _sessions.indexWhere((s) => s.id == sessionId);
    if (index == -1) return;

    _sessions[index] = _sessions[index].copyWith(status: status);
    notifyListeners();
  }

  void cancelSession(String sessionId) {
    updateSessionStatus(sessionId, SessionStatus.cancelled);
  }
}
