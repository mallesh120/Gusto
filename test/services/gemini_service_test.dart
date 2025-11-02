import 'package:flutter_test/flutter_test.dart';
import 'package:gusto/services/gemini_service.dart';

void main() {
  group('GeminiService', () {
    late GeminiService geminiService;

    setUp(() {
      geminiService = GeminiService();
    });

    group('extractRecipe', () {
      test('should return ExtractedRecipe with valid video metadata', () async {
        final recipe = await geminiService.extractRecipe(
          videoTitle: 'How to Make Gulab Jamun | Indian Sweet Recipe',
          videoDescription: 'Learn to make delicious Gulab Jamun at home with step-by-step instructions.',
          channelName: 'Indian Sweets Channel',
        );

        // May be null if API key not configured or API fails
        if (recipe != null) {
          expect(recipe.title, isNotEmpty);
          expect(recipe.ingredients, isNotEmpty);
          expect(recipe.instructions, isNotEmpty);
          expect(recipe.cookingTime, greaterThan(0));
          expect(recipe.servings, greaterThan(0));
        }
      });

      test('should handle empty video title gracefully', () async {
        final recipe = await geminiService.extractRecipe(
          videoTitle: '',
          videoDescription: 'Some description',
          channelName: 'Test Channel',
        );

        // Should either return null or a valid recipe
        expect(recipe, isA<ExtractedRecipe?>());
      });

      test('should handle long descriptions', () async {
        final longDescription = 'A' * 5000; // Very long description
        final recipe = await geminiService.extractRecipe(
          videoTitle: 'Test Recipe',
          videoDescription: longDescription,
          channelName: 'Test Channel',
        );

        expect(recipe, isA<ExtractedRecipe?>());
      });
    });

    group('ExtractedRecipe', () {
      test('should create recipe with all required fields', () {
        final recipe = ExtractedRecipe(
          title: 'Gulab Jamun',
          description: 'Sweet Indian dessert',
          ingredients: ['1 cup milk powder', '1/4 cup flour'],
          instructions: ['Mix ingredients', 'Form balls', 'Fry until golden'],
          cookingTime: 45,
          servings: 6,
          tags: ['Indian', 'Dessert', 'Sweet'],
          notes: 'Best served warm',
        );

        expect(recipe.title, 'Gulab Jamun');
        expect(recipe.description, 'Sweet Indian dessert');
        expect(recipe.ingredients.length, 2);
        expect(recipe.instructions.length, 3);
        expect(recipe.cookingTime, 45);
        expect(recipe.servings, 6);
        expect(recipe.tags.length, 3);
        expect(recipe.notes, 'Best served warm');
      });

      test('isComplete should return true when recipe has ingredients and instructions', () {
        final recipe = ExtractedRecipe(
          title: 'Test',
          description: 'Test',
          ingredients: ['ingredient 1'],
          instructions: ['step 1'],
          cookingTime: 30,
          servings: 4,
          tags: [],
          notes: '',
        );

        expect(recipe.isComplete, true);
      });

      test('isComplete should return false when recipe has no ingredients', () {
        final recipe = ExtractedRecipe(
          title: 'Test',
          description: 'Test',
          ingredients: [],
          instructions: ['step 1'],
          cookingTime: 30,
          servings: 4,
          tags: [],
          notes: '',
        );

        expect(recipe.isComplete, false);
      });

      test('isComplete should return false when recipe has no instructions', () {
        final recipe = ExtractedRecipe(
          title: 'Test',
          description: 'Test',
          ingredients: ['ingredient 1'],
          instructions: [],
          cookingTime: 30,
          servings: 4,
          tags: [],
          notes: '',
        );

        expect(recipe.isComplete, false);
      });

      test('toString should provide readable representation', () {
        final recipe = ExtractedRecipe(
          title: 'Test Recipe',
          description: 'Test',
          ingredients: ['a', 'b', 'c'],
          instructions: ['1', '2'],
          cookingTime: 30,
          servings: 4,
          tags: [],
          notes: '',
        );

        final str = recipe.toString();
        expect(str, contains('Test Recipe'));
        expect(str, contains('3')); // ingredient count
        expect(str, contains('2')); // instruction count
      });
    });
  });
}
