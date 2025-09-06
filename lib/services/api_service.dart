import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/restaurant.dart';
import '../models/restaurant_detail.dart';

class ApiService {
  static const String baseUrl = 'https://restaurant-api.dicoding.dev';
  static const String imageUrl = 'https://restaurant-api.dicoding.dev/images';

  // Get all restaurants
  Future<List<Restaurant>> getRestaurants() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/list'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> restaurantList = data['restaurants'];
        return restaurantList.map((json) => Restaurant.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load restaurants');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Method untuk cek koneksi internet
  Future<bool> hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  // Get restaurant detail dengan pengecekan koneksi
  Future<RestaurantDetail> getRestaurantDetail(String id) async {
    // Cek koneksi internet dulu
    if (!await hasInternetConnection()) {
      throw Exception('Tidak ada koneksi internet');
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/detail/$id'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10)); // Tambahkan timeout

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return RestaurantDetail.fromJson(data['restaurant']);
      } else {
        throw Exception('Failed to load restaurant detail: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Search restaurants
  Future<Map<String, dynamic>> searchRestaurants(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/search?q=$query'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> restaurantList = data['restaurants'];
        final restaurants = restaurantList.map((json) => Restaurant.fromJson(json)).toList();
        
        return {
          'restaurants': restaurants,
          'founded': data['founded'] ?? restaurants.length,
        };
      } else {
        throw Exception('Failed to search restaurants');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Add review
  Future<void> addReview(String id, String name, String review) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/review'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'id': id,
          'name': name,
          'review': review,
        }),
      );

      if (response.statusCode != 201) {
        throw Exception('Failed to add review');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Get image URL
  static String getImageUrl(String pictureId, {String size = 'medium'}) {
    return '$imageUrl/$size/$pictureId';
  }
}