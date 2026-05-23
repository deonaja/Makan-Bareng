import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  CollectionReference get _users => _firestore.collection('users');

  // ---------------------------------------------------------------------------
  // Auth state
  // ---------------------------------------------------------------------------

  User? getCurrentUser() => _auth.currentUser;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  // ---------------------------------------------------------------------------
  // Register dengan email & password
  // ---------------------------------------------------------------------------

  Future<UserCredential> register({
    required String email,
    required String password,
    required String name,
    List<String> foodPreferences = const [],
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await credential.user!.updateDisplayName(name);

      // Buat profil di Firestore.
      // TODO: Refactor ke UserService().createUserProfile() setelah Ihsan selesai.
      await _createUserDocument(
        uid: credential.user!.uid,
        name: name,
        email: email,
        photoUrl: _avatarUrl(name),
        foodPreferences: foodPreferences,
      );

      return credential;
    } on FirebaseAuthException catch (e) {
      throw Exception(_authErrorMessage(e));
    } catch (e) {
      throw Exception('Gagal mendaftar: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // Login dengan email & password
  // ---------------------------------------------------------------------------

  Future<UserCredential> login({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _updateLastLogin(credential.user!.uid);

      return credential;
    } on FirebaseAuthException catch (e) {
      throw Exception(_authErrorMessage(e));
    } catch (e) {
      throw Exception('Gagal masuk: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // Login dengan Google
  // ---------------------------------------------------------------------------

  Future<UserCredential> loginWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) throw Exception('Login Google dibatalkan');

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user!;

      // Kalau baru pertama kali login dengan Google, buat dokumen Firestore.
      final docSnapshot = await _users.doc(user.uid).get();
      if (!docSnapshot.exists) {
        final name = user.displayName ?? 'User';
        final photoUrl = user.photoURL ?? _avatarUrl(name);

        // TODO: Refactor ke UserService().createUserProfile() setelah Ihsan selesai.
        await _createUserDocument(
          uid: user.uid,
          name: name,
          email: user.email ?? '',
          photoUrl: photoUrl,
        );
      } else {
        await _updateLastLogin(user.uid);
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(_authErrorMessage(e));
    } catch (e) {
      throw Exception('Gagal masuk dengan Google: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // Logout
  // ---------------------------------------------------------------------------

  Future<void> logout() async {
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (e) {
      throw Exception('Gagal keluar: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // Ambil UserModel dari Firestore
  // TODO: Pindahkan ke UserService setelah Ihsan selesai implementasinya.
  // ---------------------------------------------------------------------------

  Future<UserModel?> getUserDocument(String uid) async {
    try {
      final doc = await _users.doc(uid).get();
      if (!doc.exists) return null;
      return UserModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Gagal mengambil data user: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  /// Buat dokumen user baru di Firestore dengan nilai default.
  Future<void> _createUserDocument({
    required String uid,
    required String name,
    required String email,
    required String photoUrl,
    List<String> foodPreferences = const [],
  }) async {
    await _users.doc(uid).set({
      'uid': uid,
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'bio': '',
      'foodPreferences': foodPreferences,
      'isAdmin': false,
      'averageRating': 0.0,
      'totalReviews': 0,
      'sessionsCreated': 0,
      'sessionsJoined': 0,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'lastLoginAt': FieldValue.serverTimestamp(),
    });
  }

  /// Update timestamp lastLoginAt saat login.
  Future<void> _updateLastLogin(String uid) async {
    await _users.doc(uid).update({
      'lastLoginAt': FieldValue.serverTimestamp(),
    });
  }

  /// Generate avatar URL dari nama — pengganti Firebase Storage.
  String _avatarUrl(String name) {
    final encoded = Uri.encodeComponent(name);
    return 'https://ui-avatars.com/api/?name=$encoded&background=random&size=200';
  }

  /// Terjemahkan error Firebase Auth ke pesan Bahasa Indonesia.
  String _authErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'Email sudah terdaftar';
      case 'weak-password':
        return 'Password terlalu lemah (minimal 6 karakter)';
      case 'invalid-email':
        return 'Format email tidak valid';
      case 'user-not-found':
        return 'Akun tidak ditemukan';
      case 'wrong-password':
        return 'Password salah';
      case 'invalid-credential':
        return 'Email atau password salah';
      case 'user-disabled':
        return 'Akun ini telah dinonaktifkan';
      case 'too-many-requests':
        return 'Terlalu banyak percobaan. Coba lagi nanti';
      default:
        return 'Terjadi kesalahan: ${e.message}';
    }
  }
}
