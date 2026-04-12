import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/review_model.dart';
import '../data/mock_data.dart';

class UserProvider extends ChangeNotifier {
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
      return _users.firstWhere((u) => u.id == userId);
    } catch (_) {
      return null;
    }
  }

  List<ReviewModel> getReviewsForUser(String userId) {
    return _reviews.where((r) => r.toUserId == userId).toList();
  }

  List<ReviewModel> getReviewsByUser(String userId) {
    return _reviews.where((r) => r.fromUserId == userId).toList();
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
