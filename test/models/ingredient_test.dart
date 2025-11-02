import 'package:flutter_test/flutter_test.dart';
import 'package:gusto/models/ingredient.dart';

void main() {
  group('Ingredient Model', () {
    test('should create ingredient with all fields', () {
      final ingredient = Ingredient(
        id: '1',
        name: 'Chicken breast',
        quantity: '500g',
        category: 'Meat',
      );

      expect(ingredient.id, '1');
      expect(ingredient.name, 'Chicken breast');
      expect(ingredient.quantity, '500g');
      expect(ingredient.category, 'Meat');
    });

    test('should convert ingredient to map', () {
      final ingredient = Ingredient(
        id: '1',
        name: 'Rice',
        quantity: '2 cups',
        category: 'Grains',
      );

      final map = ingredient.toMap();

      expect(map['id'], '1');
      expect(map['name'], 'Rice');
      expect(map['quantity'], '2 cups');
      expect(map['category'], 'Grains');
    });

    test('should create ingredient from map', () {
      final map = {
        'id': '1',
        'name': 'Tomato',
        'quantity': '3 large',
        'category': 'Vegetables',
      };

      final ingredient = Ingredient.fromMap(map);

      expect(ingredient.id, '1');
      expect(ingredient.name, 'Tomato');
      expect(ingredient.quantity, '3 large');
      expect(ingredient.category, 'Vegetables');
    });

    test('should handle empty category', () {
      final ingredient = Ingredient(
        id: '1',
        name: 'Salt',
        quantity: '1 tsp',
      );

      expect(ingredient.category, '');
    });

    test('copyWith should create new instance with updated fields', () {
      final original = Ingredient(
        id: '1',
        name: 'Sugar',
        quantity: '1 cup',
        category: 'Sweeteners',
      );

      final updated = original.copyWith(
        quantity: '2 cups',
      );

      expect(updated.id, '1');
      expect(updated.name, 'Sugar');
      expect(updated.quantity, '2 cups');
      expect(updated.category, 'Sweeteners');
    });
  });
}
