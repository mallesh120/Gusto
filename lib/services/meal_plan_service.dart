import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'dart:async';
import '../models/meal_plan.dart';
import '../models/recipe.dart';
import '../models/shopping_item.dart' as shopping;
import 'firestore_service.dart';

class MealPlanService extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  List<MealPlan> _mealPlans = [];
  bool _isLoading = false;
  String? _error;
  DateTime _selectedWeekStart = _getWeekStart(DateTime.now());
  StreamSubscription? _plansSubscription;

  List<MealPlan> get mealPlans => List.unmodifiable(_mealPlans);
  bool get isLoading => _isLoading;
  String? get error => _error;
  DateTime get selectedWeekStart => _selectedWeekStart;
  bool get isAuthenticated => _auth.currentUser != null;

  static DateTime _getWeekStart(DateTime date) {
    // Get Monday of the week
    return date.subtract(Duration(days: date.weekday - 1));
  }

  MealPlanService() {
    _init();
    // Load initial data
    _loadMealPlans();
  }

  void _init() {
    _auth.authStateChanges().listen((user) {
      if (user != null) {
        _loadFromFirestoreWithMigration();
      } else {
        _loadFromLocalStorage();
        _plansSubscription?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _plansSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadMealPlans() async {
    if (isAuthenticated) {
      await _loadFromFirestoreWithMigration();
    } else {
      await _loadFromLocalStorage();
    }
  }

  Future<void> _loadFromLocalStorage() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final mealPlansJson = prefs.getStringList('meal_plans') ?? [];
      _mealPlans = mealPlansJson
          .map((json) => MealPlan.fromMap(jsonDecode(json)))
          .toList();
      _error = null;
    } catch (e) {
      _error = 'Failed to load meal plans: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadFromFirestoreWithMigration() async {
    _isLoading = true;
    notifyListeners();

    try {
      final hasCloudData = await _firestoreService.hasCloudData();
      
      if (!hasCloudData) {
        await _migrateLocalToCloud();
      }

      _plansSubscription?.cancel();
      _plansSubscription = _firestoreService.mealPlansStream()?.listen(
        (plans) {
          _mealPlans = plans;
          _error = null;
          notifyListeners();
          _saveToLocalStorage();
        },
        onError: (_) {
          _loadFromLocalStorage();
        },
      );

      _mealPlans = await _firestoreService.getMealPlans();
      _error = null;
      await _saveToLocalStorage();
    } catch (e) {
      _error = 'Failed to sync meal plans: $e';
      await _loadFromLocalStorage();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _migrateLocalToCloud() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final mealPlansJson = prefs.getStringList('meal_plans') ?? [];
      
      if (mealPlansJson.isEmpty) return;

      final localPlans = mealPlansJson
          .map((json) => MealPlan.fromMap(jsonDecode(json)))
          .toList();

      if (localPlans.isNotEmpty) {
        await _firestoreService.batchAddMealPlans(localPlans);
        debugPrint('✅ Migrated ${localPlans.length} meal plans to cloud');
      }
    } catch (e) {
      debugPrint('⚠️ Meal plan migration error: $e');
    }
  }

  Future<void> _saveToLocalStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final mealPlansJson = _mealPlans
          .map((plan) => jsonEncode(plan.toMap()))
          .toList();
      await prefs.setStringList('meal_plans', mealPlansJson);
    } catch (e) {
      debugPrint('⚠️ Failed to cache meal plans: $e');
    }
  }

  Future<void> _saveMealPlans() async {
    await _saveToLocalStorage();
  }

  // Get meal plans for a specific week
  List<MealPlan> getMealPlansForWeek(DateTime weekStart) {
    final weekEnd = weekStart.add(const Duration(days: 7));
    return _mealPlans.where((plan) {
      return plan.date.isAfter(weekStart.subtract(const Duration(days: 1))) &&
          plan.date.isBefore(weekEnd);
    }).toList();
  }

  // Get meal plan for a specific date and meal type
  MealPlan? getMealPlan(DateTime date, String mealType) {
    try {
      return _mealPlans.firstWhere((plan) {
        return plan.date.year == date.year &&
            plan.date.month == date.month &&
            plan.date.day == date.day &&
            plan.mealType == mealType;
      });
    } catch (e) {
      return null;
    }
  }

  // Add or update a meal plan
  Future<void> setMealPlan(DateTime date, String mealType, String recipeId) async {
    final existingPlan = getMealPlan(date, mealType);
    
    if (existingPlan != null) {
      // Update existing
      final updated = existingPlan.copyWith(recipeId: recipeId);
      
      if (isAuthenticated) {
        await _firestoreService.updateMealPlan(updated);
      } else {
        final index = _mealPlans.indexOf(existingPlan);
        _mealPlans[index] = updated;
        notifyListeners();
        await _saveMealPlans();
      }
    } else {
      // Add new
      final newPlan = MealPlan(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        date: date,
        mealType: mealType,
        recipeId: recipeId,
      );
      
      if (isAuthenticated) {
        await _firestoreService.addMealPlan(newPlan);
      } else {
        _mealPlans.add(newPlan);
        notifyListeners();
        await _saveMealPlans();
      }
    }
  }

  // Remove a meal plan
  Future<void> removeMealPlan(DateTime date, String mealType) async {
    final plan = getMealPlan(date, mealType);
    if (plan == null) return;

    if (isAuthenticated) {
      await _firestoreService.deleteMealPlan(plan.id);
    } else {
      _mealPlans.removeWhere((p) => p.id == plan.id);
      notifyListeners();
      await _saveMealPlans();
    }
  }

  // Navigate to previous week
  void previousWeek() {
    _selectedWeekStart = _selectedWeekStart.subtract(const Duration(days: 7));
    notifyListeners();
  }

  // Navigate to next week
  void nextWeek() {
    _selectedWeekStart = _selectedWeekStart.add(const Duration(days: 7));
    notifyListeners();
  }

  // Go to current week
  void goToCurrentWeek() {
    _selectedWeekStart = _getWeekStart(DateTime.now());
    notifyListeners();
  }

  // Generate shopping list from current week's meal plans
  List<shopping.ShoppingItem> generateShoppingList(List<Recipe> allRecipes) {
    final weekMealPlans = getMealPlansForWeek(_selectedWeekStart);
    final ingredientMap = <String, shopping.ShoppingItem>{};

    for (final mealPlan in weekMealPlans) {
      final recipe = allRecipes.where((r) => r.id == mealPlan.recipeId).firstOrNull;
      if (recipe != null) {
        for (final ingredient in recipe.ingredients) {
          // Simple ingredient parsing - in production, use better parsing
          final key = ingredient.toLowerCase().trim();
          
          if (ingredientMap.containsKey(key)) {
            // Already in list - could combine quantities in production
            continue;
          } else {
            ingredientMap[key] = shopping.ShoppingItem(
              id: DateTime.now().millisecondsSinceEpoch.toString() + key.hashCode.toString(),
              name: ingredient,
              category: shopping.Category.other,
              isChecked: false,
              userId: 'local_user',
            );
          }
        }
      }
    }

    return ingredientMap.values.toList();
  }

  Future<void> refresh() async {
    await _loadMealPlans();
  }
}
