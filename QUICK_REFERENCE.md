# Gusto - Quick Reference Guide

## 🚀 Running the App

```bash
# Install dependencies
flutter pub get

# Run on Chrome (Web)
flutter run -d chrome

# Run on iOS Simulator
flutter run -d ios

# Run on Android Emulator
flutter run -d android

# Run tests
flutter test

# Analyze code
flutter analyze
```

---

## 📱 Main Features Access

### From Welcome Screen

1. **View Recipes**: Tap "View My Cookbook"
2. **Add Recipe**: Tap "Let's Get Started" → Choose import method
3. **Plan Meals**: Tap "Meal Planner"
4. **Shopping List**: Tap "Open Shopping List"
5. **Try Sample**: Tap "View Sample Recipe"

---

## 🔑 Key Screens

### Cookbook Screen
- **Path**: `lib/screens/home/cookbook_screen.dart`
- **Actions**:
  - Search icon → Opens full search screen
  - Filter icon → Opens filter dialog
  - FAB (+) → Add new recipe
  - Tap card → View recipe detail

### Recipe Detail
- **Path**: `lib/screens/home/recipe_detail_screen.dart`
- **Actions**:
  - Edit icon → Edit recipe
  - Timer → Start/pause/reset cooking timer
  - Tabs → Switch between ingredients/instructions
  - Checkboxes → Track progress

### Add/Edit Recipe
- **Path**: `lib/screens/home/add_recipe_screen.dart`
- **Actions**:
  - Fill form → Enter recipe details
  - Add buttons → Add ingredient/instruction rows
  - Tags → Manage recipe tags
  - Save → Create or update recipe

### Import from URL
- **Path**: `lib/screens/home/import_recipe_url_screen.dart`
- **Actions**:
  - Enter URL → Paste recipe link
  - Sample button → Try with demo URL
  - Preview → Review before saving
  - Save → Add to cookbook

### Meal Planner
- **Path**: `lib/screens/home/meal_plan_screen.dart`
- **Actions**:
  - Arrows → Navigate weeks
  - Meal slot → Assign recipe
  - View icon → See recipe detail
  - Cart icon → Generate shopping list

### Search Screen
- **Path**: `lib/screens/home/search_screen.dart`
- **Actions**:
  - Type → Search recipes
  - Filters chip → Toggle filter section
  - Sort chip → Choose sort order
  - Tag chips → Filter by tags
  - Time chips → Filter by cooking time

---

## 🛠️ Services

### RecipeService
```dart
// Get all recipes
final recipes = recipeService.recipes;

// Add recipe
await recipeService.addRecipe(recipe);

// Update recipe
await recipeService.updateRecipe(recipe);

// Delete recipe
await recipeService.deleteRecipe(id);

// Search
final results = recipeService.searchRecipes('pizza');

// Filter
final filtered = recipeService.filterByTags(['Italian']);
```

### MealPlanService
```dart
// Get current week plans
final plans = mealPlanService.getMealPlansForWeek(weekStart);

// Set meal plan
await mealPlanService.setMealPlan(date, 'dinner', recipeId);

// Remove meal
await mealPlanService.removeMealPlan(date, 'breakfast');

// Navigate weeks
mealPlanService.nextWeek();
mealPlanService.previousWeek();
mealPlanService.goToCurrentWeek();

// Generate shopping list
final items = mealPlanService.generateShoppingList(recipes);
```

### ShoppingService
```dart
// Add item
await shoppingService.addItem(item);

// Update item
await shoppingService.updateItem(item);

// Delete item
await shoppingService.deleteItem(id);

// Filter by category
final filtered = shoppingService.filterByCategory(Category.produce);
```

---

## 📦 Models

### Recipe
```dart
Recipe(
  id: 'unique-id',
  title: 'Recipe Name',
  description: 'Description',
  imageUrl: 'https://...',
  ingredients: ['item 1', 'item 2'],
  instructions: ['step 1', 'step 2'],
  cookingTimeMinutes: 30,
  servings: 4,
  userId: 'user-id',
  createdAt: DateTime.now(),
  tags: ['tag1', 'tag2'],
  notes: 'Optional notes',
  isImported: false,
)
```

### MealPlan
```dart
MealPlan(
  id: 'unique-id',
  date: DateTime(2025, 11, 1),
  mealType: 'breakfast', // or 'lunch', 'dinner'
  recipeId: 'recipe-id',
)
```

