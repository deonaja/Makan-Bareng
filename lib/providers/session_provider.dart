import 'dart:async';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../models/restaurant_model.dart';
import '../models/session_model.dart';
import '../services/session_service.dart';

class SessionProvider extends ChangeNotifier {
  final SessionService _service = SessionService();

  List<SessionModel> _activeSessions = [];
  List<SessionModel> _userSessions = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  String _sortBy = 'waktu';
  double? _userLat;
  double? _userLng;

  StreamSubscription<List<SessionModel>>? _activeSessionsSub;
  StreamSubscription<List<SessionModel>>? _userSessionsSub;
  bool _disposed = false;

  List<SessionModel> get activeSessions => _activeSessions;
  List<SessionModel> get userSessions => _userSessions;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  String get sortBy => _sortBy;

  List<SessionModel> get filteredSessions {
    var list = List<SessionModel>.from(_activeSessions);

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list
          .where((s) =>
              s.title.toLowerCase().contains(q) ||
              s.locationName.toLowerCase().contains(q))
          .toList();
    }

    if (_sortBy == 'jarak' && _userLat != null && _userLng != null) {
      const calc = Distance();
      list.sort((a, b) {
        final da = calc(
          LatLng(_userLat!, _userLng!),
          LatLng(a.locationLatitude, a.locationLongitude),
        );
        final db = calc(
          LatLng(_userLat!, _userLng!),
          LatLng(b.locationLatitude, b.locationLongitude),
        );
        return da.compareTo(db);
      });
    } else {
      list.sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
    }

    return list;
  }

  Stream<List<SessionModel>> streamAllSessions() {
    return _service.streamAllSessions();
  }

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
      try {
        return _userSessions.firstWhere((s) => s.sessionId == sessionId);
      } catch (_) {
        return null;
      }
    }
  }

  List<SessionModel> getCreatedByUser(String userId) =>
      _userSessions.where((s) => s.hostId == userId).toList();

  List<SessionModel> getJoinedByUser(String userId) =>
      _userSessions.where((s) => s.hostId != userId && s.participantIds.contains(userId)).toList();

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSortBy(String value) {
    _sortBy = value;
    notifyListeners();
  }

  void setUserLocation(double lat, double lng) {
    _userLat = lat;
    _userLng = lng;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Perbaiki sesi lama yang koordinatnya masih di titik default (Danau Galau).
  /// Hanya memperbaiki sesi milik [hostId].
  Future<Map<String, int>> migrateDefaultLocations({
    required String hostId,
    required List<RestaurantModel> restaurants,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final result = await _service.migrateDefaultLocations(
        hostId: hostId,
        restaurants: restaurants,
      );
      return result;
    } catch (e) {
      _error = e.toString();
      return {'fixed': 0, 'skipped': 0};
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void notifyListeners() {
    // Guard agar stream callback yang resolve setelah dispose tidak crash.
    if (_disposed) return;
    super.notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _activeSessionsSub?.cancel();
    _userSessionsSub?.cancel();
    super.dispose();
  }
}
