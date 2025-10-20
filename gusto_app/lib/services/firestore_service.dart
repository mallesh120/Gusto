import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gusto_app/models/recipe_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Get a stream of recipes for a specific user
  Stream<List<Recipe>> getRecipes(String userId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('recipes')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Recipe.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Add a new recipe
  Future<void> addRecipe(String userId, Recipe recipe) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('recipes')
        .add(recipe.toMap());
  }

  // Update an existing recipe
  Future<void> updateRecipe(String userId, Recipe recipe) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('recipes')
        .doc(recipe.id)
        .update(recipe.toMap());
  }

  // Delete a recipe
  Future<void> deleteRecipe(String userId, String recipeId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('recipes')
        .doc(recipeId)
        .delete();
  }

  // Check recipe limits for the free tier
  Future<bool> checkRecipeLimits(String userId, bool isVideoRecipe) async {
    final snapshot =
        await _db.collection('users').doc(userId).collection('recipes').get();
    final recipeCount = snapshot.docs.length;

    if (recipeCount >= 25) {
      return false;
    }

    if (isVideoRecipe) {
      final videoRecipeCount = snapshot.docs
          .where((doc) => Recipe.fromMap(doc.data(), doc.id).isVideoRecipe)
          .length;
      if (videoRecipeCount >= 3) {
        return false;
      }
    }

    return true;
  }
}
