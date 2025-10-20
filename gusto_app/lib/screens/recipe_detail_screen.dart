import 'package:flutter/material.dart';
import 'package:gusto_app/models/recipe_model.dart';
import 'package:gusto_app/screens/cooking_mode_screen.dart';

class RecipeDetailScreen extends StatefulWidget {
  final Recipe recipe;

  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  late List<bool> _checkedIngredients;
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _checkedIngredients =
        List<bool>.filled(widget.recipe.ingredients.length, false);
    _notesController = TextEditingController(text: widget.recipe.notes);
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.recipe.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Image.network(
              widget.recipe.imageUrl,
              fit: BoxFit.cover,
              height: 250,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 250,
                color: Colors.grey[300],
                child: const Center(child: Icon(Icons.photo, size: 100)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.recipe.title,
                      style: Theme.of(context).textTheme.headlineLarge),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.timer_outlined, size: 16),
                      const SizedBox(width: 4),
                      Text('${widget.recipe.cookingTime} min'),
                      const SizedBox(width: 16),
                      const Icon(Icons.people_outline, size: 16),
                      const SizedBox(width: 4),
                      Text('${widget.recipe.servings} servings'),
                    ],
                  ),
                  const Divider(height: 32),
                  Text('Ingredients',
                      style: Theme.of(context).textTheme.headlineMedium),
                  ...List.generate(widget.recipe.ingredients.length, (index) {
                    final ingredient = widget.recipe.ingredients[index];
                    return CheckboxListTile(
                      value: _checkedIngredients[index],
                      onChanged: (value) {
                        setState(() {
                          _checkedIngredients[index] = value!;
                        });
                      },
                      title: Text(
                          '${ingredient.quantity} ${ingredient.name}'),
                    );
                  }),
                  const Divider(height: 32),
                  Text('Instructions',
                      style: Theme.of(context).textTheme.headlineMedium),
                  ...List.generate(widget.recipe.instructions.length, (index) {
                    return ListTile(
                      leading: CircleAvatar(child: Text('${index + 1}')),
                      title: Text(widget.recipe.instructions[index]),
                    );
                  }),
                   const Divider(height: 32),
                  Text('My Notes',
                      style: Theme.of(context).textTheme.headlineMedium),
                  TextField(
                    controller: _notesController,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      hintText: 'Add your notes here...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () {
             Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CookingModeScreen(recipe: widget.recipe),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
          ),
          child: const Text('Start Cooking', style: TextStyle(fontSize: 18)),
        ),
      ),
    );
  }
}
