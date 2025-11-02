import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/recipe.dart';
import '../../services/recipe_service.dart';
import '../../utils/app_theme.dart';

class AddRecipeScreen extends StatefulWidget {
  final Recipe? recipe; // If provided, edit mode

  const AddRecipeScreen({super.key, this.recipe});

  @override
  State<AddRecipeScreen> createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends State<AddRecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _cookingTimeController = TextEditingController();
  final _servingsController = TextEditingController();
  final _notesController = TextEditingController();
  
  List<String> _ingredients = [''];
  List<String> _instructions = [''];
  List<String> _tags = [];
  final _tagController = TextEditingController();

  bool _isLoading = false;
  bool get _isEditMode => widget.recipe != null;

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      _loadRecipeData();
    }
  }

  void _loadRecipeData() {
    final recipe = widget.recipe!;
    _titleController.text = recipe.title;
    _descriptionController.text = recipe.description;
    _imageUrlController.text = recipe.imageUrl;
    _cookingTimeController.text = recipe.cookingTimeMinutes.toString();
    _servingsController.text = recipe.servings.toString();
    _notesController.text = recipe.notes;
    _ingredients = recipe.ingredients.isNotEmpty ? recipe.ingredients.toList() : [''];
    _instructions = recipe.instructions.isNotEmpty ? recipe.instructions.toList() : [''];
    _tags = recipe.tags.toList();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    _cookingTimeController.dispose();
    _servingsController.dispose();
    _notesController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Recipe' : 'Add Recipe'),
        actions: [
          if (_isEditMode)
            IconButton(
              icon: const Icon(Icons.delete_rounded),
              onPressed: _confirmDelete,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildTextField(
                    controller: _titleController,
                    label: 'Recipe Title',
                    icon: Icons.title_rounded,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a title';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _descriptionController,
                    label: 'Description',
                    icon: Icons.description_rounded,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _imageUrlController,
                    label: 'Image URL',
                    icon: Icons.image_rounded,
                    keyboardType: TextInputType.url,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: _cookingTimeController,
                          label: 'Cooking Time',
                          icon: Icons.timer_rounded,
                          keyboardType: TextInputType.number,
                          suffixText: 'min',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Required';
                            }
                            if (int.tryParse(value) == null) {
                              return 'Number only';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildTextField(
                          controller: _servingsController,
                          label: 'Servings',
                          icon: Icons.people_rounded,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Required';
                            }
                            if (int.tryParse(value) == null) {
                              return 'Number only';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildSectionHeader('Ingredients'),
                  const SizedBox(height: 8),
                  ..._buildIngredientFields(),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () {
                      setState(() => _ingredients.add(''));
                    },
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Add Ingredient'),
                  ),
                  const SizedBox(height: 24),
                  _buildSectionHeader('Instructions'),
                  const SizedBox(height: 8),
                  ..._buildInstructionFields(),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () {
                      setState(() => _instructions.add(''));
                    },
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Add Step'),
                  ),
                  const SizedBox(height: 24),
                  _buildSectionHeader('Tags'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ..._tags.map((tag) => Chip(
                        label: Text(tag),
                        deleteIcon: const Icon(Icons.close_rounded, size: 18),
                        onDeleted: () {
                          setState(() => _tags.remove(tag));
                        },
                      )),
                      ActionChip(
                        avatar: const Icon(Icons.add_rounded, size: 18),
                        label: const Text('Add Tag'),
                        onPressed: _showAddTagDialog,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildTextField(
                    controller: _notesController,
                    label: 'Notes (Optional)',
                    icon: Icons.note_rounded,
                    maxLines: 4,
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: _saveRecipe,
                    icon: const Icon(Icons.save_rounded),
                    label: Text(_isEditMode ? 'Update Recipe' : 'Save Recipe'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? suffixText,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        suffixText: suffixText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: AppTheme.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildIngredientFields() {
    return List.generate(_ingredients.length, (index) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            Expanded(
              child: TextFormField(
                initialValue: _ingredients[index],
                decoration: InputDecoration(
                  labelText: 'Ingredient ${index + 1}',
                  prefixIcon: const Icon(Icons.check_circle_outline_rounded),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (value) => _ingredients[index] = value,
                validator: (value) {
                  if ((value == null || value.isEmpty) && _ingredients.length == 1) {
                    return 'At least one ingredient required';
                  }
                  return null;
                },
              ),
            ),
            if (_ingredients.length > 1) ...[
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.remove_circle_outline_rounded),
                onPressed: () {
                  setState(() => _ingredients.removeAt(index));
                },
                color: AppTheme.error,
              ),
            ],
          ],
        ),
      );
    });
  }

  List<Widget> _buildInstructionFields() {
    return List.generate(_instructions.length, (index) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextFormField(
                initialValue: _instructions[index],
                decoration: InputDecoration(
                  labelText: 'Step ${index + 1}',
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      '${index + 1}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                maxLines: 3,
                onChanged: (value) => _instructions[index] = value,
                validator: (value) {
                  if ((value == null || value.isEmpty) && _instructions.length == 1) {
                    return 'At least one instruction required';
                  }
                  return null;
                },
              ),
            ),
            if (_instructions.length > 1) ...[
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.remove_circle_outline_rounded),
                onPressed: () {
                  setState(() => _instructions.removeAt(index));
                },
                color: AppTheme.error,
              ),
            ],
          ],
        ),
      );
    });
  }

  void _showAddTagDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Tag'),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: TextField(
            controller: _tagController,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Tag name',
              hintText: 'e.g., Italian, Vegetarian, Quick',
            ),
            textCapitalization: TextCapitalization.words,
            onSubmitted: (value) {
              if (value.isNotEmpty && !_tags.contains(value)) {
                setState(() => _tags.add(value));
                _tagController.clear();
              }
              Navigator.pop(context);
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_tagController.text.isNotEmpty && !_tags.contains(_tagController.text)) {
                  setState(() => _tags.add(_tagController.text));
                  _tagController.clear();
                }
                Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveRecipe() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Remove empty ingredients and instructions
    final ingredients = _ingredients.where((i) => i.trim().isNotEmpty).toList();
    final instructions = _instructions.where((i) => i.trim().isNotEmpty).toList();

    if (ingredients.isEmpty || instructions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one ingredient and one instruction'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final service = context.read<RecipeService>();
      
      if (_isEditMode) {
        final updatedRecipe = widget.recipe!.copyWith(
          title: _titleController.text,
          description: _descriptionController.text,
          imageUrl: _imageUrlController.text,
          ingredients: ingredients,
          instructions: instructions,
          cookingTimeMinutes: int.parse(_cookingTimeController.text),
          servings: int.parse(_servingsController.text),
          tags: _tags,
          notes: _notesController.text,
        );
        await service.updateRecipe(updatedRecipe);
      } else {
        final newRecipe = Recipe(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: _titleController.text,
          description: _descriptionController.text,
          imageUrl: _imageUrlController.text,
          ingredients: ingredients,
          instructions: instructions,
          cookingTimeMinutes: int.parse(_cookingTimeController.text),
          servings: int.parse(_servingsController.text),
          userId: 'local_user', // TODO: Replace with actual user ID when auth is implemented
          createdAt: DateTime.now(),
          tags: _tags,
          notes: _notesController.text,
          isImported: false,
        );
        await service.addRecipe(newRecipe);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditMode ? 'Recipe updated!' : 'Recipe added!'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Recipe?'),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: const Text('This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.error,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed == true && mounted) {
      setState(() => _isLoading = true);
      try {
        await context.read<RecipeService>().deleteRecipe(widget.recipe!.id);
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Recipe deleted')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting: ${e.toString()}'),
              backgroundColor: AppTheme.error,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }
}
