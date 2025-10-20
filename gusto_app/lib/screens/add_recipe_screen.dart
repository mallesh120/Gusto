import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gusto_app/models/recipe_model.dart';
import 'package:gusto_app/services/auth_service.dart';
import 'package:gusto_app/services/firestore_service.dart';
import 'package:gusto_app/widgets/limit_reached_dialog.dart';

class AddRecipeScreen extends ConsumerStatefulWidget {
  const AddRecipeScreen({super.key});

  @override
  ConsumerState<AddRecipeScreen> createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends ConsumerState<AddRecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _cookingTimeController = TextEditingController();
  final _servingsController = TextEditingController();
  final _ingredientsController = TextEditingController();
  final _instructionsController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _cookingTimeController.dispose();
    _servingsController.dispose();
    _ingredientsController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  void _saveRecipe() async {
    if (_formKey.currentState!.validate()) {
      final user = ref.read(authServiceProvider).currentUser;
      final firestoreService = ref.read(firestoreServiceProvider);
      final canAddRecipe = await firestoreService.checkRecipeLimits(user!.uid, false);

      if (canAddRecipe) {
        final newRecipe = Recipe(
          id: '', // Firestore will generate this
          title: _titleController.text,
          imageUrl: '', // Placeholder
          cookingTime: int.parse(_cookingTimeController.text),
          servings: int.parse(_servingsController.text),
          ingredients: _ingredientsController.text
              .split('\n')
              .map((line) => Ingredient(name: line, quantity: ''))
              .toList(),
          instructions: _instructionsController.text.split('\n'),
        );
        firestoreService.addRecipe(user.uid, newRecipe);
        Navigator.pop(context);
      } else {
        showLimitReachedDialog(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Recipe'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveRecipe,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a title' : null,
              ),
              TextFormField(
                controller: _cookingTimeController,
                decoration: const InputDecoration(labelText: 'Cooking Time (minutes)'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a cooking time' : null,
              ),
              TextFormField(
                controller: _servingsController,
                decoration: const InputDecoration(labelText: 'Servings'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value!.isEmpty ? 'Please enter the number of servings' : null,
              ),
              TextFormField(
                controller: _ingredientsController,
                decoration: const InputDecoration(
                    labelText: 'Ingredients (one per line)'),
                maxLines: 10,
                validator: (value) =>
                    value!.isEmpty ? 'Please enter the ingredients' : null,
              ),
              TextFormField(
                controller: _instructionsController,
                decoration: const InputDecoration(
                    labelText: 'Instructions (one per line)'),
                maxLines: 10,
                validator: (value) =>
                    value!.isEmpty ? 'Please enter the instructions' : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