### ShoppingItem
```dart
ShoppingItem(
  id: 'unique-id',
  name: 'Item name',
  category: Category.produce,
  isChecked: false,
  recipeId: 'optional-recipe-id',
  userId: 'user-id',
)
```

---

## 🎨 Theme Customization

Edit `lib/utils/app_theme.dart`:

```dart
// Change primary color
static const Color primary = Color(0xFF6366F1); // Indigo

// Change secondary color
static const Color secondary = Color(0xFF10B981); // Emerald

// Change accent color
static const Color accent = Color(0xFFF59E0B); // Amber
```

---

## 🧪 Testing

### Run All Tests
```bash
flutter test
```

### Run Specific Test
```bash
flutter test test/recipe_detail_screen_test.dart
```

### Test Files
- `test/recipe_detail_screen_test.dart` - Recipe detail UI tests
- `test/shopping_list_screen_test.dart` - Shopping list UI tests
- `test/shopping_service_test.dart` - Shopping service logic tests

---

## 🐛 Common Issues

### Issue: Google Sign-In not working
**Solution**: Add client ID via `--dart-define`:
```bash
flutter run -d chrome --dart-define=GOOGLE_CLIENT_ID=your-client-id
```

### Issue: SharedPreferences data persists between runs
**Solution**: Clear data manually or use device settings

### Issue: Images not loading
**Solution**: Check URL validity, ensure internet connection

### Issue: Tests failing
**Solution**: Run `flutter clean && flutter pub get` then retry

---

## 📝 Code Snippets

### Using Provider
```dart
// Read service once
final recipeService = context.read<RecipeService>();

// Watch for changes
final recipeService = context.watch<RecipeService>();

// Consumer widget
Consumer<RecipeService>(
  builder: (context, service, child) {
    return Text('${service.recipes.length} recipes');
  },
)
```

### Navigation
```dart
// Push new screen
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => RecipeDetailScreen(recipe: recipe),
  ),
);

// Pop back
Navigator.pop(context);

// Replace current screen
Navigator.pushReplacement(
  context,
  MaterialPageRoute(builder: (context) => NewScreen()),
);
```

### Showing Dialogs
```dart
// Alert Dialog
showDialog(
  context: context,
  builder: (context) {
    return AlertDialog(
      title: Text('Title'),
      content: Text('Message'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('OK'),
        ),
      ],
    );
  },
);

// Bottom Sheet
showModalBottomSheet(
  context: context,
  builder: (context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Text('Bottom sheet content'),
    );
  },
);
```

---

## 🎯 File Locations

### Screens
- Cookbook: `lib/screens/home/cookbook_screen.dart`
- Recipe Detail: `lib/screens/home/recipe_detail_screen.dart`
- Add Recipe: `lib/screens/home/add_recipe_screen.dart`
- Import URL: `lib/screens/home/import_recipe_url_screen.dart`
- Meal Plan: `lib/screens/home/meal_plan_screen.dart`
- Search: `lib/screens/home/search_screen.dart`
- Shopping List: `lib/screens/home/shopping_list_screen.dart`
- Welcome: `lib/screens/onboarding/welcome.dart`

### Services
- Recipe: `lib/services/recipe_service.dart`
- Meal Plan: `lib/services/meal_plan_service.dart`
- Shopping: `lib/services/shopping_service.dart`
- Auth: `lib/services/auth_service.dart`

### Models
- Recipe: `lib/models/recipe.dart`
- Meal Plan: `lib/models/meal_plan.dart`
- Shopping Item: `lib/models/shopping_item.dart`

---

## 💡 Tips

1. **Local Data**: All data is stored locally using SharedPreferences
2. **Search**: Search works across title, description, tags, and ingredients
3. **Filters**: Can combine multiple filters for precise results
4. **Meal Planning**: Shopping list auto-generates from week's meals
5. **Timer**: Runs in background, survives screen navigation
6. **Import**: Currently simulated (2s delay) - real parsing would need implementation
7. **Tags**: Auto-complete available based on existing tags
8. **Edit Mode**: Accessible from recipe detail screen (edit icon)
9. **Sample Recipe**: Available on welcome screen for quick demo
10. **Persistence**: All changes saved automatically

---

## 🔗 Resources

- **Flutter Docs**: https://docs.flutter.dev
- **Provider Package**: https://pub.dev/packages/provider
- **Material 3**: https://m3.material.io
- **Firebase**: https://firebase.google.com/docs/flutter

---

*For detailed feature documentation, see `FEATURES.md`*
*For complete project overview, see `PROJECT_COMPLETE.md`*
