class Recipe {
  final String id;
  final String title;
  final String imageUrl;
  final int cookingTime; // in minutes
  final int servings;
  final List<Ingredient> ingredients;
  final List<String> instructions;
  final List<String> tags;
  final String notes;
  final bool isVideoRecipe;

  Recipe({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.cookingTime,
    required this.servings,
    required this.ingredients,
    required this.instructions,
    this.tags = const [],
    this.notes = '',
    this.isVideoRecipe = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'imageUrl': imageUrl,
      'cookingTime': cookingTime,
      'servings': servings,
      'ingredients': ingredients.map((i) => i.toMap()).toList(),
      'instructions': instructions,
      'tags': tags,
      'notes': notes,
      'isVideoRecipe': isVideoRecipe,
    };
  }

  factory Recipe.fromMap(Map<String, dynamic> map, String documentId) {
    return Recipe(
      id: documentId,
      title: map['title'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      cookingTime: map['cookingTime']?.toInt() ?? 0,
      servings: map['servings']?.toInt() ?? 0,
      ingredients: List<Ingredient>.from(map['ingredients']?.map((x) => Ingredient.fromMap(x))),
      instructions: List<String>.from(map['instructions']),
      tags: List<String>.from(map['tags']),
      notes: map['notes'] ?? '',
      isVideoRecipe: map['isVideoRecipe'] ?? false,
    );
  }
}

class Ingredient {
  final String name;
  String quantity;
  final String category;

  Ingredient({required this.name, required this.quantity, this.category = 'Pantry'});

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'quantity': quantity,
      'category': category,
    };
  }

  factory Ingredient.fromMap(Map<String, dynamic> map) {
    return Ingredient(
      name: map['name'] ?? '',
      quantity: map['quantity'] ?? '',
      category: map['category'] ?? 'Pantry',
    );
  }
}
