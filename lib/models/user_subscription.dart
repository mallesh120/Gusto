import 'package:cloud_firestore/cloud_firestore.dart';

enum SubscriptionTier {
  free,
  premium,
}

class UserSubscription {
  final String userId;
  final SubscriptionTier tier;
  final DateTime? premiumExpiresAt;
  final int recipesImported; // Track usage for free tier limits
  final int recipesCreated;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserSubscription({
    required this.userId,
    required this.tier,
    this.premiumExpiresAt,
    this.recipesImported = 0,
    this.recipesCreated = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  // Free tier limits
  static const int freeRecipeImportLimit = 5;
  static const int freeRecipeCreateLimit = 10;
  static const int freeMealPlanDays = 7;

  // Premium features
  bool get isPremium => tier == SubscriptionTier.premium && 
      (premiumExpiresAt == null || premiumExpiresAt!.isAfter(DateTime.now()));

  bool get canImportRecipe => 
      isPremium || recipesImported < freeRecipeImportLimit;

  bool get canCreateRecipe => 
      isPremium || recipesCreated < freeRecipeCreateLimit;

  bool get hasUnlimitedRecipes => isPremium;
  bool get hasAdvancedMealPlanning => isPremium;
  bool get hasNutritionalInfo => isPremium;
  bool get hasRecipeSharing => isPremium;
  bool get canExportData => isPremium;
  bool get hasAIRecipeGeneration => isPremium;

  int get remainingFreeImports => 
      isPremium ? -1 : (freeRecipeImportLimit - recipesImported).clamp(0, freeRecipeImportLimit);

  int get remainingFreeRecipes => 
      isPremium ? -1 : (freeRecipeCreateLimit - recipesCreated).clamp(0, freeRecipeCreateLimit);

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'tier': tier.name,
      'premiumExpiresAt': premiumExpiresAt?.toIso8601String(),
      'recipesImported': recipesImported,
      'recipesCreated': recipesCreated,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory UserSubscription.fromMap(Map<String, dynamic> map) {
    return UserSubscription(
      userId: map['userId'] as String,
      tier: SubscriptionTier.values.firstWhere(
        (e) => e.name == map['tier'],
        orElse: () => SubscriptionTier.free,
      ),
      premiumExpiresAt: map['premiumExpiresAt'] != null
          ? DateTime.parse(map['premiumExpiresAt'] as String)
          : null,
      recipesImported: map['recipesImported'] as int? ?? 0,
      recipesCreated: map['recipesCreated'] as int? ?? 0,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  factory UserSubscription.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserSubscription.fromMap(data);
  }

  UserSubscription copyWith({
    String? userId,
    SubscriptionTier? tier,
    DateTime? premiumExpiresAt,
    int? recipesImported,
    int? recipesCreated,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserSubscription(
      userId: userId ?? this.userId,
      tier: tier ?? this.tier,
      premiumExpiresAt: premiumExpiresAt ?? this.premiumExpiresAt,
      recipesImported: recipesImported ?? this.recipesImported,
      recipesCreated: recipesCreated ?? this.recipesCreated,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
