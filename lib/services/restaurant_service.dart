import 'package:cloud_firestore/cloud_firestore.dart';

class RestaurantService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Tambah restoran baru
  Future<void> addRestaurant({
    required String name,
    required String description,
    required String address,
    required double latitude,
    required double longitude,
    required List<String> categories,
    required String priceRange,
    required String imageUrl,
    required String createdBy,
  }) async {
    try {
      await _firestore.collection('restaurants').add({
        'name': name,
        'description': description,
        'address': address,
        'location': {
          'latitude': latitude,
          'longitude': longitude,
        },
        'categories': categories,
        'priceRange': priceRange,
        'imageUrl': imageUrl,
        'isVerified': false,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'createdBy': createdBy,
      });
    } catch (e) {
      throw Exception("Gagal menambahkan restoran: $e");
    }
  }

  /// Ambil semua restoran
  Stream<QuerySnapshot> getRestaurants() {
    return _firestore.collection('restaurants').snapshots();
  }

  /// Update restoran
  Future<void> updateRestaurant(String restaurantId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('restaurants').doc(restaurantId).update({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception("Gagal update restoran: $e");
    }
  }

  /// Hapus restoran
  Future<void> deleteRestaurant(String restaurantId) async {
    try {
      await _firestore.collection('restaurants').doc(restaurantId).delete();
    } catch (e) {
      throw Exception("Gagal hapus restoran: $e");
    }
  }
}
