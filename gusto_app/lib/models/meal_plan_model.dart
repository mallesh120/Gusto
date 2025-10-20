class MealPlanItem {
  final String id;
  final String recipeId;
  final DateTime date;

  MealPlanItem({
    required this.id,
    required this.recipeId,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'recipeId': recipeId,
      'date': date.toIso8601String(),
    };
  }

  factory MealPlanItem.fromMap(Map<String, dynamic> map, String documentId) {
    return MealPlanItem(
      id: documentId,
      recipeId: map['recipeId'] ?? '',
      date: DateTime.parse(map['date']),
    );
  }
}
