# Test-Driven Development Guide for Gusto

## Overview
This document outlines the testing strategy and TDD approach for the Gusto app.

## Test Structure

```
test/
├── models/
│   ├── recipe_test.dart
│   ├── ingredient_test.dart
│   └── shopping_item_test.dart
├── services/
│   ├── youtube_service_test.dart
│   ├── gemini_service_test.dart
│   ├── recipe_extractor_test.dart
│   ├── recipe_service_test.dart
│   ├── auth_service_test.dart
│   └── firestore_service_test.dart
├── widgets/
│   ├── recipe_card_test.dart
│   └── tip_carousel_test.dart
└── screens/
    ├── home/
    │   ├── cookbook_screen_test.dart
    │   └── recipe_detail_test.dart
    └── onboarding/
        └── welcome_test.dart
```

## TDD Workflow

### 1. Red Phase - Write Failing Tests
```dart
test('should extract video ID from YouTube URL', () {
  final videoId = youtubeService.extractVideoId('https://youtube.com/watch?v=ABC123');
  expect(videoId, 'ABC123');
});
```

### 2. Green Phase - Make Tests Pass
```dart
String? extractVideoId(String url) {
  final regex = RegExp(r'(?:youtube\.com\/watch\?v=|youtu\.be\/)([^&]+)');
  final match = regex.firstMatch(url);
  return match?.group(1);
}
```

### 3. Refactor Phase - Improve Code Quality
- Clean up implementation
- Remove duplication
- Improve readability
- Ensure all tests still pass

## Running Tests

### Run all tests
```bash
flutter test
```

### Run specific test file
```bash
flutter test test/services/youtube_service_test.dart
```

### Run tests with coverage
```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

### Run tests in watch mode (during development)
```bash
flutter test --watch
```

## Test Categories

### Unit Tests
- Test individual functions and methods
- Mock external dependencies
- Fast execution
- **Location:** `test/services/`, `test/models/`

### Widget Tests
- Test individual widgets
- Verify UI rendering
- Test user interactions
- **Location:** `test/widgets/`

### Integration Tests
- Test feature flows
- Test screen navigation
- Test state management
- **Location:** `test/screens/`

## Best Practices

### 1. Test Naming Convention
```dart
group('ServiceName', () {
  group('methodName', () {
    test('should do something when condition', () {
      // Arrange
      // Act
      // Assert
    });
  });
});
```

### 2. AAA Pattern
```dart
test('should calculate total correctly', () {
  // Arrange - Setup
  final calculator = Calculator();
  
  // Act - Execute
  final result = calculator.add(2, 3);
  
  // Assert - Verify
  expect(result, 5);
});
```

### 3. Test One Thing at a Time
```dart
// Good
test('should return true when user is authenticated', () { ... });
test('should return false when user is not authenticated', () { ... });

// Bad
test('should handle authentication correctly', () { 
  // Testing multiple scenarios
});
```

### 4. Use Descriptive Test Names
```dart
// Good
test('should extract recipe with 10+ steps from YouTube video with detailed description', () { ... });

// Bad
test('test extraction', () { ... });
```

### 5. Mock External Dependencies
```dart
class MockYouTubeService extends Mock implements YouTubeService {}

test('should use Gemini when YouTube service succeeds', () {
  final mockYouTube = MockYouTubeService();
  when(mockYouTube.getVideoInfo(any)).thenAnswer((_) async => videoInfo);
  
  // Test with mock
});
```

## Coverage Goals

- **Overall Coverage:** 80%+
- **Services:** 90%+
- **Models:** 95%+
- **Widgets:** 70%+
- **Screens:** 60%+

## Continuous Integration

### GitHub Actions Workflow
```yaml
name: Tests
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter test --coverage
      - uses: codecov/codecov-action@v2
```

## TDD for New Features

### Example: Adding Recipe Sharing Feature

#### 1. Write Test First
```dart
test('should generate shareable link for recipe', () {
  final recipe = Recipe(...);
  final shareService = ShareService();
  
  final link = shareService.generateLink(recipe);
  
  expect(link, startsWith('https://gusto.app/recipe/'));
  expect(link, contains(recipe.id));
});
```

#### 2. Run Test (Should Fail)
```bash
flutter test test/services/share_service_test.dart
# Expected: Test fails because ShareService doesn't exist
```

#### 3. Implement Minimum Code
```dart
class ShareService {
  String generateLink(Recipe recipe) {
    return 'https://gusto.app/recipe/${recipe.id}';
  }
}
```

#### 4. Run Test Again (Should Pass)
```bash
flutter test test/services/share_service_test.dart
# Expected: All tests pass
```

#### 5. Refactor
- Add error handling
- Add validation
- Improve code structure
- Ensure tests still pass

## Mocking Strategy

### Use mockito for service mocks
```dart
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks([FirestoreService, AuthService])
void main() {
  late MockFirestoreService mockFirestore;
  
  setUp(() {
    mockFirestore = MockFirestoreService();
  });
}
```

### Use fake implementations for complex objects
```dart
class FakeRecipe implements Recipe {
  @override
  String get id => 'fake-id';
  
  @override
  String get title => 'Fake Recipe';
  // ... other properties
}
```

## Common Test Patterns

### Testing Async Code
```dart
test('should load recipes asynchronously', () async {
  final recipes = await recipeService.loadRecipes();
  expect(recipes, isNotEmpty);
});
```

### Testing Streams
```dart
test('should emit recipes from stream', () {
  final stream = recipeService.watchRecipes();
  
  expectLater(stream, emits(isA<List<Recipe>>()));
});
```

### Testing Errors
```dart
test('should throw exception when API key is invalid', () {
  expect(
    () => geminiService.extractRecipe(...),
    throwsA(isA<ApiException>()),
  );
});
```

## Golden Tests for UI

```dart
testWidgets('RecipeCard renders correctly', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: RecipeCard(recipe: testRecipe),
    ),
  );
  
  await expectLater(
    find.byType(RecipeCard),
    matchesGoldenFile('goldens/recipe_card.png'),
  );
});
```

## Test Data Management

### Create test fixtures
```dart
// test/fixtures/recipes.dart
final testRecipeBiryani = Recipe(
  id: 'test-1',
  title: 'Chicken Biryani',
  description: 'Aromatic rice dish',
  // ... other fields
);

final testRecipeGulabJamun = Recipe(
  id: 'test-2',
  title: 'Gulab Jamun',
  description: 'Sweet dessert',
  // ... other fields
);
```

## Performance Testing

```dart
test('should load 1000 recipes in under 1 second', () {
  final stopwatch = Stopwatch()..start();
  
  recipeService.loadRecipes(count: 1000);
  
  stopwatch.stop();
  expect(stopwatch.elapsedMilliseconds, lessThan(1000));
});
```

## Remember

1. **Write tests before code** (TDD)
2. **Keep tests simple and focused**
3. **Test behavior, not implementation**
4. **Maintain high code coverage**
5. **Run tests frequently**
6. **Don't skip tests**
7. **Refactor with confidence**

## Next Steps

1. ✅ Create test structure
2. ✅ Write initial unit tests
3. ⏳ Add integration tests
4. ⏳ Set up CI/CD pipeline
5. ⏳ Achieve 80%+ coverage
6. ⏳ Add golden tests for widgets
7. ⏳ Implement snapshot testing
