import 'package:flutter_test/flutter_test.dart';
import 'package:gusto/models/recipe.dart';

void main() {
  group('Recipe Model', () {
    test('should create recipe with all required fields', () {
      final recipe = Recipe(
        id: '123',
        title: 'Chicken Biryani',
        description: 'Aromatic rice dish',
        imageUrl: 'https://example.com/image.jpg',
        ingredients: ['rice', 'chicken', 'spices'],
        instructions: ['Cook rice', 'Cook chicken', 'Layer and cook'],
        cookingTimeMinutes: 90,
        servings: 4,
        userId: 'user123',
        tags: ['Indian', 'Rice', 'Main Course'],
        notes: 'Use basmati rice',
        isImported: false,
        createdAt: DateTime.now(),
      );

      expect(recipe.id, '123');
      expect(recipe.title, 'Chicken Biryani');
      expect(recipe.description, 'Aromatic rice dish');
      expect(recipe.ingredients.length, 3);
      expect(recipe.instructions.length, 3);
      expect(recipe.cookingTimeMinutes, 90);
      expect(recipe.servings, 4);
      expect(recipe.tags.length, 3);
      expect(recipe.isImported, false);
    });

    test('should create recipe with minimal required fields', () {
      final recipe = Recipe(
        id: '123',
        title: 'Simple Recipe',
        description: '',
        imageUrl: '',
        ingredients: [],
        instructions: [],
        cookingTimeMinutes: 0,
        servings: 0,
        userId: 'user123',
        createdAt: DateTime.now(),
        tags: [],
      );

      expect(recipe.id, '123');
      expect(recipe.title, 'Simple Recipe');
      expect(recipe.tags, isEmpty);
      expect(recipe.notes, '');
    });

    test('should convert recipe to map for Firestore', () {
      final now = DateTime.now();
      final recipe = Recipe(
        id: '123',
        title: 'Test Recipe',
        description: 'Test',
        imageUrl: 'url',
        ingredients: ['a', 'b'],
        instructions: ['1', '2'],
        cookingTimeMinutes: 30,
        servings: 2,
        userId: 'user123',
        tags: ['tag1'],
        notes: 'note',
        isImported: true,
        createdAt: now,
      );

      final map = recipe.toMap();

      expect(map['id'], '123');
      expect(map['title'], 'Test Recipe');
      expect(map['ingredients'], isA<List>());
      expect(map['instructions'], isA<List>());
      expect(map['tags'], isA<List>());
      expect(map['isImported'], true);
    });

    test('should create recipe from Firestore map', () {
      final map = {
        'id': '123',
        'title': 'Test Recipe',
        'description': 'Test desc',
        'imageUrl': 'url',
        'ingredients': ['a', 'b'],
        'instructions': ['1', '2'],
        'cookingTimeMinutes': 30,
        'servings': 4,
        'userId': 'user123',
        'tags': ['Indian'],
        'notes': 'test note',
        'isImported': false,
        'createdAt': DateTime.now().toIso8601String(),
      };

      final recipe = Recipe.fromMap(map);

      expect(recipe.id, '123');
      expect(recipe.title, 'Test Recipe');
      expect(recipe.ingredients.length, 2);
      expect(recipe.instructions.length, 2);
      expect(recipe.tags.length, 1);
      expect(recipe.isImported, false);
    });

    test('copyWith should create new instance with updated fields', () {
      final original = Recipe(
        id: '123',
        title: 'Original',
        description: 'desc',
        imageUrl: 'url',
        ingredients: [],
        instructions: [],
        cookingTimeMinutes: 30,
        servings: 4,
        userId: 'user123',
        isImported: false,
        createdAt: DateTime.now(),
        tags: [],
      );

      final updated = original.copyWith(
        title: 'Updated',
        isImported: true,
      );

      expect(updated.id, '123'); // unchanged
      expect(updated.title, 'Updated'); // changed
      expect(updated.isImported, true); // changed
      expect(updated.description, 'desc'); // unchanged
    });

    test('should handle empty lists correctly', () {
      final recipe = Recipe(
        id: '123',
        title: 'Test',
        description: '',
        imageUrl: '',
        ingredients: [],
        instructions: [],
        cookingTimeMinutes: 0,
        servings: 0,
        userId: 'user123',
        createdAt: DateTime.now(),
        tags: [],
      );

      expect(recipe.ingredients, isEmpty);
      expect(recipe.instructions, isEmpty);
      expect(recipe.tags, isEmpty);
    });
  });
}
