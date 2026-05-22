import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription<User?>? _authSubscription;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _currentUser != null;
  String? get errorMessage => _errorMessage;

  AuthProvider() {
    _listenToAuthChanges();
  }

  void _listenToAuthChanges() {
    _authSubscription = _authService.authStateChanges().listen((firebaseUser) async {
      if (firebaseUser == null) {
        _currentUser = null;
        notifyListeners();
        return;
      }

      // User baru login — ambil dokumen Firestore-nya.
      try {
        _currentUser = await _authService.getUserDocument(firebaseUser.uid);
      } catch (_) {
        _currentUser = null;
      }
      notifyListeners();
    });
  }

  // ---------------------------------------------------------------------------
  // Login dengan email & password
  // ---------------------------------------------------------------------------

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _clearError();
    try {
      final credential = await _authService.login(email: email, password: password);
      // Set _currentUser langsung agar tersedia sebelum navigasi terjadi,
      // tidak menunggu stream listener yang async.
      _currentUser = await _authService.getUserDocument(credential.user!.uid);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString().replaceFirst('Exception: ', ''));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ---------------------------------------------------------------------------
  // Register dengan email & password
  // ---------------------------------------------------------------------------

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    List<String> foodPreferences = const [],
  }) async {
    _setLoading(true);
    _clearError();
    try {
      final credential = await _authService.register(
        email: email,
        password: password,
        name: name,
        foodPreferences: foodPreferences,
      );
      _currentUser = await _authService.getUserDocument(credential.user!.uid);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString().replaceFirst('Exception: ', ''));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ---------------------------------------------------------------------------
  // Login dengan Google
  // ---------------------------------------------------------------------------

  Future<void> loginWithGoogle() async {
    _setLoading(true);
    _clearError();
    try {
      final credential = await _authService.loginWithGoogle();
      _currentUser = await _authService.getUserDocument(credential.user!.uid);
      notifyListeners();
    } catch (e) {
      _setError(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      _setLoading(false);
    }
  }

  // ---------------------------------------------------------------------------
  // Logout
  // ---------------------------------------------------------------------------

  Future<void> logout() async {
    _setLoading(true);
    try {
      await _authService.logout();
      _currentUser = null;
    } catch (e) {
      _setError(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      _setLoading(false);
    }
  }

  // ---------------------------------------------------------------------------
  // Update profil lokal (dipanggil oleh UserProvider setelah edit profil)
  // ---------------------------------------------------------------------------

  void updateProfile(UserModel updatedUser) {
    _currentUser = updatedUser;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
