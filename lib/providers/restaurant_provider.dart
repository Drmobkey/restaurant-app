import 'package:flutter/material.dart';
import '../models/restaurant.dart';
import '../models/restaurant_detail.dart';
import '../services/api_service.dart';

class RestaurantProvider extends ChangeNotifier {
  final ApiService _apiService;
  
  RestaurantListState _restaurantState = RestaurantListInitial();
  RestaurantDetailState _restaurantDetailState = RestaurantDetailInitial();
  SearchState _searchState = SearchInitial();

  RestaurantProvider(this._apiService);

  RestaurantListState get restaurantState => _restaurantState;
  RestaurantDetailState get restaurantDetailState => _restaurantDetailState;
  SearchState get searchState => _searchState;

  // Fetch restaurants
  Future<void> fetchRestaurants() async {
    _restaurantState = RestaurantListLoading();
    notifyListeners();

    try {
      final restaurants = await _apiService.getRestaurants();
      _restaurantState = RestaurantListLoaded(restaurants);
    } catch (e) {
      _restaurantState = RestaurantListError(e.toString());
    }
    notifyListeners();
  }

  // Fetch restaurant detail
  Future<void> fetchRestaurantDetail(String id) async {
    print('Provider: Starting to fetch restaurant detail for ID: $id'); // Debug log
    _restaurantDetailState = RestaurantDetailLoading();
    notifyListeners();
  
    try {
      final restaurant = await _apiService.getRestaurantDetail(id)
          .timeout(const Duration(seconds: 15)); // Tambahkan timeout
      _restaurantDetailState = RestaurantDetailLoaded(restaurant);
      print('Provider: Successfully loaded restaurant detail'); // Debug log
    } catch (e) {
      print('Provider: Error loading restaurant detail: $e'); // Debug log
      _restaurantDetailState = RestaurantDetailError(e.toString());
    }
    notifyListeners();
  }

  // Search restaurants
  Future<void> searchRestaurants(String query) async {
    if (query.isEmpty) {
      _searchState = SearchInitial();
      notifyListeners();
      return;
    }

    _searchState = SearchLoading();
    notifyListeners();

    try {
      final result = await _apiService.searchRestaurants(query);
      _searchState = SearchLoaded(result['restaurants'], result['founded']);
    } catch (e) {
      _searchState = SearchError(e.toString());
    }
    notifyListeners();
  }

  // Add review
  Future<void> addReview(String id, String name, String review) async {
    try {
      await _apiService.addReview(id, name, review);
      // Refresh restaurant detail after adding review
      await fetchRestaurantDetail(id);
    } catch (e) {
      _restaurantDetailState = RestaurantDetailError(e.toString());
      notifyListeners();
    }
  }
  
  // Tambahkan method ini di RestaurantProvider
  void resetRestaurantDetailState() {
    _restaurantDetailState = RestaurantDetailInitial();
    notifyListeners();
  }
}

// Restaurant List States
abstract class RestaurantListState {
  T when<T>({
    required T Function() initial,
    required T Function() loading,
    required T Function(List<Restaurant> restaurants) success,
    required T Function(String message) error,
  }) {
    if (this is RestaurantListInitial) return initial();
    if (this is RestaurantListLoading) return loading();
    if (this is RestaurantListLoaded) return success((this as RestaurantListLoaded).restaurants);
    if (this is RestaurantListError) return error((this as RestaurantListError).message);
    throw Exception('Unknown state');
  }
}

class RestaurantListInitial extends RestaurantListState {}
class RestaurantListLoading extends RestaurantListState {}
class RestaurantListLoaded extends RestaurantListState {
  final List<Restaurant> restaurants;
  RestaurantListLoaded(this.restaurants);
}
class RestaurantListError extends RestaurantListState {
  final String message;
  RestaurantListError(this.message);
}

// Restaurant Detail States
abstract class RestaurantDetailState {
  T when<T>({
    required T Function() initial,
    required T Function() loading,
    required T Function(RestaurantDetail restaurant) success,
    required T Function(String message) error,
  }) {
    if (this is RestaurantDetailInitial) return initial();
    if (this is RestaurantDetailLoading) return loading();
    if (this is RestaurantDetailLoaded) return success((this as RestaurantDetailLoaded).restaurant);
    if (this is RestaurantDetailError) return error((this as RestaurantDetailError).message);
    throw Exception('Unknown state');
  }
}

class RestaurantDetailInitial extends RestaurantDetailState {}
class RestaurantDetailLoading extends RestaurantDetailState {}
class RestaurantDetailLoaded extends RestaurantDetailState {
  final RestaurantDetail restaurant;
  RestaurantDetailLoaded(this.restaurant);
}
class RestaurantDetailError extends RestaurantDetailState {
  final String message;
  RestaurantDetailError(this.message);
}

// Search States
abstract class SearchState {
  T when<T>({
    required T Function() initial,
    required T Function() loading,
    required T Function(List<Restaurant> restaurants) success,
    required T Function(String message) error,
  }) {
    if (this is SearchInitial) return initial();
    if (this is SearchLoading) return loading();
    if (this is SearchLoaded) return success((this as SearchLoaded).restaurants);
    if (this is SearchError) return error((this as SearchError).message);
    throw Exception('Unknown state');
  }
}

class SearchInitial extends SearchState {}
class SearchLoading extends SearchState {}
class SearchLoaded extends SearchState {
  final List<Restaurant> restaurants;
  final int founded;
  SearchLoaded(this.restaurants, this.founded);
}
class SearchError extends SearchState {
  final String message;
  SearchError(this.message);
}