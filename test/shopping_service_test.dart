import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gusto/services/shopping_service.dart';
import 'package:gusto/models/shopping_item.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ShoppingService', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
    });

    test('add and persist item', () async {
      final service = ShoppingService();
      final item = ShoppingItem(
        id: '1',
        name: 'Milk',
        category: Category.dairyAndEggs,
        userId: 'local',
      );
      await service.addItem(item);
      expect(service.items.length, 1);
      expect(service.items.first.name, 'Milk');
    });

    test('toggle checked', () async {
      final service = ShoppingService();
      final item = ShoppingItem(
        id: '2',
        name: 'Eggs',
        category: Category.dairyAndEggs,
        userId: 'local',
      );
      await service.addItem(item);
      expect(service.items.first.isChecked, false);
      await service.toggleChecked('2');
      expect(service.items.first.isChecked, true);
    });
  });
}
