import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gusto/screens/home/shopping_list_screen.dart';
import 'package:gusto/services/shopping_service.dart';
import 'package:gusto/models/shopping_item.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  Widget createTestWidget(ShoppingService service) {
    return MaterialApp(
      home: ChangeNotifierProvider<ShoppingService>.value(
        value: service,
        child: const ShoppingListScreen(),
      ),
    );
  }

  group('ShoppingListScreen Widget Tests', () {
    testWidgets('shows empty state when no items', (tester) async {
      final service = ShoppingService();
      await tester.pumpWidget(createTestWidget(service));
      await tester.pumpAndSettle();

      expect(find.text('No items yet'), findsOneWidget);
      expect(find.text('Tap the + button to add your first item'), findsOneWidget);
    });

    testWidgets('displays items in list', (tester) async {
      final service = ShoppingService();
      final item = ShoppingItem(
        id: '1',
        name: 'Milk',
        category: Category.dairyAndEggs,
        userId: 'local',
      );
      await service.addItem(item);

      await tester.pumpWidget(createTestWidget(service));
      await tester.pumpAndSettle();

      expect(find.text('Milk'), findsOneWidget);
      expect(find.text('Dairy And Eggs'), findsOneWidget);
    });

    testWidgets('can toggle item checkbox', (tester) async {
      final service = ShoppingService();
      final item = ShoppingItem(
        id: '2',
        name: 'Eggs',
        category: Category.dairyAndEggs,
        userId: 'local',
      );
      await service.addItem(item);

      await tester.pumpWidget(createTestWidget(service));
      await tester.pumpAndSettle();

      final checkbox = find.byType(Checkbox);
      expect(checkbox, findsOneWidget);

      await tester.tap(checkbox);
      await tester.pumpAndSettle();

      expect(service.items.first.isChecked, true);
    });

    testWidgets('can open add dialog', (tester) async {
      final service = ShoppingService();
      await tester.pumpWidget(createTestWidget(service));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Dialog title and action buttons
      expect(find.widgetWithText(AlertDialog, 'Add Item'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Add'), findsOneWidget);
    });

    testWidgets('group by category toggle works', (tester) async {
      final service = ShoppingService();
      await service.addItem(ShoppingItem(id: '1', name: 'Milk', category: Category.dairyAndEggs, userId: 'local'));
      await service.addItem(ShoppingItem(id: '2', name: 'Apple', category: Category.produce, userId: 'local'));

      await tester.pumpWidget(createTestWidget(service));
      await tester.pumpAndSettle();

      // Find and tap the group by category button (rounded icon)
      final groupButton = find.byIcon(Icons.category_rounded);
      expect(groupButton, findsOneWidget);

      await tester.tap(groupButton);
      await tester.pumpAndSettle();

      // Should now show category headers with formatted names
      expect(find.text('Dairy And Eggs'), findsWidgets);
      expect(find.text('Produce'), findsWidgets);
    });
  });
}
