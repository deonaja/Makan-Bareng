import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Update profil user di Firestore
  Future<void> updateUserProfile({
    required String name,
    required String bio,
    required List<String> foodPreferences,
    String? photoUrl,
  }) async {
    try {
      final uid = _auth.currentUser!.uid;

      await _firestore.collection('users').doc(uid).update({
        'name': name,
        'bio': bio,
        'foodPreferences': foodPreferences,
        'photoUrl': photoUrl ?? "https://ui-avatars.com/api/?name=$name&background=random",
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception("Gagal update profil: $e");
    }
  }

  /// Ambil data user dari Firestore
  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final uid = _auth.currentUser!.uid;
      final doc = await _firestore.collection('users').doc(uid).get();
      return doc.data();
    } catch (e) {
      throw Exception("Gagal ambil profil: $e");
    }
  }

  /// Ambil stream daftar semua user
  Stream<QuerySnapshot> getUsersStream() {
    return _firestore.collection('users').orderBy('name').snapshots();
  }

  /// Upload foto profil ke Firebase Storage
  Future<String> uploadProfilePicture(File imageFile) async {
    try {
      final uid = _auth.currentUser!.uid;
      final ext = imageFile.path.split('.').last.toLowerCase();
      final storageRef = FirebaseStorage.instance.ref().child('profile_pictures/$uid.$ext');
      
      final uploadTask = await storageRef.putFile(imageFile);
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception("Gagal mengunggah foto: $e");
    }
  }
}
