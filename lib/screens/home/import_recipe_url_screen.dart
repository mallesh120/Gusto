import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/recipe.dart';
import '../../services/recipe_service.dart';
import '../../utils/app_theme.dart';
import 'recipe_detail_screen.dart';

class ImportRecipeFromUrlScreen extends StatefulWidget {
  const ImportRecipeFromUrlScreen({super.key});

  @override
  State<ImportRecipeFromUrlScreen> createState() => _ImportRecipeFromUrlScreenState();
}

class _ImportRecipeFromUrlScreenState extends State<ImportRecipeFromUrlScreen> {
  final _urlController = TextEditingController();
  bool _isLoading = false;
  String? _error;
  Recipe? _parsedRecipe;

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Import from URL'),
      ),
      body: _parsedRecipe != null
          ? _buildPreview()
          : _buildUrlInput(),
    );
  }

  Widget _buildUrlInput() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline_rounded, color: AppTheme.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Paste a Recipe URL',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Supports popular recipe sites like AllRecipes, Food Network, NYT Cooking, and more.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _urlController,
            decoration: InputDecoration(
              labelText: 'Recipe URL',
              hintText: 'https://example.com/recipe',
              prefixIcon: const Icon(Icons.link_rounded),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              errorText: _error,
            ),
            keyboardType: TextInputType.url,
            autofocus: true,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _isLoading ? null : _importRecipe,
            icon: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.download_rounded),
            label: Text(_isLoading ? 'Importing...' : 'Import Recipe'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(16),
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: _importSample,
            child: const Text('Try with sample URL'),
          ),
        ],
      ),
    );
  }

  Widget _buildPreview() {
    final recipe = _parsedRecipe!;
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                      Icon(Icons.check_circle_rounded, color: AppTheme.secondary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Recipe Imported!',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              Text(
                                'Review and edit before saving',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (recipe.imageUrl.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      recipe.imageUrl,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 200,
                        color: AppTheme.surfaceVariant,
                        child: Icon(
                          Icons.image_not_supported_rounded,
                          size: 48,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                Text(
                  recipe.title,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                if (recipe.description.isNotEmpty) ...[
                  Text(
                    recipe.description,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                  ),
                  const SizedBox(height: 16),
                ],
                Row(
                  children: [
                    Icon(Icons.timer_rounded, size: 16, color: AppTheme.textSecondary),
                    const SizedBox(width: 4),
                    Text('${recipe.cookingTimeMinutes} min'),
                    const SizedBox(width: 16),
                    Icon(Icons.people_rounded, size: 16, color: AppTheme.textSecondary),
                    const SizedBox(width: 4),
                    Text('${recipe.servings} servings'),
                  ],
                ),
                const SizedBox(height: 24),
                _buildSection('Ingredients', recipe.ingredients),
                const SizedBox(height: 24),
                _buildSection('Instructions', recipe.instructions),
              ],
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _parsedRecipe = null;
                        _urlController.clear();
                        _error = null;
                      });
                    },
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _saveRecipe,
                    child: const Text('Save Recipe'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSection(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        ...items.asMap().entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title == 'Ingredients' ? '•' : '${entry.key + 1}.',
                  style: TextStyle(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(entry.value),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Future<void> _importRecipe() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) {
      setState(() => _error = 'Please enter a URL');
      return;
    }

    if (!Uri.tryParse(url)!.hasScheme) {
      setState(() => _error = 'Invalid URL');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // In a real app, you would use a backend service or web scraping library
      // For this demo, we'll simulate the import with a delay
      await Future.delayed(const Duration(seconds: 2));
      
      // Parse the recipe (simulated)
      final recipe = await _parseRecipeFromUrl(url);
      
      setState(() {
        _parsedRecipe = recipe;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to import recipe: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<Recipe> _parseRecipeFromUrl(String url) async {
    // This is a simplified simulation of recipe parsing
    // In a real app, you would:
    // 1. Fetch the HTML content from the URL
    // 2. Use a library like beautiful_soup (for Python) or html parser (for Dart)
    // 3. Extract structured data (JSON-LD, microdata, etc.)
    // 4. Parse ingredients, instructions, etc.
    
    // For demonstration purposes, return a sample recipe
    return Recipe(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'Imported: Classic Chocolate Chip Cookies',
      description: 'Delicious homemade chocolate chip cookies with a crispy edge and chewy center. Perfect for any occasion!',
      imageUrl: 'https://images.unsplash.com/photo-1499636136210-6f4ee915583e?w=800',
      ingredients: [
        '2 1/4 cups all-purpose flour',
        '1 tsp baking soda',
        '1 tsp salt',
        '1 cup (2 sticks) butter, softened',
        '3/4 cup granulated sugar',
        '3/4 cup packed brown sugar',
        '2 large eggs',
        '2 tsp vanilla extract',
        '2 cups chocolate chips',
      ],
      instructions: [
        'Preheat oven to 375°F (190°C).',
        'In a small bowl, combine flour, baking soda, and salt.',
        'In a large bowl, beat butter and both sugars until creamy.',
        'Beat in eggs and vanilla extract.',
        'Gradually blend in flour mixture.',
        'Stir in chocolate chips.',
        'Drop rounded tablespoons of dough onto ungreased baking sheets.',
        'Bake for 9-11 minutes or until golden brown.',
        'Cool on baking sheets for 2 minutes, then transfer to wire racks.',
      ],
      cookingTimeMinutes: 25,
      servings: 48,
      userId: 'local_user',
      createdAt: DateTime.now(),
      tags: ['Dessert', 'Baking', 'Cookies', 'Sweet'],
      notes: 'Imported from: $url',
      isImported: true,
    );
  }

  void _importSample() {
    _urlController.text = 'https://www.example.com/recipe/chocolate-chip-cookies';
    _importRecipe();
  }

  Future<void> _saveRecipe() async {
    if (_parsedRecipe == null) return;

    try {
      await context.read<RecipeService>().addRecipe(_parsedRecipe!);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Recipe saved successfully!')),
        );
        
        // Navigate to the recipe detail screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => RecipeDetailScreen(recipe: _parsedRecipe!),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving recipe: ${e.toString()}'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }
}
