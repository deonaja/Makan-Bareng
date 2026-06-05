import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/review_model.dart';
import '../data/mock_data.dart';
import '../services/user_service.dart';

class UserProvider extends ChangeNotifier {
  final UserService _userService = UserService();
  
  List<UserModel> _users = [];
  List<ReviewModel> _reviews = [];

  List<UserModel> get users => _users;
  List<ReviewModel> get reviews => _reviews;

  UserProvider() {
    _users = List.from(MockData.users);
    _reviews = List.from(MockData.reviews);
  }

  UserModel? getUserById(String userId) {
    try {
      return _users.firstWhere((u) => u.uid == userId);
    } catch (_) {
      return null;
    }
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

  Future<void> updateUserProfile({
    required UserModel user,
  }) async {
    try {
      await _userService.updateUserProfile(
        name: user.name,
        bio: user.bio,
        foodPreferences: user.foodPreferences,
        photoUrl: user.photoUrl,
      );
      // Update locally if the user is in the list
      final index = _users.indexWhere((u) => u.uid == user.uid);
      if (index != -1) {
        _users[index] = user;
        notifyListeners();
      }
    } catch (e) {
      rethrow;
    }
  }
}
