import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../models/recipe.dart';
import '../../models/shopping_item.dart';
import '../../services/shopping_service.dart';
import '../../utils/app_theme.dart';
import 'add_recipe_screen.dart';

class RecipeDetailScreen extends StatefulWidget {
  final Recipe recipe;

  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Timer? _timer;
  int _remainingSeconds = 0;
  bool _isTimerRunning = false;
  bool _showCheckboxes = false;
  final Set<int> _checkedIngredients = {};
  final Set<int> _checkedInstructions = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _remainingSeconds = widget.recipe.cookingTimeMinutes * 60;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    setState(() {
      _isTimerRunning = true;
      _remainingSeconds = widget.recipe.cookingTimeMinutes * 60;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        _timer?.cancel();
        setState(() {
          _isTimerRunning = false;
        });
        _showTimerCompleteDialog();
      }
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() {
      _isTimerRunning = false;
    });
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _isTimerRunning = false;
      _remainingSeconds = widget.recipe.cookingTimeMinutes * 60;
    });
  }

  void _showTimerCompleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.alarm_on, color: AppTheme.secondary),
            const SizedBox(width: 12),
            const Text('Timer Complete!'),
          ],
        ),
        content: Text(
          '${widget.recipe.title} is ready!',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildRecipeHeader(),
                _buildTimerCard(),
                _buildTabBar(),
              ],
            ),
          ),
          _buildTabContent(),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.6),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            widget.recipe.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            widget.recipe.imageUrl.isNotEmpty
                ? Image.network(
                    widget.recipe.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        _buildPlaceholderImage(),
                  )
                : _buildPlaceholderImage(),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.edit_rounded),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddRecipeScreen(recipe: widget.recipe),
              ),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.share_rounded),
          onPressed: () {
            // TODO: Implement share functionality
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Share feature coming soon!')),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.favorite_border_rounded),
          onPressed: () {
            // TODO: Implement favorite functionality
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Favorites feature coming soon!')),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: AppTheme.primary.withOpacity(0.1),
      child: Icon(
        Icons.restaurant_menu_rounded,
        size: 120,
        color: AppTheme.primary.withOpacity(0.3),
      ),
    );
  }

  Widget _buildRecipeHeader() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.recipe.description.isNotEmpty) ...[
            Text(
              widget.recipe.description,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.textSecondary,
                    height: 1.6,
                  ),
            ),
            const SizedBox(height: 24),
          ],
          Row(
            children: [
              _buildInfoChip(
                Icons.access_time_rounded,
                '${widget.recipe.cookingTimeMinutes} min',
              ),
              const SizedBox(width: 12),
              _buildInfoChip(
                Icons.people_rounded,
                '${widget.recipe.servings} servings',
              ),
              if (widget.recipe.isImported) ...[
                const SizedBox(width: 12),
                _buildInfoChip(
                  Icons.link_rounded,
                  'Imported',
                  color: AppTheme.accent,
                ),
              ],
            ],
          ),
          if (widget.recipe.tags.isNotEmpty) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.recipe.tags
                  .map((tag) => Chip(
                        label: Text(tag),
                        backgroundColor: AppTheme.primary.withOpacity(0.1),
                        labelStyle: TextStyle(
                          color: AppTheme.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        padding: EdgeInsets.zero,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, {Color? color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: (color ?? AppTheme.primary).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 18,
            color: color ?? AppTheme.primary,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color ?? AppTheme.primary,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimerCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primary,
            AppTheme.secondary,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.timer_rounded,
                color: Colors.white,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                'Cooking Timer',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _formatTime(_remainingSeconds),
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  color: Colors.white,
                  fontSize: 56,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!_isTimerRunning) ...[
                ElevatedButton.icon(
                  onPressed: _startTimer,
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text('Start'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppTheme.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
              ] else ...[
                ElevatedButton.icon(
                  onPressed: _pauseTimer,
                  icon: const Icon(Icons.pause_rounded),
                  label: const Text('Pause'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppTheme.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
              if (_remainingSeconds != widget.recipe.cookingTimeMinutes * 60) ...[
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: _resetTimer,
                  icon: const Icon(Icons.restart_alt_rounded),
                  label: const Text('Reset'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white, width: 2),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppTheme.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: AppTheme.textSecondary,
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
        tabs: const [
          Tab(
            icon: Icon(Icons.shopping_basket_rounded),
            text: 'Ingredients',
          ),
          Tab(
            icon: Icon(Icons.format_list_numbered_rounded),
            text: 'Instructions',
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 600, // Fixed height for tab content
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildIngredientsTab(),
            _buildInstructionsTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildIngredientsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Ingredients',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _showCheckboxes = !_showCheckboxes;
                  });
                },
                icon: Icon(
                  _showCheckboxes
                      ? Icons.check_box_rounded
                      : Icons.check_box_outline_blank_rounded,
                  size: 20,
                ),
                label: Text(_showCheckboxes ? 'Hide checks' : 'Show checks'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...widget.recipe.ingredients.asMap().entries.map((entry) {
            final index = entry.key;
            final ingredient = entry.value;
            final isChecked = _checkedIngredients.contains(index);

            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: _showCheckboxes
                    ? () {
                        setState(() {
                          if (isChecked) {
                            _checkedIngredients.remove(index);
                          } else {
                            _checkedIngredients.add(index);
                          }
                        });
                      }
                    : null,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      if (_showCheckboxes) ...[
                        Icon(
                          isChecked
                              ? Icons.check_circle_rounded
                              : Icons.circle_outlined,
                          color: isChecked
                              ? AppTheme.secondary
                              : AppTheme.textSecondary,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                      ] else ...[
                        Icon(
                          Icons.fiber_manual_record,
                          size: 8,
                          color: AppTheme.primary,
                        ),
                        const SizedBox(width: 16),
                      ],
                      Expanded(
                        child: Text(
                          ingredient,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                decoration: isChecked && _showCheckboxes
                                    ? TextDecoration.lineThrough
                                    : null,
                                color: isChecked && _showCheckboxes
                                    ? AppTheme.textSecondary
                                    : AppTheme.textPrimary,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () => _addIngredientsToShoppingList(),
            icon: const Icon(Icons.add_shopping_cart_rounded),
            label: const Text('Add to Shopping List'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Instructions',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _showCheckboxes = !_showCheckboxes;
                  });
                },
                icon: Icon(
                  _showCheckboxes
                      ? Icons.check_box_rounded
                      : Icons.check_box_outline_blank_rounded,
                  size: 20,
                ),
                label: Text(_showCheckboxes ? 'Hide checks' : 'Show checks'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...widget.recipe.instructions.asMap().entries.map((entry) {
            final index = entry.key;
            final instruction = entry.value;
            final isChecked = _checkedInstructions.contains(index);

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: _showCheckboxes
                    ? () {
                        setState(() {
                          if (isChecked) {
                            _checkedInstructions.remove(index);
                          } else {
                            _checkedInstructions.add(index);
                          }
                        });
                      }
                    : null,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_showCheckboxes) ...[
                        Icon(
                          isChecked
                              ? Icons.check_circle_rounded
                              : Icons.circle_outlined,
                          color: isChecked
                              ? AppTheme.secondary
                              : AppTheme.textSecondary,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                      ] else ...[
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: TextStyle(
                                color: AppTheme.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      Expanded(
                        child: Text(
                          instruction,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                height: 1.6,
                                decoration: isChecked && _showCheckboxes
                                    ? TextDecoration.lineThrough
                                    : null,
                                color: isChecked && _showCheckboxes
                                    ? AppTheme.textSecondary
                                    : AppTheme.textPrimary,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
          if (widget.recipe.notes.isNotEmpty) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.accent.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.notes_rounded, color: AppTheme.accent),
                      const SizedBox(width: 8),
                      Text(
                        'Notes',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: AppTheme.accent,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.recipe.notes,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          height: 1.6,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _addIngredientsToShoppingList() async {
    final shoppingService = context.read<ShoppingService>();
    
    // Add each ingredient to shopping list
    int addedCount = 0;
    int updatedCount = 0;
    
    for (final ingredient in widget.recipe.ingredients) {
      final ingredientName = ingredient.trim();
      if (ingredientName.isEmpty) continue;
      
      // Parse ingredient into quantity and item name
      final parsed = _parseIngredient(ingredientName);
      final baseItemName = parsed['itemName'] as String;
      final quantity = parsed['quantity'] as String;
      final unit = parsed['unit'] as String;
      
      // Check if similar item already exists (case-insensitive, comparing base item names)
      final existingItem = shoppingService.items.firstWhere(
        (item) {
          final itemParsed = _parseIngredient(item.name);
          final itemBaseName = itemParsed['itemName'] as String;
          return itemBaseName.toLowerCase() == baseItemName.toLowerCase();
        },
        orElse: () => ShoppingItem(
          id: '',
          name: '',
          category: Category.other,
          userId: 'local',
        ),
      );
      
      if (existingItem.id.isEmpty) {
        // Create new shopping item
        final item = ShoppingItem(
          id: DateTime.now().millisecondsSinceEpoch.toString() + 
               ingredientName.hashCode.toString(),
          name: ingredientName,
          category: _categorizeIngredient(ingredientName),
          recipeId: widget.recipe.id,
          userId: 'local',
        );
        
        await shoppingService.addItem(item);
        addedCount++;
      } else {
        // Item exists - try to combine quantities
        final existingParsed = _parseIngredient(existingItem.name);
        final existingQuantity = existingParsed['quantity'] as String;
        final existingUnit = existingParsed['unit'] as String;
        final existingItemName = existingParsed['itemName'] as String;
        
        // Try to combine if units match
        final combined = _combineQuantities(
          existingQuantity, 
          existingUnit, 
          quantity, 
          unit,
        );
        
        if (combined != null) {
          // Update with combined quantity
          final updatedName = combined.isEmpty 
            ? existingItemName 
            : '$combined $existingItemName';
          
          final updatedItem = existingItem.copyWith(
            name: updatedName,
          );
          
          await shoppingService.updateItem(updatedItem);
          updatedCount++;
        } else {
          // Can't combine, add as separate item
          final item = ShoppingItem(
            id: DateTime.now().millisecondsSinceEpoch.toString() + 
                 ingredientName.hashCode.toString(),
            name: ingredientName,
            category: _categorizeIngredient(ingredientName),
            recipeId: widget.recipe.id,
            userId: 'local',
          );
          
          await shoppingService.addItem(item);
          addedCount++;
        }
      }
    }
    
    if (mounted) {
      String message;
      if (addedCount > 0 && updatedCount > 0) {
        message = 'Added $addedCount new, combined $updatedCount existing ingredients!';
      } else if (addedCount > 0) {
        message = 'Added $addedCount ingredient${addedCount > 1 ? 's' : ''} to shopping list!';
      } else if (updatedCount > 0) {
        message = 'Combined $updatedCount ingredient${updatedCount > 1 ? 's' : ''} with existing items!';
      } else {
        message = 'All ingredients already in shopping list';
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          backgroundColor: AppTheme.secondary,
          action: SnackBarAction(
            label: 'View',
            textColor: Colors.white,
            onPressed: () {
              // Navigate to shopping list screen
              Navigator.pop(context);
            },
          ),
        ),
      );
    }
  }
  
  Map<String, String> _parseIngredient(String ingredient) {
    // Pattern: "2 cups all-purpose flour" or "1/2 tsp salt" or "3-4 tomatoes"
    final regex = RegExp(
      r'^([\d./\-\s¼½¾⅓⅔⅛⅜⅝⅞]+)?\s*(cup|cups|tbsp|tablespoon|tablespoons|tsp|teaspoon|teaspoons|oz|ounce|ounces|lb|pound|pounds|g|gram|grams|kg|kilogram|kilograms|ml|milliliter|milliliters|l|liter|liters|clove|cloves|piece|pieces|slice|slices|can|cans|package|packages|pinch|dash)?\s*(.+)',
      caseSensitive: false,
    );
    
    final match = regex.firstMatch(ingredient.trim());
    
    if (match != null) {
      final quantity = match.group(1)?.trim() ?? '';
      final unit = match.group(2)?.trim() ?? '';
      final itemName = match.group(3)?.trim() ?? ingredient;
      
      return {
        'quantity': quantity,
        'unit': unit,
        'itemName': itemName,
      };
    }
    
    // No quantity/unit found, treat whole thing as item name
    return {
      'quantity': '',
      'unit': '',
      'itemName': ingredient.trim(),
    };
  }
  
  String? _combineQuantities(String qty1, String unit1, String qty2, String unit2) {
    // Only combine if units match (or both are empty)
    if (unit1.toLowerCase() != unit2.toLowerCase()) {
      return null;
    }
    
    // Parse quantities - handle fractions and decimals
    final num1 = _parseQuantityToDecimal(qty1);
    final num2 = _parseQuantityToDecimal(qty2);
    
    if (num1 == null || num2 == null) {
      return null; // Can't parse, don't combine
    }
    
    final total = num1 + num2;
    
    // Format result nicely
    final formatted = _formatQuantity(total);
    
    return unit1.isEmpty ? formatted : '$formatted $unit1';
  }
  
  double? _parseQuantityToDecimal(String quantity) {
    if (quantity.isEmpty) return null;
    
    final trimmed = quantity.trim();
    
    // Handle fractions with unicode characters
    final fractionMap = {
      '¼': 0.25, '½': 0.5, '¾': 0.75,
      '⅓': 0.333, '⅔': 0.667,
      '⅛': 0.125, '⅜': 0.375, '⅝': 0.625, '⅞': 0.875,
    };
    
    for (final entry in fractionMap.entries) {
      if (trimmed.contains(entry.key)) {
        final replaced = trimmed.replaceAll(entry.key, '');
        final whole = double.tryParse(replaced.trim()) ?? 0.0;
        return whole + entry.value;
      }
    }
    
    // Handle "1/2", "1/4", etc.
    if (trimmed.contains('/')) {
      final parts = trimmed.split('/');
      if (parts.length == 2) {
        final numerator = double.tryParse(parts[0].trim());
        final denominator = double.tryParse(parts[1].trim());
        if (numerator != null && denominator != null && denominator != 0) {
          return numerator / denominator;
        }
      }
      
      // Handle "1 1/2" format
      final spaceMatch = RegExp(r'(\d+)\s+(\d+)/(\d+)').firstMatch(trimmed);
      if (spaceMatch != null) {
        final whole = double.tryParse(spaceMatch.group(1) ?? '0') ?? 0;
        final numerator = double.tryParse(spaceMatch.group(2) ?? '0') ?? 0;
        final denominator = double.tryParse(spaceMatch.group(3) ?? '1') ?? 1;
        return whole + (numerator / denominator);
      }
    }
    
    // Handle ranges like "3-4" - take average
    if (trimmed.contains('-') && !trimmed.startsWith('-')) {
      final parts = trimmed.split('-');
      if (parts.length == 2) {
        final num1 = double.tryParse(parts[0].trim());
        final num2 = double.tryParse(parts[1].trim());
        if (num1 != null && num2 != null) {
          return (num1 + num2) / 2;
        }
      }
    }
    
    // Regular decimal or integer
    return double.tryParse(trimmed);
  }
  
  String _formatQuantity(double quantity) {
    // Format nicely - remove unnecessary decimals
    if (quantity == quantity.roundToDouble()) {
      return quantity.round().toString();
    }
    
    // Check if it's close to common fractions
    final fractions = {
      0.25: '¼', 0.5: '½', 0.75: '¾',
      0.333: '⅓', 0.667: '⅔',
      0.125: '⅛', 0.375: '⅜', 0.625: '⅝', 0.875: '⅞',
    };
    
    final whole = quantity.floor();
    final decimal = quantity - whole;
    
    for (final entry in fractions.entries) {
      if ((decimal - entry.key).abs() < 0.01) {
        return whole > 0 ? '$whole${entry.value}' : entry.value;
      }
    }
    
    // Format with 1-2 decimal places
    return quantity.toStringAsFixed(quantity.truncateToDouble() == quantity ? 0 : 
                                     (quantity * 10).truncateToDouble() == quantity * 10 ? 1 : 2);
  }

  Category _categorizeIngredient(String ingredient) {
    final lowerIngredient = ingredient.toLowerCase();
    
    // Produce
    if (_containsAny(lowerIngredient, [
      'lettuce', 'tomato', 'onion', 'garlic', 'potato', 'carrot', 
      'celery', 'pepper', 'broccoli', 'spinach', 'mushroom', 'cucumber',
      'avocado', 'lemon', 'lime', 'apple', 'banana', 'orange', 'berry',
      'basil', 'parsley', 'cilantro', 'mint', 'thyme', 'rosemary',
      'ginger', 'chili', 'jalapeño', 'bell pepper', 'green onion',
      'scallion', 'shallot', 'kale', 'cabbage', 'zucchini', 'squash',
    ])) {
      return Category.produce;
    }
    
    // Meat and Seafood
    if (_containsAny(lowerIngredient, [
      'chicken', 'beef', 'pork', 'lamb', 'turkey', 'duck', 'bacon',
      'sausage', 'ham', 'fish', 'salmon', 'tuna', 'shrimp', 'prawn',
      'crab', 'lobster', 'scallop', 'meat', 'steak', 'ground beef',
      'ground turkey', 'ground chicken',
    ])) {
      return Category.meatAndSeafood;
    }
    
    // Dairy and Eggs
    if (_containsAny(lowerIngredient, [
      'milk', 'cream', 'butter', 'cheese', 'yogurt', 'egg', 'mozzarella',
      'parmesan', 'cheddar', 'feta', 'ricotta', 'sour cream', 'heavy cream',
      'half and half', 'whipped cream',
    ])) {
      return Category.dairyAndEggs;
    }
    
    // Pantry (grains, oils, spices, canned goods, etc.)
    if (_containsAny(lowerIngredient, [
      'flour', 'sugar', 'salt', 'pepper', 'oil', 'olive oil', 'vegetable oil',
      'rice', 'pasta', 'bread', 'noodle', 'quinoa', 'oat', 'cereal',
      'stock', 'broth', 'sauce', 'vinegar', 'soy sauce', 'honey',
      'vanilla', 'cinnamon', 'paprika', 'cumin', 'oregano', 'bay leaf',
      'cardamom', 'coriander', 'turmeric', 'chili powder', 'cayenne',
      'baking powder', 'baking soda', 'yeast', 'cornstarch', 'cocoa',
      'chocolate', 'can', 'canned', 'jar', 'bottled', 'dried',
      'masala', 'garam masala', 'curry powder', 'spice',
    ])) {
      return Category.pantry;
    }
    
    // Default to other
    return Category.other;
  }

  bool _containsAny(String text, List<String> keywords) {
    return keywords.any((keyword) => text.contains(keyword));
  }
}

