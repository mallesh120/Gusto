import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/recipe.dart';
import '../../services/meal_plan_service.dart';
import '../../services/recipe_service.dart';
import '../../services/shopping_service.dart';
import '../../utils/app_theme.dart';
import 'recipe_detail_screen.dart';

class MealPlanScreen extends StatelessWidget {
  const MealPlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meal Planner'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_rounded),
            onPressed: () => _generateShoppingList(context),
            tooltip: 'Generate Shopping List',
          ),
        ],
      ),
      body: Consumer<MealPlanService>(
        builder: (context, mealPlanService, _) {
          return Column(
            children: [
              _WeekNavigator(mealPlanService: mealPlanService),
              Expanded(
                child: _WeekView(mealPlanService: mealPlanService),
              ),
            ],
          );
        },
      ),
    );
  }

  void _generateShoppingList(BuildContext context) async {
    final mealPlanService = context.read<MealPlanService>();
    final recipeService = context.read<RecipeService>();
    final shoppingService = context.read<ShoppingService>();

    final shoppingItems = mealPlanService.generateShoppingList(recipeService.recipes);
    
    if (shoppingItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No meal plans for this week. Add some recipes first!'),
        ),
      );
      return;
    }

    // Add items to shopping list
    for (final item in shoppingItems) {
      await shoppingService.addItem(item);
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Added ${shoppingItems.length} items to shopping list!'),
          action: SnackBarAction(
            label: 'View',
            onPressed: () => Navigator.pop(context),
          ),
        ),
      );
    }
  }
}

class _WeekNavigator extends StatelessWidget {
  final MealPlanService mealPlanService;

  const _WeekNavigator({required this.mealPlanService});

  @override
  Widget build(BuildContext context) {
    final weekStart = mealPlanService.selectedWeekStart;
    final weekEnd = weekStart.add(const Duration(days: 6));
    final isCurrentWeek = _isSameWeek(weekStart, DateTime.now());

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border(
          bottom: BorderSide(color: AppTheme.divider),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left_rounded),
            onPressed: mealPlanService.previousWeek,
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  '${DateFormat('MMM d').format(weekStart)} - ${DateFormat('MMM d, yyyy').format(weekEnd)}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (!isCurrentWeek) ...[
                  const SizedBox(height: 4),
                  TextButton(
                    onPressed: mealPlanService.goToCurrentWeek,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text('Go to current week'),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right_rounded),
            onPressed: mealPlanService.nextWeek,
          ),
        ],
      ),
    );
  }

  bool _isSameWeek(DateTime date1, DateTime date2) {
    final diff = date1.difference(date2).inDays;
    return diff.abs() < 7 && date1.weekday >= date2.weekday;
  }
}

class _WeekView extends StatelessWidget {
  final MealPlanService mealPlanService;

  const _WeekView({required this.mealPlanService});

  @override
  Widget build(BuildContext context) {
    final weekStart = mealPlanService.selectedWeekStart;
    final days = List.generate(7, (index) => weekStart.add(Duration(days: index)));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: days.length,
      itemBuilder: (context, index) {
        return _DayCard(
          date: days[index],
          mealPlanService: mealPlanService,
        );
      },
    );
  }
}

class _DayCard extends StatelessWidget {
  final DateTime date;
  final MealPlanService mealPlanService;

  const _DayCard({
    required this.date,
    required this.mealPlanService,
  });

  @override
  Widget build(BuildContext context) {
    final isToday = _isToday(date);
    final dayName = DateFormat('EEEE').format(date);
    final dateStr = DateFormat('MMM d').format(date);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (isToday)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'TODAY',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                if (isToday) const SizedBox(width: 8),
                Text(
                  dayName,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Spacer(),
                Text(
                  dateStr,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _MealSlot(
              date: date,
              mealType: 'breakfast',
              icon: Icons.wb_sunny_rounded,
              label: 'Breakfast',
              mealPlanService: mealPlanService,
            ),
            const SizedBox(height: 12),
            _MealSlot(
              date: date,
              mealType: 'lunch',
              icon: Icons.light_mode_rounded,
              label: 'Lunch',
              mealPlanService: mealPlanService,
            ),
            const SizedBox(height: 12),
            _MealSlot(
              date: date,
              mealType: 'dinner',
              icon: Icons.nights_stay_rounded,
              label: 'Dinner',
              mealPlanService: mealPlanService,
            ),
          ],
        ),
      ),
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }
}

class _MealSlot extends StatelessWidget {
  final DateTime date;
  final String mealType;
  final IconData icon;
  final String label;
  final MealPlanService mealPlanService;

  const _MealSlot({
    required this.date,
    required this.mealType,
    required this.icon,
    required this.label,
    required this.mealPlanService,
  });

  @override
  Widget build(BuildContext context) {
    final mealPlan = mealPlanService.getMealPlan(date, mealType);
    final recipeService = context.watch<RecipeService>();
    final recipe = mealPlan != null ? recipeService.getRecipeById(mealPlan.recipeId) : null;

    return Container(
      decoration: BoxDecoration(
        color: recipe != null ? AppTheme.primary.withValues(alpha: 0.05) : AppTheme.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: recipe != null ? AppTheme.primary.withValues(alpha: 0.2) : AppTheme.divider,
        ),
      ),
      child: InkWell(
        onTap: () => _showRecipeSelector(context),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(
                icon,
                color: recipe != null ? AppTheme.primary : AppTheme.textSecondary,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                    ),
                    if (recipe != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        recipe.title,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ] else
                      const SizedBox(height: 4),
                    Text(
                      recipe != null ? 'Tap to change' : 'Tap to add recipe',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
              if (recipe != null) ...[
                IconButton(
                  icon: const Icon(Icons.visibility_rounded, size: 20),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RecipeDetailScreen(recipe: recipe),
                      ),
                    );
                  },
                  tooltip: 'View recipe',
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 20),
                  onPressed: () => _removeMeal(context),
                  tooltip: 'Remove',
                  color: AppTheme.error,
                ),
              ] else
                Icon(
                  Icons.add_circle_outline_rounded,
                  color: AppTheme.textSecondary,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRecipeSelector(BuildContext context) async {
    final recipeService = context.read<RecipeService>();
    final recipes = recipeService.recipes;

    if (recipes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No recipes available. Add some recipes first!'),
        ),
      );
      return;
    }

    final selected = await showModalBottomSheet<Recipe>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          maxChildSize: 0.9,
          minChildSize: 0.5,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: AppTheme.divider),
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        'Select a Recipe',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: recipes.length,
                    itemBuilder: (context, index) {
                      final recipe = recipes[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: recipe.imageUrl.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    recipe.imageUrl,
                                    width: 56,
                                    height: 56,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) =>
                                        _buildPlaceholder(),
                                  ),
                                )
                              : _buildPlaceholder(),
                          title: Text(recipe.title),
                          subtitle: Text(
                            '${recipe.cookingTimeMinutes} min • ${recipe.servings} servings',
                          ),
                          onTap: () => Navigator.pop(context, recipe),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    if (selected != null && context.mounted) {
      await mealPlanService.setMealPlan(date, mealType, selected.id);
    }
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: AppTheme.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.restaurant_menu_rounded,
        color: AppTheme.textSecondary,
      ),
    );
  }

  void _removeMeal(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Remove Meal?'),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: const Text('This will remove the recipe from this meal slot.'),
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
              child: const Text('Remove'),
            ),
          ],
        );
      },
    );

    if (confirmed == true && context.mounted) {
      await mealPlanService.removeMealPlan(date, mealType);
    }
  }
}
