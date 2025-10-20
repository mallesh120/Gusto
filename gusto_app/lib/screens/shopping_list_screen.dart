import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gusto_app/models/recipe_model.dart';
import 'package:gusto_app/widgets/add_item_dialog.dart';

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
        final existing = consolidated[ingredient.name]!;
        // Simple numeric consolidation - this is a basic implementation
        try {
          final existingQuantity = double.parse(existing.ingredient.quantity);
          final newQuantity = double.parse(ingredient.quantity);
          existing.ingredient.quantity =
              (existingQuantity + newQuantity).toString();
        } catch (e) {
          // Fallback for non-numeric quantities
          existing.ingredient.quantity += ', ${ingredient.quantity}';
        }
      } else {
        consolidated[ingredient.name] =
            ShoppingListItem(ingredient: Ingredient(name: ingredient.name, quantity: ingredient.quantity));
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

  void addItem(Ingredient ingredient) {
    state = [...state, ShoppingListItem(ingredient: ingredient)];
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
    final categories = shoppingList.map((item) => item.ingredient.category).toSet().toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final newItem = await showAddItemDialog(context);
              if (newItem != null) {
                ref
                    .read(shoppingListViewModelProvider.notifier)
                    .addItem(newItem);
              }
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final itemsInCategory = shoppingList
              .where((item) => item.ingredient.category == category)
              .toList();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  category,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
              ...itemsInCategory.map((item) {
                return CheckboxListTile(
                  value: item.isChecked,
                  onChanged: (value) => ref
                      .read(shoppingListViewModelProvider.notifier)
                      .toggleItem(shoppingList.indexOf(item)),
                  title: Text(
                      '${item.ingredient.quantity} ${item.ingredient.name}'),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}
