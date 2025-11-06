import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'dart:async';
import '../models/recipe.dart';
import 'firestore_service.dart';

class RecipeService extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  List<Recipe> _recipes = [];
  bool _isLoading = false;
  String? _error;
  StreamSubscription? _recipeSubscription;

  List<Recipe> get recipes => List.unmodifiable(_recipes);
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _auth.currentUser != null;

  RecipeService() {
    _init();
    // Load initial data
    _loadRecipes();
  }

  void _init() {
    // Listen to auth state changes
    _auth.authStateChanges().listen((user) {
      if (user != null) {
        // User logged in - load from Firestore and migrate local data
        _loadFromFirestoreWithMigration();
      } else {
        // User logged out - load from local storage only
        _loadFromLocalStorage();
        _recipeSubscription?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _recipeSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadRecipes() async {
    if (isAuthenticated) {
      await _loadFromFirestoreWithMigration();
    } else {
      await _loadFromLocalStorage();
    }
  }

  /// Load recipes from local SharedPreferences (offline/guest mode)
  Future<void> _loadFromLocalStorage() async {
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

  /// Load from Firestore and migrate any local data
  Future<void> _loadFromFirestoreWithMigration() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Check if user has cloud data
      final hasCloudData = await _firestoreService.hasCloudData();
      
      if (!hasCloudData) {
        // First login - migrate local data to cloud
        await _migrateLocalToCloud();
      }

      // Set up real-time listener
      _recipeSubscription?.cancel();
      _recipeSubscription = _firestoreService.recipesStream()?.listen(
        (recipes) {
          _recipes = recipes;
          _error = null;
          notifyListeners();
          // Also cache to local storage for offline access
          _saveToLocalStorage();
        },
        onError: (error) {
          debugPrint('⚠️ Firestore sync error: $error');
          _error = null; // Don't show error to user, just use local cache
          // Fall back to local storage silently
          _loadFromLocalStorage();
        },
      );

      // Initial load from Firestore
      _recipes = await _firestoreService.getRecipes();
      _error = null;
      await _saveToLocalStorage();
    } catch (e) {
      debugPrint('⚠️ Firestore error, using local storage: $e');
      _error = null; // Don't show error to user
      // Fall back to local storage
      await _loadFromLocalStorage();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Migrate existing local recipes to Firestore
  Future<void> _migrateLocalToCloud() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final recipesJson = prefs.getStringList('recipes') ?? [];
      
      if (recipesJson.isEmpty) return;

      final localRecipes = recipesJson
          .map((json) => Recipe.fromMap(jsonDecode(json)))
          .toList();

      if (localRecipes.isNotEmpty) {
        // Update userId to current user
        final userId = _auth.currentUser?.uid ?? 'unknown';
        final updatedRecipes = localRecipes.map((recipe) {
          return recipe.copyWith(userId: userId);
        }).toList();

        // Batch upload to Firestore
        await _firestoreService.batchAddRecipes(updatedRecipes);
        
        debugPrint('✅ Migrated ${updatedRecipes.length} recipes to cloud');
      }
    } catch (e) {
      debugPrint('⚠️ Migration error: $e');
      // Don't throw - migration failure shouldn't break the app
    }
  }

  /// Save to local storage (for offline access)
  Future<void> _saveToLocalStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final recipesJson = _recipes
          .map((recipe) => jsonEncode(recipe.toMap()))
          .toList();
      await prefs.setStringList('recipes', recipesJson);
    } catch (e) {
      debugPrint('⚠️ Failed to cache recipes locally: $e');
    }
  }

  Future<void> addRecipe(Recipe recipe) async {
    // Update userId to current user
    final userId = _auth.currentUser?.uid ?? 'local_user';
    final recipeWithUserId = recipe.copyWith(userId: userId);
    
    if (isAuthenticated) {
      try {
        // Save to Firestore (will trigger stream update)
        await _firestoreService.addRecipe(recipeWithUserId);
      } catch (e) {
        debugPrint('⚠️ Failed to save to Firestore, saving locally: $e');
        // If Firestore fails, save locally
        _recipes.add(recipeWithUserId);
        notifyListeners();
        await _saveToLocalStorage();
      }
    } else {
      // Guest mode - save locally only
      _recipes.add(recipeWithUserId);
      notifyListeners();
      await _saveToLocalStorage();
    }
  }

  Future<void> updateRecipe(Recipe recipe) async {
    if (isAuthenticated) {
      try {
        // Update in Firestore (will trigger stream update)
        await _firestoreService.updateRecipe(recipe);
      } catch (e) {
        debugPrint('⚠️ Failed to update in Firestore, updating locally: $e');
        // If Firestore fails, update locally
        final index = _recipes.indexWhere((r) => r.id == recipe.id);
        if (index != -1) {
          _recipes[index] = recipe;
          notifyListeners();
          await _saveToLocalStorage();
        }
      }
    } else {
      // Guest mode - update locally
      final index = _recipes.indexWhere((r) => r.id == recipe.id);
      if (index != -1) {
        _recipes[index] = recipe;
        notifyListeners();
        await _saveToLocalStorage();
      }
    }
  }

  Future<void> deleteRecipe(String id) async {
    if (isAuthenticated) {
      try {
        // Delete from Firestore (will trigger stream update)
        await _firestoreService.deleteRecipe(id);
      } catch (e) {
        debugPrint('⚠️ Failed to delete from Firestore, deleting locally: $e');
        // If Firestore fails, delete locally
        _recipes.removeWhere((r) => r.id == id);
        notifyListeners();
        await _saveToLocalStorage();
      }
    } else {
      // Guest mode - delete locally
      _recipes.removeWhere((r) => r.id == id);
      notifyListeners();
      await _saveToLocalStorage();
    }
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
