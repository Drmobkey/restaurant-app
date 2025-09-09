import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:restaurant_app/providers/restaurant_provider.dart'; // State classes ada di sini
import 'package:restaurant_app/services/api_service.dart';
import 'package:restaurant_app/models/restaurant.dart' show Restaurant; // Hanya model Restaurant
import 'restaurant_provider_test.mocks.dart';

@GenerateMocks([ApiService])
void main() {
  group('RestaurantProvider Tests', () {
    late RestaurantProvider restaurantProvider;
    late MockApiService mockApiService;

    setUp(() {
      mockApiService = MockApiService();
      restaurantProvider = RestaurantProvider(mockApiService);
    });

    test('initial state should be RestaurantListInitial', () {
      // Assert
      expect(restaurantProvider.restaurantState, isA<RestaurantListInitial>());
    });

    test('should return list of restaurants when API call is successful', () async {
      // Arrange
      final mockRestaurants = [
        Restaurant(
          id: '1',
          name: 'Test Restaurant',
          description: 'Test Description',
          pictureId: 'test.jpg',
          city: 'Test City',
          rating: 4.5,
        ),
      ];
      when(mockApiService.getRestaurants())
          .thenAnswer((_) async => mockRestaurants);

      // Act
      await restaurantProvider.fetchRestaurants();

      // Assert
      expect(restaurantProvider.restaurantState, isA<RestaurantListLoaded>());
      final loadedState = restaurantProvider.restaurantState as RestaurantListLoaded;
      expect(loadedState.restaurants, equals(mockRestaurants));
    });

    test('should return error when API call fails', () async {
      // Arrange
      when(mockApiService.getRestaurants())
          .thenThrow(Exception('Network error'));

      // Act
      await restaurantProvider.fetchRestaurants();

      // Assert
      expect(restaurantProvider.restaurantState, isA<RestaurantListError>());
      final errorState = restaurantProvider.restaurantState as RestaurantListError;
      expect(errorState.message, contains('Network error'));
    });
  });
}