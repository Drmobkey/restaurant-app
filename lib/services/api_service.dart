import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/restaurant.dart';
import '../models/restaurant_detail.dart';

class ApiService {
  static const String baseUrl = 'https://restaurant-api.dicoding.dev';
  static const String imageUrl = 'https://restaurant-api.dicoding.dev/images';

  // Add this method to construct image URLs
  static String getImageUrl(String pictureId, {String size = 'medium'}) {
    return '$imageUrl/$size/$pictureId';
  }

  // Get all restaurants
  Future<List<Restaurant>> getRestaurants() async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/list'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> restaurantList = data['restaurants'];
        return restaurantList.map((json) => Restaurant.fromJson(json)).toList();
      } else {
        throw Exception('Gagal memuat daftar restaurant. Silakan coba lagi.');
      }
    } on SocketException {
      throw Exception(
        'Tidak ada koneksi internet. Periksa koneksi Anda dan coba lagi.',
      );
    } on HttpException {
      throw Exception(
        'Terjadi masalah dengan server. Silakan coba lagi nanti.',
      );
    } catch (e) {
      if (e.toString().contains('timeout')) {
        throw Exception('Koneksi terlalu lambat. Silakan coba lagi.');
      }
      throw Exception('Terjadi kesalahan. Silakan coba lagi.');
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
      throw Exception(
        'Tidak ada koneksi internet. Periksa koneksi Anda dan coba lagi.',
      );
    }

    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/detail/$id'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return RestaurantDetail.fromJson(data['restaurant']);
      } else if (response.statusCode == 404) {
        throw Exception('Restaurant tidak ditemukan.');
      } else {
        throw Exception('Gagal memuat detail restaurant. Silakan coba lagi.');
      }
    } on SocketException {
      throw Exception(
        'Tidak ada koneksi internet. Periksa koneksi Anda dan coba lagi.',
      );
    } on HttpException {
      throw Exception(
        'Terjadi masalah dengan server. Silakan coba lagi nanti.',
      );
    } catch (e) {
      if (e.toString().contains('timeout')) {
        throw Exception('Koneksi terlalu lambat. Silakan coba lagi.');
      }
      throw Exception('Terjadi kesalahan. Silakan coba lagi.');
    }
  }

  // Search restaurants
  Future<Map<String, dynamic>> searchRestaurants(String query) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/search?q=$query'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> restaurantList = data['restaurants'];
        return {
          'restaurants': restaurantList
              .map((json) => Restaurant.fromJson(json))
              .toList(),
          'founded': data['founded'] ?? 0,
        };
      } else {
        throw Exception('Gagal mencari restaurant. Silakan coba lagi.');
      }
    } on SocketException {
      throw Exception(
        'Tidak ada koneksi internet. Periksa koneksi Anda dan coba lagi.',
      );
    } on HttpException {
      throw Exception(
        'Terjadi masalah dengan server. Silakan coba lagi nanti.',
      );
    } catch (e) {
      if (e.toString().contains('timeout')) {
        throw Exception('Koneksi terlalu lambat. Silakan coba lagi.');
      }
      throw Exception('Terjadi kesalahan saat mencari. Silakan coba lagi.');
    }
  }

  // Add review
  Future<void> addReview(String id, String name, String review) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/review'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'id': id, 'name': name, 'review': review}),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        throw Exception('Gagal menambahkan review. Silakan coba lagi.');
      }
    } on SocketException {
      throw Exception(
        'Tidak ada koneksi internet. Periksa koneksi Anda dan coba lagi.',
      );
    } on HttpException {
      throw Exception(
        'Terjadi masalah dengan server. Silakan coba lagi nanti.',
      );
    } catch (e) {
      if (e.toString().contains('timeout')) {
        throw Exception('Koneksi terlalu lambat. Silakan coba lagi.');
      }
      throw Exception(
        'Terjadi kesalahan saat menambahkan review. Silakan coba lagi.',
      );
    }
  }
}
