import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gusto_app/models/recipe_model.dart';
import 'package:gusto_app/screens/cookbook_screen.dart';

class SelectRecipeDialog extends ConsumerWidget {
  const SelectRecipeDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipesAsyncValue = ref.watch(recipesStreamProvider);

    return AlertDialog(
      title: const Text('Select a Recipe'),
      content: SizedBox(
        width: double.maxFinite,
        child: recipesAsyncValue.when(
          data: (recipes) {
            if (recipes.isEmpty) {
              return const Text('You have no recipes to choose from!');
            }
            return ListView.builder(
              itemCount: recipes.length,
              itemBuilder: (context, index) {
                final recipe = recipes[index];
                return ListTile(
                  title: Text(recipe.title),
                  onTap: () {
                    Navigator.pop(context, recipe);
                  },
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) =>
              const Center(child: Text('Could not load recipes.')),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
