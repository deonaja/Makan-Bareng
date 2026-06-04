import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/review_model.dart';
import '../services/auth_service.dart';

class UserProvider extends ChangeNotifier {
  final List<UserModel> _users = [];
  final List<ReviewModel> _reviews = [];

  // Mencegah duplikat fetch untuk uid yang sedang/sudah di-fetch
  final Set<String> _pendingFetches = {};
  final Set<String> _failedFetches = {};

  List<UserModel> get users => _users;
  List<ReviewModel> get reviews => _reviews;

  /// Kembalikan user dari cache. Jika belum ada, trigger async fetch
  /// dari Firestore — widget akan rebuild otomatis setelah data tiba.
  UserModel? getUserById(String userId) {
    if (userId.isEmpty) return null;
    try {
      return _users.firstWhere((u) => u.uid == userId);
    } catch (_) {
      _fetchIfMissing(userId);
      return null;
    }
  }

  void _fetchIfMissing(String userId) {
    if (_pendingFetches.contains(userId) || _failedFetches.contains(userId)) {
      return;
    }
    _pendingFetches.add(userId);
    AuthService().getUserDocument(userId).then((user) {
      _pendingFetches.remove(userId);
      if (user != null && !_users.any((u) => u.uid == user.uid)) {
        _users.add(user);
        notifyListeners();
      } else if (user == null) {
        _failedFetches.add(userId);
      }
    }).catchError((_) {
      _pendingFetches.remove(userId);
      _failedFetches.add(userId);
    });
  }

  /// Simpan / update user di cache (dipanggil setelah edit profil, dll.)
  void cacheUser(UserModel user) {
    final idx = _users.indexWhere((u) => u.uid == user.uid);
    if (idx >= 0) {
      _users[idx] = user;
    } else {
      _users.add(user);
    }
    _failedFetches.remove(user.uid);
    notifyListeners();
  }

  List<ReviewModel> getReviewsForUser(String userId) {
    return _reviews.where((r) => r.revieweeId == userId).toList();
  }

  List<ReviewModel> getReviewsByUser(String userId) {
    return _reviews.where((r) => r.reviewerId == userId).toList();
  }

  double getAverageRating(String userId) {
    final userReviews = getReviewsForUser(userId);
    if (userReviews.isEmpty) return 0.0;
    final total = userReviews.fold(0.0, (sum, r) => sum + r.rating);
    return total / userReviews.length;
  }

  void addReview(ReviewModel review) {
    _reviews.add(review);
    notifyListeners();
  }

  void addMultipleReviews(List<ReviewModel> newReviews) {
    _reviews.addAll(newReviews);
    notifyListeners();
  }
}
