import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/restaurant_service.dart';

class RestaurantProvider with ChangeNotifier {
  final RestaurantService _restaurantService = RestaurantService();

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Stream semua restoran (untuk list di admin dashboard)
  Stream<QuerySnapshot> getRestaurantsStream() {
    return _restaurantService.getRestaurants();
  }

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
    _isLoading = true;
    notifyListeners();

    try {
      await _restaurantService.addRestaurant(
        name: name,
        description: description,
        address: address,
        latitude: latitude,
        longitude: longitude,
        categories: categories,
        priceRange: priceRange,
        imageUrl: imageUrl,
        createdBy: createdBy,
      );
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update restoran
  Future<void> updateRestaurant(String restaurantId, Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _restaurantService.updateRestaurant(restaurantId, data);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Hapus restoran
  Future<void> deleteRestaurant(String restaurantId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _restaurantService.deleteRestaurant(restaurantId);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
