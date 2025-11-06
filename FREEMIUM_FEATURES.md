# Freemium & Premium Features Implementation

## ✅ Completed Features

### Subscription System

**Models:**
- `UserSubscription` - Tracks user subscription tier, limits, and premium status
- Support for Free and Premium tiers
- Automatic limit tracking (imports, recipes created)

**Services:**
- `SubscriptionService` - Manages subscription state and Firestore integration
- Real-time subscription updates via Firestore streams
- Automatic initialization on user login

### Feature Limits

#### Free Tier
- ✅ **5 Recipe Imports** from YouTube
- ✅ **10 Saved Recipes** custom recipes
- ✅ **7-day Meal Planning**
- ❌ No nutritional information
- ❌ No recipe sharing
- ❌ No data export
- ❌ No AI recipe generation

#### Premium Tier ($29.99 lifetime)
- ✅ **Unlimited Recipe Imports**
- ✅ **Unlimited Recipe Storage**
- ✅ **30+ Day Meal Planning**
- ✅ **Nutritional Information**
- ✅ **Recipe Sharing**
- ✅ **Data Export**
- ✅ **AI Recipe Generation**
- ✅ **Priority Support**

### UI Components

1. **PremiumScreen** (`lib/screens/subscription/premium_screen.dart`)
   - Beautiful upgrade page with feature list
   - Current usage indicators for free users
   - One-click upgrade flow
   - Premium badge for existing subscribers

2. **FeatureGate** Widget (`lib/widgets/feature_gate.dart`)
   - Wrap any feature to enforce premium access
   - Shows lock icon for locked features
   - Displays upgrade dialog on tap
   - Seamless UX for feature discovery

3. **HomeScreen Updates**
   - Premium badge next to user name
   - Star icon in AppBar for upgrade (free users only)
   - Automatic subscription initialization

## 📊 Usage Example

### Protecting a Feature

```dart
FeatureGate(
  featureName: 'ai_generation',
  child: ElevatedButton(
    onPressed: () => generateAIRecipe(),
    child: Text('Generate with AI'),
  ),
)
```

### Checking Before Action

```dart
final subscriptionService = Provider.of<SubscriptionService>(context);

if (!subscriptionService.canImportRecipe()) {
  // Show upgrade prompt
  _showUpgradeDialog();
  return;
}

// Proceed with import
await importRecipe();
await subscriptionService.incrementRecipeImport(userId);
```

### Available Feature Checks

```dart
subscriptionService.isPremium
subscriptionService.canImportRecipe()
subscriptionService.canCreateRecipe()
subscriptionService.hasFeature('unlimited_recipes')
subscriptionService.hasFeature('advanced_meal_planning')
subscriptionService.hasFeature('nutritional_info')
subscriptionService.hasFeature('recipe_sharing')
subscriptionService.hasFeature('export_data')
subscriptionService.hasFeature('ai_generation')
```

## 🎯 Integration Points

### Where to Add Feature Gates

1. **Import Recipe Screen** - Check `canImportRecipe()` before importing
2. **Create Recipe** - Check `canCreateRecipe()` before saving
3. **Meal Plan** - Limit days for free tier
4. **Recipe Details** - Hide nutritional info for free users
5. **Share Button** - Gate with `hasFeature('recipe_sharing')`
6. **Export Menu** - Gate with `hasFeature('export_data')`
7. **AI Features** - Gate with `hasFeature('ai_generation')`

### Firestore Structure

Collection: `subscriptions`
Document ID: `{userId}`

```json
{
  "userId": "user123",
  "tier": "free",
  "premiumExpiresAt": null,
  "recipesImported": 3,
  "recipesCreated": 7,
  "createdAt": "2025-11-01T10:00:00Z",
  "updatedAt": "2025-11-01T15:30:00Z"
}
```

## 💳 Payment Integration (TODO)

The current implementation includes a simulated upgrade. To integrate real payments:

### Option 1: Stripe

```dart
// In PremiumScreen._handleUpgrade()
final paymentSheet = await Stripe.instance.initPaymentSheet(
  paymentSheetParameters: SetupPaymentSheetParameters(
    merchantDisplayName: 'Gusto',
    customerId: customerId,
    customerEphemeralKeySecret: ephemeralKey,
    paymentIntentClientSecret: paymentIntent,
  ),
);

await Stripe.instance.presentPaymentSheet();
// On success, call upgradeToPremium()
```

### Option 2: RevenueCat

```dart
// Initialize RevenueCat
await Purchases.configure(
  PurchasesConfiguration('api_key'),
);

// Purchase
final purchaserInfo = await Purchases.purchaseProduct('premium_lifetime');
if (purchaserInfo.entitlements.all['premium']?.isActive == true) {
  await subscriptionService.upgradeToPremium(userId);
}
```

### Option 3: In-App Purchase (Mobile)

```dart
import 'package:in_app_purchase/in_app_purchase.dart';

const String premiumId = 'gusto_premium_lifetime';
final ProductDetailsResponse response = 
    await InAppPurchase.instance.queryProductDetails({premiumId});

// Purchase flow...
```

## 🔒 Security Rules

Add to `firestore.rules`:

```javascript
match /subscriptions/{userId} {
  allow read: if request.auth.uid == userId;
  allow write: if request.auth.uid == userId;
}
```

## 📈 Analytics Events (Recommended)

Track these events for business insights:

- `premium_screen_viewed`
- `upgrade_button_clicked`
- `premium_purchase_started`
- `premium_purchase_completed`
- `premium_purchase_failed`
- `feature_gate_hit` (which feature, how many times)
- `free_limit_reached` (which limit)

## 🧪 Testing

### Test Free User
1. Sign in
2. Import 5 recipes → Should hit limit
3. Try to import 6th → Should see upgrade prompt
4. Create 10 recipes → Should hit limit
5. Try features → Should see locks

### Test Premium User
1. Sign in
2. Navigate to Premium screen
3. Click "Upgrade Now"
4. Verify premium badge appears
5. Verify no limits on imports/recipes
6. Verify all features unlocked

## 🚀 Next Steps

1. **Integrate Payment Provider** - Choose Stripe, RevenueCat, or IAP
2. **Add Analytics** - Track conversion funnel
3. **A/B Test Pricing** - Test different price points
4. **Add Trial Period** - 7-day free trial for premium
5. **Email Campaigns** - Re-engage free users
6. **Add Monthly Option** - $4.99/month alongside lifetime
7. **Referral Program** - Give free month for referrals
8. **Usage Notifications** - Alert when approaching limits

## 💰 Monetization Strategy

**Current Model:** Lifetime Premium ($29.99)

**Suggested Additions:**
- Monthly: $4.99/month
- Annual: $29.99/year (save 50%)
- Family Plan: $49.99/year (5 users)
- Trial: 7 days free, then $4.99/month

**Conversion Tactics:**
- Show usage % when at 80% of free limit
- Offer 20% discount for early adopters
- Show "Popular" badge on annual plan
- Highlight money-back guarantee
