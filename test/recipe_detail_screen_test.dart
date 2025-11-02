import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gusto/screens/home/recipe_detail_screen.dart';
import 'package:gusto/models/recipe.dart';

void main() {
  late Recipe testRecipe;

  setUp(() {
    testRecipe = Recipe(
      id: 'test-1',
      title: 'Test Recipe',
      description: 'A delicious test recipe',
      imageUrl: 'https://example.com/image.jpg',
      ingredients: [
        '1 cup flour',
        '2 eggs',
        '1/2 cup milk',
      ],
      instructions: [
        'Mix dry ingredients',
        'Add wet ingredients',
        'Bake at 350°F',
      ],
      cookingTimeMinutes: 45,
      servings: 4,
      userId: 'test-user',
      createdAt: DateTime(2025, 1, 1),
      tags: ['Test', 'Easy'],
      notes: 'This is a test note',
      isImported: false,
    );
  });

  Widget createTestWidget(Recipe recipe) {
    return MaterialApp(
      home: RecipeDetailScreen(recipe: recipe),
    );
  }

  group('RecipeDetailScreen Widget Tests', () {
    testWidgets('displays recipe title and description', (tester) async {
      await tester.pumpWidget(createTestWidget(testRecipe));
      await tester.pumpAndSettle();

      expect(find.text('Test Recipe'), findsOneWidget);
      expect(find.text('A delicious test recipe'), findsOneWidget);
    });

    testWidgets('displays recipe info chips', (tester) async {
      await tester.pumpWidget(createTestWidget(testRecipe));
      await tester.pumpAndSettle();

      expect(find.text('45 min'), findsOneWidget);
      expect(find.text('4 servings'), findsOneWidget);
    });

    testWidgets('displays recipe tags', (tester) async {
      await tester.pumpWidget(createTestWidget(testRecipe));
      await tester.pumpAndSettle();

      expect(find.text('Test'), findsOneWidget);
      expect(find.text('Easy'), findsOneWidget);
    });

    testWidgets('shows timer card with initial time', (tester) async {
      await tester.pumpWidget(createTestWidget(testRecipe));
      await tester.pumpAndSettle();

      expect(find.text('Cooking Timer'), findsOneWidget);
      expect(find.text('45:00'), findsOneWidget);
      expect(find.text('Start'), findsOneWidget);
    });

    testWidgets('has tabs for ingredients and instructions', (tester) async {
      await tester.pumpWidget(createTestWidget(testRecipe));
      await tester.pumpAndSettle();

      expect(find.text('Ingredients'), findsWidgets);
      expect(find.text('Instructions'), findsWidgets);
    });

    testWidgets('shows imported badge when recipe is imported', (tester) async {
      final importedRecipe = testRecipe.copyWith(isImported: true);
      await tester.pumpWidget(createTestWidget(importedRecipe));
      await tester.pumpAndSettle();

      expect(find.text('Imported'), findsOneWidget);
    });

    testWidgets('has share and favorite action buttons', (tester) async {
      await tester.pumpWidget(createTestWidget(testRecipe));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.share_rounded), findsOneWidget);
      expect(find.byIcon(Icons.favorite_border_rounded), findsOneWidget);
    });
  });
}

extension RecipeCopyWith on Recipe {
  Recipe copyWith({
    String? id,
    String? title,
    String? description,
    String? imageUrl,
    List<String>? ingredients,
    List<String>? instructions,
    int? cookingTimeMinutes,
    int? servings,
    String? userId,
    DateTime? createdAt,
    List<String>? tags,
    String? notes,
    bool? isImported,
  }) {
    return Recipe(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      ingredients: ingredients ?? this.ingredients,
      instructions: instructions ?? this.instructions,
      cookingTimeMinutes: cookingTimeMinutes ?? this.cookingTimeMinutes,
      servings: servings ?? this.servings,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      tags: tags ?? this.tags,
      notes: notes ?? this.notes,
      isImported: isImported ?? this.isImported,
    );
  }
}
