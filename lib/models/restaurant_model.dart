import 'package:latlong2/latlong.dart';

class RestaurantModel {
  final String id;
  final String name;
  final String address;
  final LatLng location;
  final double rating;
  final String imageUrl;
  final String category;
  final String priceRange;

  const RestaurantModel({
    required this.id,
    required this.name,
    required this.address,
    required this.location,
    this.rating = 0.0,
    this.imageUrl = '',
    this.category = '',
    this.priceRange = '',
  });
}
