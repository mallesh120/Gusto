import 'package:flutter/material.dart';
import 'package:gusto_app/models/recipe_model.dart';

class RecipeGridItem extends StatelessWidget {
  final Recipe recipe;

  const RecipeGridItem({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Image.network(
              recipe.imageUrl,
              fit: BoxFit.cover,
              // Basic error handling for images
              errorBuilder: (context, error, stackTrace) {
                return const Center(
                    child: Icon(Icons.photo, color: Colors.grey));
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              recipe.title,
              style: Theme.of(context).textTheme.titleMedium,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
