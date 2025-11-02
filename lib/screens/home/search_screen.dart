import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/recipe.dart';
import '../../services/recipe_service.dart';
import '../../utils/app_theme.dart';
import 'recipe_detail_screen.dart';

enum SortOption {
  dateNewest,
  dateOldest,
  nameAZ,
  nameZA,
  timeAsc,
  timeDesc,
}

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  List<String> _selectedTags = [];
  int? _maxCookingTime;
  SortOption _sortOption = SortOption.dateNewest;
  bool _showFilters = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Recipe> _getFilteredAndSortedRecipes(RecipeService service) {
    var recipes = service.recipes;

    // Apply search
    if (_searchQuery.isNotEmpty) {
      recipes = service.searchRecipes(_searchQuery);
    }

    // Apply tag filter
    if (_selectedTags.isNotEmpty) {
      recipes = recipes.where((r) => 
        _selectedTags.any((tag) => r.tags.contains(tag))
      ).toList();
    }

    // Apply cooking time filter
    if (_maxCookingTime != null) {
      recipes = recipes.where((r) => r.cookingTimeMinutes <= _maxCookingTime!).toList();
    }

    // Apply sorting
    switch (_sortOption) {
      case SortOption.dateNewest:
        recipes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case SortOption.dateOldest:
        recipes.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case SortOption.nameAZ:
        recipes.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
        break;
      case SortOption.nameZA:
        recipes.sort((a, b) => b.title.toLowerCase().compareTo(a.title.toLowerCase()));
        break;
      case SortOption.timeAsc:
        recipes.sort((a, b) => a.cookingTimeMinutes.compareTo(b.cookingTimeMinutes));
        break;
      case SortOption.timeDesc:
        recipes.sort((a, b) => b.cookingTimeMinutes.compareTo(a.cookingTimeMinutes));
        break;
    }

    return recipes;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Search recipes...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: AppTheme.textSecondary),
          ),
          style: Theme.of(context).textTheme.titleMedium,
          onChanged: (value) {
            setState(() => _searchQuery = value);
          },
        ),
        actions: [
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear_rounded),
              onPressed: () {
                setState(() {
                  _searchController.clear();
                  _searchQuery = '';
                });
              },
            ),
        ],
      ),
      body: Consumer<RecipeService>(
        builder: (context, service, _) {
          final recipes = _getFilteredAndSortedRecipes(service);
          final allTags = service.getAllTags();

          return Column(
            children: [
              // Filters and Sort Bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  border: Border(
                    bottom: BorderSide(color: AppTheme.divider),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        // Filters button
                        FilterChip(
                          label: Text(
                            'Filters ${_selectedTags.isNotEmpty || _maxCookingTime != null ? "(${_selectedTags.length + (_maxCookingTime != null ? 1 : 0)})" : ""}',
                          ),
                          selected: _showFilters,
                          onSelected: (selected) {
                            setState(() => _showFilters = selected);
                          },
                          avatar: const Icon(Icons.filter_list_rounded, size: 18),
                        ),
                        const SizedBox(width: 8),
                        // Sort button
                        ActionChip(
                          label: Text(_getSortLabel()),
                          onPressed: _showSortDialog,
                          avatar: const Icon(Icons.sort_rounded, size: 18),
                        ),
                        const Spacer(),
                        // Results count
                        Text(
                          '${recipes.length} ${recipes.length == 1 ? "recipe" : "recipes"}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    // Filter chips
                    if (_showFilters) ...[
                      const SizedBox(height: 12),
                      _buildFilterSection(allTags),
                    ],
                  ],
                ),
              ),
              // Results
              Expanded(
                child: recipes.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: recipes.length,
                        itemBuilder: (context, index) {
                          return _buildRecipeCard(recipes[index]);
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterSection(List<String> allTags) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Tags',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const Spacer(),
            if (_selectedTags.isNotEmpty || _maxCookingTime != null)
              TextButton(
                onPressed: () {
                  setState(() {
                    _selectedTags.clear();
                    _maxCookingTime = null;
                  });
                },
                child: const Text('Clear All'),
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (allTags.isEmpty)
          Text(
            'No tags available',
            style: Theme.of(context).textTheme.bodySmall,
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: allTags.map((tag) {
              final isSelected = _selectedTags.contains(tag);
              return FilterChip(
                label: Text(tag),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedTags.add(tag);
                    } else {
                      _selectedTags.remove(tag);
                    }
                  });
                },
              );
            }).toList(),
          ),
        const SizedBox(height: 16),
        Text(
          'Max Cooking Time',
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilterChip(
              label: const Text('15 min'),
              selected: _maxCookingTime == 15,
              onSelected: (selected) {
                setState(() => _maxCookingTime = selected ? 15 : null);
              },
            ),
            FilterChip(
              label: const Text('30 min'),
              selected: _maxCookingTime == 30,
              onSelected: (selected) {
                setState(() => _maxCookingTime = selected ? 30 : null);
              },
            ),
            FilterChip(
              label: const Text('45 min'),
              selected: _maxCookingTime == 45,
              onSelected: (selected) {
                setState(() => _maxCookingTime = selected ? 45 : null);
              },
            ),
            FilterChip(
              label: const Text('60 min'),
              selected: _maxCookingTime == 60,
              onSelected: (selected) {
                setState(() => _maxCookingTime = selected ? 60 : null);
              },
            ),
            FilterChip(
              label: const Text('90+ min'),
              selected: _maxCookingTime == 90,
              onSelected: (selected) {
                setState(() => _maxCookingTime = selected ? 90 : null);
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecipeCard(Recipe recipe) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RecipeDetailScreen(recipe: recipe),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: recipe.imageUrl.isNotEmpty
                    ? Image.network(
                        recipe.imageUrl,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            _buildPlaceholder(),
                      )
                    : _buildPlaceholder(),
              ),
              const SizedBox(width: 16),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe.title,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    if (recipe.description.isNotEmpty) ...[
                      Text(
                        recipe.description,
                        style: Theme.of(context).textTheme.bodySmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                    ],
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 14,
                          color: AppTheme.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${recipe.cookingTimeMinutes} min',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          Icons.people_rounded,
                          size: 14,
                          color: AppTheme.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${recipe.servings}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    if (recipe.tags.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: recipe.tags.take(3).map((tag) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              tag,
                              style: TextStyle(
                                color: AppTheme.primary,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 80,
      height: 80,
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 64,
            color: AppTheme.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No recipes found',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty || _selectedTags.isNotEmpty || _maxCookingTime != null
                ? 'Try adjusting your search or filters'
                : 'Start typing to search for recipes',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          if (_searchQuery.isNotEmpty || _selectedTags.isNotEmpty || _maxCookingTime != null) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _searchController.clear();
                  _searchQuery = '';
                  _selectedTags.clear();
                  _maxCookingTime = null;
                });
              },
              child: const Text('Clear All'),
            ),
          ],
        ],
      ),
    );
  }

  void _showSortDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Sort By'),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<SortOption>(
                title: const Text('Date Added (Newest)'),
                value: SortOption.dateNewest,
                groupValue: _sortOption,
                onChanged: (value) {
                  setState(() => _sortOption = value!);
                  Navigator.pop(context);
                },
              ),
              RadioListTile<SortOption>(
                title: const Text('Date Added (Oldest)'),
                value: SortOption.dateOldest,
                groupValue: _sortOption,
                onChanged: (value) {
                  setState(() => _sortOption = value!);
                  Navigator.pop(context);
                },
              ),
              RadioListTile<SortOption>(
                title: const Text('Name (A-Z)'),
                value: SortOption.nameAZ,
                groupValue: _sortOption,
                onChanged: (value) {
                  setState(() => _sortOption = value!);
                  Navigator.pop(context);
                },
              ),
              RadioListTile<SortOption>(
                title: const Text('Name (Z-A)'),
                value: SortOption.nameZA,
                groupValue: _sortOption,
                onChanged: (value) {
                  setState(() => _sortOption = value!);
                  Navigator.pop(context);
                },
              ),
              RadioListTile<SortOption>(
                title: const Text('Cooking Time (Shortest)'),
                value: SortOption.timeAsc,
                groupValue: _sortOption,
                onChanged: (value) {
                  setState(() => _sortOption = value!);
                  Navigator.pop(context);
                },
              ),
              RadioListTile<SortOption>(
                title: const Text('Cooking Time (Longest)'),
                value: SortOption.timeDesc,
                groupValue: _sortOption,
                onChanged: (value) {
                  setState(() => _sortOption = value!);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  String _getSortLabel() {
    switch (_sortOption) {
      case SortOption.dateNewest:
        return 'Newest';
      case SortOption.dateOldest:
        return 'Oldest';
      case SortOption.nameAZ:
        return 'A-Z';
      case SortOption.nameZA:
        return 'Z-A';
      case SortOption.timeAsc:
        return 'Shortest';
      case SortOption.timeDesc:
        return 'Longest';
    }
  }
}
