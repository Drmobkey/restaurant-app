import 'package:flutter/foundation.dart';
import '../models/restaurant.dart';
import '../database/database_helper.dart';

class FavoriteProvider extends ChangeNotifier {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  List<Restaurant> _favorites = [];
  bool _isLoading = false;

  List<Restaurant> get favorites => _favorites;
  bool get isLoading => _isLoading;

  Future<void> loadFavorites() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _favorites = await _databaseHelper.getFavorites();
    } catch (e) {
      debugPrint('Error loading favorites: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addFavorite(Restaurant restaurant) async {
    try {
      await _databaseHelper.insertFavorite(restaurant);
      await loadFavorites();
    } catch (e) {
      debugPrint('Error adding favorite: $e');
    }
  }

  Future<void> removeFavorite(String id) async {
    try {
      await _databaseHelper.deleteFavorite(id);
      await loadFavorites();
    } catch (e) {
      debugPrint('Error removing favorite: $e');
    }
  }

  Future<bool> isFavorite(String id) async {
    return await _databaseHelper.isFavorite(id);
  }

  Future<void> toggleFavorite(Restaurant restaurant) async {
    final isFav = await isFavorite(restaurant.id);
    if (isFav) {
      await removeFavorite(restaurant.id);
    } else {
      await addFavorite(restaurant);
    }
  }
}