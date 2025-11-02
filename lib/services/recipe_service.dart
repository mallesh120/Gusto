import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/recipe.dart';

class RecipeService extends ChangeNotifier {
  List<Recipe> _recipes = [];
  bool _isLoading = false;
  String? _error;

  List<Recipe> get recipes => List.unmodifiable(_recipes);
  bool get isLoading => _isLoading;
  String? get error => _error;

  RecipeService() {
    _loadRecipes();
  }

  Future<void> _loadRecipes() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final recipesJson = prefs.getStringList('recipes') ?? [];
      _recipes = recipesJson
          .map((json) => Recipe.fromMap(jsonDecode(json)))
          .toList();
      _error = null;
    } catch (e) {
      _error = 'Failed to load recipes: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveRecipes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final recipesJson = _recipes
          .map((recipe) => jsonEncode(recipe.toMap()))
          .toList();
      await prefs.setStringList('recipes', recipesJson);
    } catch (e) {
      _error = 'Failed to save recipes: $e';
      notifyListeners();
    }
  }

  Future<void> addRecipe(Recipe recipe) async {
    _recipes.add(recipe);
    notifyListeners();
    await _saveRecipes();
  }

  Future<void> updateRecipe(Recipe recipe) async {
    final index = _recipes.indexWhere((r) => r.id == recipe.id);
    if (index != -1) {
      _recipes[index] = recipe;
      notifyListeners();
      await _saveRecipes();
    }
  }

  Future<void> deleteRecipe(String id) async {
    _recipes.removeWhere((r) => r.id == id);
    notifyListeners();
    await _saveRecipes();
  }

  Recipe? getRecipeById(String id) {
    try {
      return _recipes.firstWhere((r) => r.id == id);
    } catch (e) {
      return null;
    }
  }

  List<Recipe> searchRecipes(String query) {
    if (query.isEmpty) return _recipes;
    
    final lowerQuery = query.toLowerCase();
    return _recipes.where((recipe) {
      return recipe.title.toLowerCase().contains(lowerQuery) ||
          recipe.description.toLowerCase().contains(lowerQuery) ||
          recipe.tags.any((tag) => tag.toLowerCase().contains(lowerQuery)) ||
          recipe.ingredients.any((ing) => ing.toLowerCase().contains(lowerQuery));
    }).toList();
  }

  List<Recipe> filterByTags(List<String> tags) {
    if (tags.isEmpty) return _recipes;
    
    return _recipes.where((recipe) {
      return tags.any((tag) => recipe.tags.contains(tag));
    }).toList();
  }

  List<Recipe> filterByCookingTime(int maxMinutes) {
    return _recipes.where((recipe) => recipe.cookingTimeMinutes <= maxMinutes).toList();
  }

  List<String> getAllTags() {
    final tags = <String>{};
    for (final recipe in _recipes) {
      tags.addAll(recipe.tags);
    }
    return tags.toList()..sort();
  }

  Future<void> refresh() async {
    await _loadRecipes();
  }
}
