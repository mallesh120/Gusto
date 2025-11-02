import 'package:flutter/material.dart';
import 'dart:async';
import '../../models/recipe.dart';
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
            onPressed: () {
              // TODO: Add to shopping list
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Added to shopping list!'),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  backgroundColor: AppTheme.secondary,
                ),
              );
            },
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
}
