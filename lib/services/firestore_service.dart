import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/recipe.dart';
import '../models/shopping_item.dart';
import '../models/meal_plan.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _userId => _auth.currentUser?.uid;

  // ==================== RECIPES ====================

  /// Get recipes collection reference for current user
  CollectionReference<Map<String, dynamic>>? get _recipesCollection {
    if (_userId == null) return null;
    return _firestore.collection('users').doc(_userId).collection('recipes');
  }

  /// Add a new recipe to Firestore
  Future<void> addRecipe(Recipe recipe) async {
    final collection = _recipesCollection;
    if (collection == null) {
      throw Exception('User not authenticated');
    }

    await collection.doc(recipe.id).set(recipe.toMap());
  }

  /// Update an existing recipe
  Future<void> updateRecipe(Recipe recipe) async {
    final collection = _recipesCollection;
    if (collection == null) {
      throw Exception('User not authenticated');
    }

    await collection.doc(recipe.id).update(recipe.toMap());
  }

  /// Delete a recipe
  Future<void> deleteRecipe(String recipeId) async {
    final collection = _recipesCollection;
    if (collection == null) {
      throw Exception('User not authenticated');
    }

    await collection.doc(recipeId).delete();
  }

  /// Get all recipes for current user
  Future<List<Recipe>> getRecipes() async {
    final collection = _recipesCollection;
    if (collection == null) {
      return [];
    }

    final snapshot = await collection.get();
    return snapshot.docs
        .map((doc) => Recipe.fromMap(doc.data()))
        .toList();
  }

  /// Stream of recipes (real-time updates)
  Stream<List<Recipe>>? recipesStream() {
    final collection = _recipesCollection;
    if (collection == null) return null;

    return collection.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Recipe.fromMap(doc.data()))
          .toList();
    });
  }

  // ==================== SHOPPING ITEMS ====================

  /// Get shopping items collection reference for current user
  CollectionReference<Map<String, dynamic>>? get _shoppingCollection {
    if (_userId == null) return null;
    return _firestore.collection('users').doc(_userId).collection('shopping_items');
  }

  /// Add a shopping item
  Future<void> addShoppingItem(ShoppingItem item) async {
    final collection = _shoppingCollection;
    if (collection == null) {
      throw Exception('User not authenticated');
    }

    await collection.doc(item.id).set(item.toMap());
  }

  /// Update a shopping item
  Future<void> updateShoppingItem(ShoppingItem item) async {
    final collection = _shoppingCollection;
    if (collection == null) {
      throw Exception('User not authenticated');
    }

    await collection.doc(item.id).update(item.toMap());
  }

  /// Delete a shopping item
  Future<void> deleteShoppingItem(String itemId) async {
    final collection = _shoppingCollection;
    if (collection == null) {
      throw Exception('User not authenticated');
    }

    await collection.doc(itemId).delete();
  }

  /// Get all shopping items
  Future<List<ShoppingItem>> getShoppingItems() async {
    final collection = _shoppingCollection;
    if (collection == null) {
      return [];
    }

    final snapshot = await collection.get();
    return snapshot.docs
        .map((doc) => ShoppingItem.fromMap(doc.data()))
        .toList();
  }

  /// Stream of shopping items (real-time updates)
  Stream<List<ShoppingItem>>? shoppingItemsStream() {
    final collection = _shoppingCollection;
    if (collection == null) return null;

    return collection.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => ShoppingItem.fromMap(doc.data()))
          .toList();
    });
  }

  // ==================== MEAL PLANS ====================

  /// Get meal plans collection reference for current user
  CollectionReference<Map<String, dynamic>>? get _mealPlansCollection {
    if (_userId == null) return null;
    return _firestore.collection('users').doc(_userId).collection('meal_plans');
  }

  /// Add a meal plan
  Future<void> addMealPlan(MealPlan plan) async {
    final collection = _mealPlansCollection;
    if (collection == null) {
      throw Exception('User not authenticated');
    }

    await collection.doc(plan.id).set(plan.toMap());
  }

  /// Update a meal plan
  Future<void> updateMealPlan(MealPlan plan) async {
    final collection = _mealPlansCollection;
    if (collection == null) {
      throw Exception('User not authenticated');
    }

    await collection.doc(plan.id).update(plan.toMap());
  }

  /// Delete a meal plan
  Future<void> deleteMealPlan(String planId) async {
    final collection = _mealPlansCollection;
    if (collection == null) {
      throw Exception('User not authenticated');
    }

    await collection.doc(planId).delete();
  }

  /// Get all meal plans
  Future<List<MealPlan>> getMealPlans() async {
    final collection = _mealPlansCollection;
    if (collection == null) {
      return [];
    }

    final snapshot = await collection.get();
    return snapshot.docs
        .map((doc) => MealPlan.fromMap(doc.data()))
        .toList();
  }

  /// Stream of meal plans (real-time updates)
  Stream<List<MealPlan>>? mealPlansStream() {
    final collection = _mealPlansCollection;
    if (collection == null) return null;

    return collection.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => MealPlan.fromMap(doc.data()))
          .toList();
    });
  }

  // ==================== BATCH OPERATIONS ====================

  /// Batch add multiple recipes (for migration)
  Future<void> batchAddRecipes(List<Recipe> recipes) async {
    final collection = _recipesCollection;
    if (collection == null) {
      throw Exception('User not authenticated');
    }

    final batch = _firestore.batch();
    for (final recipe in recipes) {
      batch.set(collection.doc(recipe.id), recipe.toMap());
    }
    await batch.commit();
  }

  /// Batch add multiple shopping items (for migration)
  Future<void> batchAddShoppingItems(List<ShoppingItem> items) async {
    final collection = _shoppingCollection;
    if (collection == null) {
      throw Exception('User not authenticated');
    }

    final batch = _firestore.batch();
    for (final item in items) {
      batch.set(collection.doc(item.id), item.toMap());
    }
    await batch.commit();
  }

  /// Batch add multiple meal plans (for migration)
  Future<void> batchAddMealPlans(List<MealPlan> plans) async {
    final collection = _mealPlansCollection;
    if (collection == null) {
      throw Exception('User not authenticated');
    }

    final batch = _firestore.batch();
    for (final plan in plans) {
      batch.set(collection.doc(plan.id), plan.toMap());
    }
    await batch.commit();
  }

  // ==================== MIGRATION HELPERS ====================

  /// Check if user has any data in Firestore
  Future<bool> hasCloudData() async {
    if (_userId == null) return false;

    final recipes = await _recipesCollection?.limit(1).get();
    return recipes?.docs.isNotEmpty ?? false;
  }

  /// Clear all user data (for testing/reset)
  Future<void> clearAllUserData() async {
    if (_userId == null) return;

    final batch = _firestore.batch();

    // Clear recipes
    final recipes = await _recipesCollection?.get();
    if (recipes != null) {
      for (final doc in recipes.docs) {
        batch.delete(doc.reference);
      }
    }

    // Clear shopping items
    final shopping = await _shoppingCollection?.get();
    if (shopping != null) {
      for (final doc in shopping.docs) {
        batch.delete(doc.reference);
      }
    }

    // Clear meal plans
    final mealPlans = await _mealPlansCollection?.get();
    if (mealPlans != null) {
      for (final doc in mealPlans.docs) {
        batch.delete(doc.reference);
      }
    }

    await batch.commit();
  }
}
