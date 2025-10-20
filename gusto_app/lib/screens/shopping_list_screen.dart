import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gusto_app/models/recipe_model.dart';

class ShoppingListItem {
  final Ingredient ingredient;
  bool isChecked;

  ShoppingListItem({required this.ingredient, this.isChecked = false});
}

class ShoppingListViewModel extends StateNotifier<List<ShoppingListItem>> {
  ShoppingListViewModel() : super([]);

  void generateList(List<Recipe> recipes) {
    final allIngredients = recipes.expand((r) => r.ingredients).toList();
    final consolidated = <String, ShoppingListItem>{};

    for (final ingredient in allIngredients) {
      if (consolidated.containsKey(ingredient.name)) {
        // For simplicity, we'll just append quantities. A more robust solution
        // would parse and add numeric quantities.
        final existing = consolidated[ingredient.name]!;
        existing.ingredient.quantity += ', ${ingredient.quantity}';
      } else {
        consolidated[ingredient.name] =
            ShoppingListItem(ingredient: ingredient);
      }
    }
    state = consolidated.values.toList();
  }

  void toggleItem(int index) {
    state[index].isChecked = !state[index].isChecked;
    final checked = state.where((item) => item.isChecked).toList();
    final unchecked = state.where((item) => !item.isChecked).toList();
    state = [...unchecked, ...checked];
  }
}

final shoppingListViewModelProvider =
    StateNotifierProvider<ShoppingListViewModel, List<ShoppingListItem>>(
  (ref) => ShoppingListViewModel(),
);

class ShoppingListScreen extends ConsumerWidget {
  const ShoppingListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shoppingList = ref.watch(shoppingListViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // TODO: Implement manual item add
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: shoppingList.length,
        itemBuilder: (context, index) {
          final item = shoppingList[index];
          return CheckboxListTile(
            value: item.isChecked,
            onChanged: (value) =>
                ref.read(shoppingListViewModelProvider.notifier).toggleItem(index),
            title: Text('${item.ingredient.quantity} ${item.ingredient.name}'),
          );
        },
      ),
    );
  }
}
