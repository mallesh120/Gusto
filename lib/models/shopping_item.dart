enum Category {
  produce,
  meatAndSeafood,
  dairyAndEggs,
  pantry,
  other,
}

class ShoppingItem {
  final String id;
  final String name;
  final Category category;
  final bool isChecked;
  final String? recipeId;
  final String userId;

  ShoppingItem({
    required this.id,
    required this.name,
    required this.category,
    this.isChecked = false,
    this.recipeId,
    required this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category.toString(),
      'isChecked': isChecked,
      'recipeId': recipeId,
      'userId': userId,
    };
  }

  factory ShoppingItem.fromMap(Map<String, dynamic> map) {
    return ShoppingItem(
      id: map['id'],
      name: map['name'],
      category: Category.values.firstWhere(
        (e) => e.toString() == map['category'],
        orElse: () => Category.other,
      ),
      isChecked: map['isChecked'] ?? false,
      recipeId: map['recipeId'],
      userId: map['userId'],
    );
  }

  ShoppingItem copyWith({
    String? id,
    String? name,
    Category? category,
    bool? isChecked,
    String? recipeId,
    String? userId,
  }) {
    return ShoppingItem(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      isChecked: isChecked ?? this.isChecked,
      recipeId: recipeId ?? this.recipeId,
      userId: userId ?? this.userId,
    );
  }
}