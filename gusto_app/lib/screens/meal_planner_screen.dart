import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gusto_app/screens/cookbook_screen.dart';
import 'package:gusto_app/models/recipe_model.dart';
import 'package:gusto_app/screens/shopping_list_screen.dart';
import 'package:gusto_app/widgets/select_recipe_dialog.dart';
import 'package:intl/intl.dart';

final selectedDateProvider = StateProvider<DateTime>((ref) => DateTime.now());
final mealPlanProvider = StateProvider<Map<DateTime, Recipe>>((ref) => ({}));

class MealPlannerScreen extends ConsumerWidget {
  const MealPlannerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);
    final weekDays = List.generate(
        7, (index) => selectedDate.add(Duration(days: index - selectedDate.weekday + 1)));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meal Plan'),
        actions: [
          TextButton.icon(
            onPressed: () {
              final recipesAsyncValue = ref.read(recipesStreamProvider);
              recipesAsyncValue.whenData((recipes) {
                if (recipes.isNotEmpty) {
                  ref.read(shoppingListViewModelProvider.notifier).generateList(recipes);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ShoppingListScreen(),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Add recipes to your cookbook first!')),
                  );
                }
              });
            },
            icon: const Text('✨'),
            label: const Text('Generate Shopping List'),
          ),
        ],
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: weekDays
                .map((day) => Text(DateFormat('EEE').format(day)))
                .toList(),
          ),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
              ),
              itemCount: 7,
              itemBuilder: (context, index) {
                final day = weekDays[index];
                final recipe = ref.watch(mealPlanProvider)[day];

                return InkWell(
                  onTap: () async {
                    final selectedRecipe = await showDialog<Recipe>(
                      context: context,
                      builder: (context) => const SelectRecipeDialog(),
                    );
                    if (selectedRecipe != null) {
                      ref
                          .read(mealPlanProvider.notifier)
                          .state = {...ref.read(mealPlanProvider), day: selectedRecipe};
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      color: selectedDate.day == day.day
                          ? Theme.of(context).primaryColor.withOpacity(0.2)
                          : Colors.transparent,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(DateFormat('d').format(day)),
                        if (recipe != null)
                          Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Text(
                              recipe.title,
                              style: Theme.of(context).textTheme.bodySmall,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
