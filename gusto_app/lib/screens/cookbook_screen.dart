import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gusto_app/models/recipe_model.dart';
import 'package:gusto_app/screens/cookbook_view_model.dart';
import 'package:gusto_app/services/auth_service.dart';
import 'package:gusto_app/services/firestore_service.dart';
import 'package:gusto_app/widgets/recipe_grid_item.dart';
import 'package:gusto_app/widgets/recipe_list_item.dart';
import 'package:gusto_app/screens/add_recipe_screen.dart';

final firestoreServiceProvider =
    Provider<FirestoreService>((ref) => FirestoreService());

final recipesStreamProvider = StreamProvider.autoDispose<List<Recipe>>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  final user = ref.watch(authServiceProvider).currentUser;
  return firestoreService.getRecipes(user!.uid);
});

class CookbookScreen extends ConsumerWidget {
  const CookbookScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewType = ref.watch(cookbookViewModelProvider);
    final recipesAsyncValue = ref.watch(recipesStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cookbook'),
        actions: [
          IconButton(
            icon: Icon(viewType == CookbookViewType.grid
                ? Icons.view_list
                : Icons.view_module),
            onPressed: () =>
                ref.read(cookbookViewModelProvider.notifier).toggleViewType(),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search your recipes...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
          ),
          Expanded(
            child: recipesAsyncValue.when(
              data: (recipes) {
                if (recipes.isEmpty) {
                  return const Center(child: Text('No recipes yet!'));
                }
                return viewType == CookbookViewType.grid
                    ? RecipeGridView(recipes: recipes)
                    : RecipeListView(recipes: recipes);
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) =>
                  const Center(child: Text('Could not load recipes.')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddRecipeScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class RecipeGridView extends StatelessWidget {
  const RecipeGridView({super.key, required this.recipes});
  final List<Recipe> recipes;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
      ),
      itemCount: recipes.length,
      itemBuilder: (context, index) => RecipeGridItem(recipe: recipes[index]),
    );
  }
}

class RecipeListView extends StatelessWidget {
  const RecipeListView({super.key, required this.recipes});
  final List<Recipe> recipes;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: recipes.length,
      itemBuilder: (context, index) => RecipeListItem(recipe: recipes[index]),
    );
  }
}
