import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/notification_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription<User?>? _authSubscription;
  bool _disposed = false;

  /// True setelah Firebase Auth & Firestore selesai menentukan status login
  /// pertama kali (termasuk restore sesi dari storage lokal).
  /// Splash screen menunggu flag ini sebelum navigasi agar tidak
  /// keliru mengarahkan ke LoginScreen saat user sudah pernah login.
  bool _isInitialAuthComplete = false;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _currentUser != null;
  bool get isInitialAuthComplete => _isInitialAuthComplete;
  String? get errorMessage => _errorMessage;

  AuthProvider() {
    _listenToAuthChanges();
  }

  void _listenToAuthChanges() {
    _authSubscription = _authService.authStateChanges().listen((firebaseUser) async {
      if (firebaseUser == null) {
        _currentUser = null;
        _isInitialAuthComplete = true;
        notifyListeners();
        return;
      }

      // User baru login / restore sesi — ambil dokumen Firestore-nya.
      try {
        _currentUser = await _authService.getUserDocument(firebaseUser.uid);
      } catch (_) {
        _currentUser = null;
      }
      _isInitialAuthComplete = true;
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
      // Hentikan listener notifikasi (stream dokumen sesi) SEBELUM sign-out,
      // agar Firestore tidak melempar permission-denied saat sesi auth dicabut.
      await NotificationService().dispose();
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
  void notifyListeners() {
    // Guard agar callback async (auth state listener, login future, dll.) yang
    // resolve setelah provider di-dispose tidak crash. Tanpa ini, ChangeNotifier
    // melempar "A AuthProvider was used after being disposed".
    if (_disposed) return;
    super.notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _authSubscription?.cancel();
    super.dispose();
  }
}
