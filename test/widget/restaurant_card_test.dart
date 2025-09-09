import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_app/widgets/restaurant_card.dart';
import 'package:restaurant_app/models/restaurant.dart';
import 'package:restaurant_app/providers/favorite_provider.dart';

void main() {
  group('RestaurantCard Widget Tests', () {
    late Restaurant testRestaurant;
    late FavoriteProvider favoriteProvider;

    setUp(() {
      testRestaurant = Restaurant(
        id: '1',
        name: 'Test Restaurant',
        description: 'Test Description',
        pictureId: 'test.jpg',
        city: 'Test City',
        rating: 4.5,
      );
      favoriteProvider = FavoriteProvider();
    });

    testWidgets('should display restaurant information correctly', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<FavoriteProvider>(
            create: (_) => favoriteProvider,
            child: Scaffold(
              body: RestaurantCard(restaurant: testRestaurant),
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Test Restaurant'), findsOneWidget);
      expect(find.text('Test City'), findsOneWidget);
      expect(find.text('4.5'), findsOneWidget);
      expect(find.byIcon(Icons.location_on), findsOneWidget);
      expect(find.byIcon(Icons.star), findsOneWidget);
    });

    testWidgets('should show favorite button', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<FavoriteProvider>(
            create: (_) => favoriteProvider,
            child: Scaffold(
              body: RestaurantCard(restaurant: testRestaurant),
            ),
          ),
        ),
      );

      // Wait for async operations
      await tester.pumpAndSettle();

      // Assert
      expect(find.byIcon(Icons.favorite_border), findsOneWidget);
    });
  });
}