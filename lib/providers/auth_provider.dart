import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../data/mock_data.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;
  bool _isLoggedIn = false;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Mock login: accept any email that matches our users, or any valid email format
    final matchedUser = MockData.users.where((u) => u.email == email).toList();
    if (matchedUser.isNotEmpty) {
      _currentUser = matchedUser.first;
    } else {
      // Create a new user for any email
      _currentUser = UserModel(
        id: 'user_${DateTime.now().millisecondsSinceEpoch}',
        name: email.split('@').first.replaceAll('.', ' '),
        email: email,
        bio: 'Mahasiswa baru di MakanBareng!',
        foodPreferences: [],
        rating: 0.0,
        totalSessions: 0,
        sessionsCreated: 0,
        sessionsJoined: 0,
        createdAt: DateTime.now(),
      );
    }

    _isLoggedIn = true;
    _isLoading = false;
    notifyListeners();
    return true;
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    List<String> foodPreferences = const [],
  }) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));

    _currentUser = UserModel(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      email: email,
      bio: '',
      foodPreferences: foodPreferences,
      rating: 0.0,
      totalSessions: 0,
      sessionsCreated: 0,
      sessionsJoined: 0,
      createdAt: DateTime.now(),
    );

    _isLoggedIn = true;
    _isLoading = false;
    notifyListeners();
    return true;
  }

  Future<void> loginWithGoogle() async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));

    // Mock Google login - use the first user
    _currentUser = MockData.users.first;
    _isLoggedIn = true;
    _isLoading = false;
    notifyListeners();
  }

  void updateProfile(UserModel updatedUser) {
    _currentUser = updatedUser;
    notifyListeners();
  }

  void logout() {
    _currentUser = null;
    _isLoggedIn = false;
    notifyListeners();
  }
}
