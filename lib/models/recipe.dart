class Recipe {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final List<String> ingredients;
  final List<String> instructions;
  final int cookingTimeMinutes;
  final int servings;
  final String userId;
  final DateTime createdAt;
  final List<String> tags;
  final String notes;
  final bool isImported;

  Recipe({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.ingredients,
    required this.instructions,
    required this.cookingTimeMinutes,
    required this.servings,
    required this.userId,
    required this.createdAt,
    required this.tags,
    this.notes = '',
    this.isImported = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'ingredients': ingredients,
      'instructions': instructions,
      'cookingTimeMinutes': cookingTimeMinutes,
      'servings': servings,
      'userId': userId,
      'createdAt': createdAt.toIso8601String(),
      'tags': tags,
      'notes': notes,
      'isImported': isImported,
    };
  }

  factory Recipe.fromMap(Map<String, dynamic> map) {
    return Recipe(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      imageUrl: map['imageUrl'],
      ingredients: List<String>.from(map['ingredients']),
      instructions: List<String>.from(map['instructions']),
      cookingTimeMinutes: map['cookingTimeMinutes'],
      servings: map['servings'],
      userId: map['userId'],
      createdAt: DateTime.parse(map['createdAt']),
      tags: List<String>.from(map['tags']),
      notes: map['notes'] ?? '',
      isImported: map['isImported'] ?? false,
    );
  }

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