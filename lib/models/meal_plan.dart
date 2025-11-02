class MealPlan {
  final String id;
  final DateTime date;
  final String mealType; // breakfast, lunch, dinner
  final String recipeId;

  MealPlan({
    required this.id,
    required this.date,
    required this.mealType,
    required this.recipeId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'mealType': mealType,
      'recipeId': recipeId,
    };
  }

  factory MealPlan.fromMap(Map<String, dynamic> map) {
    return MealPlan(
      id: map['id'],
      date: DateTime.parse(map['date']),
      mealType: map['mealType'],
      recipeId: map['recipeId'],
    );
  }

  MealPlan copyWith({
    String? id,
    DateTime? date,
    String? mealType,
    String? recipeId,
  }) {
    return MealPlan(
      id: id ?? this.id,
      date: date ?? this.date,
      mealType: mealType ?? this.mealType,
      recipeId: recipeId ?? this.recipeId,
    );
  }
}
