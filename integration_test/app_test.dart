import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:restaurant_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Restaurant App Integration Tests', () {
    testWidgets('complete app flow test', (tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Verify main screen loads
      expect(find.text('Restaurant App'), findsOneWidget);
      expect(find.byIcon(Icons.restaurant), findsOneWidget);

      // Wait for restaurants to load
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate to search tab
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      // Navigate to favorites tab
      await tester.tap(find.byIcon(Icons.favorite));
      await tester.pumpAndSettle();
      expect(find.text('Belum ada restoran favorit'), findsOneWidget);

      // Navigate to settings tab
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();
      expect(find.text('Pengaturan'), findsOneWidget);
      expect(find.text('Mode Gelap'), findsOneWidget);
      expect(find.text('Pengingat Harian'), findsOneWidget);

      // Test theme toggle
      await tester.tap(find.byType(Switch).first);
      await tester.pumpAndSettle();

      // Go back to restaurant list
      await tester.tap(find.byIcon(Icons.restaurant));
      await tester.pumpAndSettle();
    });
  });
}