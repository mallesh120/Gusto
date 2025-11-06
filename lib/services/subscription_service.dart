import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/user_subscription.dart';

class SubscriptionService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  UserSubscription? _subscription;

  UserSubscription? get subscription => _subscription;
  bool get isPremium => _subscription?.isPremium ?? false;

  // Initialize subscription for a user
  Future<void> initializeSubscription(String userId) async {
    try {
      final doc = await _firestore
          .collection('subscriptions')
          .doc(userId)
          .get();

      if (doc.exists) {
        _subscription = UserSubscription.fromFirestore(doc);
      } else {
        // Create new free subscription
        _subscription = UserSubscription(
          userId: userId,
          tier: SubscriptionTier.free,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await _firestore
            .collection('subscriptions')
            .doc(userId)
            .set(_subscription!.toMap());
      }
      notifyListeners();
    } catch (e) {
      debugPrint('⚠️ Error initializing subscription (using default free tier): $e');
      // Create default free subscription locally if Firestore unavailable
      _subscription = UserSubscription(
        userId: userId,
        tier: SubscriptionTier.free,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      notifyListeners();
    }
  }

  // Listen to subscription changes
  Stream<UserSubscription?> subscriptionStream(String userId) {
    return _firestore
        .collection('subscriptions')
        .doc(userId)
        .snapshots()
        .map((doc) {
      if (doc.exists) {
        _subscription = UserSubscription.fromFirestore(doc);
        notifyListeners();
        return _subscription;
      }
      return null;
    });
  }

  // Upgrade to premium
  Future<void> upgradeToPremium(String userId, {Duration? duration}) async {
    try {
      final expiresAt = duration != null
          ? DateTime.now().add(duration)
          : null; // null = lifetime

      final updatedSubscription = _subscription!.copyWith(
        tier: SubscriptionTier.premium,
        premiumExpiresAt: expiresAt,
        updatedAt: DateTime.now(),
      );

      await _firestore
          .collection('subscriptions')
          .doc(userId)
          .update(updatedSubscription.toMap());

      _subscription = updatedSubscription;
      notifyListeners();
    } catch (e) {
      debugPrint('Error upgrading to premium: $e');
      throw Exception('Failed to upgrade subscription');
    }
  }

  // Increment recipe import count
  Future<void> incrementRecipeImport(String userId) async {
    if (_subscription == null) return;

    try {
      final updated = _subscription!.copyWith(
        recipesImported: _subscription!.recipesImported + 1,
        updatedAt: DateTime.now(),
      );

      await _firestore
          .collection('subscriptions')
          .doc(userId)
          .update({'recipesImported': updated.recipesImported});

      _subscription = updated;
      notifyListeners();
    } catch (e) {
      debugPrint('Error incrementing recipe import: $e');
    }
  }

  // Increment recipe create count
  Future<void> incrementRecipeCreate(String userId) async {
    if (_subscription == null) return;

    try {
      final updated = _subscription!.copyWith(
        recipesCreated: _subscription!.recipesCreated + 1,
        updatedAt: DateTime.now(),
      );

      await _firestore
          .collection('subscriptions')
          .doc(userId)
          .update({'recipesCreated': updated.recipesCreated});

      _subscription = updated;
      notifyListeners();
    } catch (e) {
      debugPrint('Error incrementing recipe create: $e');
    }
  }

  // Check if user can perform an action
  bool canImportRecipe() => _subscription?.canImportRecipe ?? false;
  bool canCreateRecipe() => _subscription?.canCreateRecipe ?? false;

  // Get remaining free uses
  int getRemainingImports() => _subscription?.remainingFreeImports ?? 0;
  int getRemainingRecipes() => _subscription?.remainingFreeRecipes ?? 0;

  // Feature checks
  bool hasFeature(String feature) {
    if (_subscription == null) return false;

    switch (feature) {
      case 'unlimited_recipes':
        return _subscription!.hasUnlimitedRecipes;
      case 'advanced_meal_planning':
        return _subscription!.hasAdvancedMealPlanning;
      case 'nutritional_info':
        return _subscription!.hasNutritionalInfo;
      case 'recipe_sharing':
        return _subscription!.hasRecipeSharing;
      case 'export_data':
        return _subscription!.canExportData;
      case 'ai_generation':
        return _subscription!.hasAIRecipeGeneration;
      default:
        return false;
    }
  }

  void clear() {
    _subscription = null;
    notifyListeners();
  }
}
