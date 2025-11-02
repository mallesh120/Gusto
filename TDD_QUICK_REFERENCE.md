# TDD Quick Reference - Gusto App

## 🚦 The TDD Cycle

```
RED → GREEN → REFACTOR → REPEAT
```

### 1️⃣ RED: Write a Failing Test
```dart
test('should return recipe by ID', () {
  final recipe = recipeService.getById('123');
  expect(recipe.id, '123');
});
```
**Result**: ❌ Test fails (method doesn't exist)

### 2️⃣ GREEN: Make It Pass
```dart
Recipe? getById(String id) {
  return recipes.firstWhere((r) => r.id == id);
}
```
**Result**: ✅ Test passes

### 3️⃣ REFACTOR: Improve Code
```dart
Recipe? getById(String id) {
  try {
    return recipes.firstWhere((r) => r.id == id);
  } catch (e) {
    return null;
  }
}
```
**Result**: ✅ Tests still pass, code is better

---

## 📋 Quick Commands

```bash
# Run all tests
flutter test

# Run specific test
flutter test test/services/recipe_service_test.dart

# Watch mode (auto-rerun)
flutter test --watch

# With coverage
flutter test --coverage

# View coverage
genhtml coverage/lcov.info -o coverage/html && open coverage/html/index.html
```

---

## 📝 Test Template

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:gusto/services/my_service.dart';

void main() {
  group('MyService', () {
    late MyService service;

    setUp(() {
      service = MyService();
    });

    tearDown(() {
      // Cleanup
    });

    group('methodName', () {
      test('should do X when Y', () {
        // Arrange
        final input = 'test';
        
        // Act
        final result = service.method(input);
        
        // Assert
        expect(result, expected);
      });

      test('should handle error case', () {
        expect(
          () => service.method(null),
          throwsA(isA<ArgumentError>()),
        );
      });
    });
  });
}
```

---

## 🎯 Common Assertions

```dart
// Equality
expect(actual, equals(expected));
expect(actual, expected); // shorthand

// Booleans
expect(value, isTrue);
expect(value, isFalse);
expect(value, isNull);
expect(value, isNotNull);

// Types
expect(value, isA<String>());
expect(value, isA<List<Recipe>>());

// Strings
expect(text, contains('substring'));
expect(text, startsWith('prefix'));
expect(text, endsWith('suffix'));
expect(text, matches(RegExp(r'\d+')));

// Numbers
expect(value, greaterThan(5));
expect(value, lessThan(10));
expect(value, greaterThanOrEqualTo(5));
expect(value, inRange(0, 100));

// Collections
expect(list, isEmpty);
expect(list, isNotEmpty);
expect(list, hasLength(3));
expect(list, contains(item));
expect(list, containsAll([item1, item2]));

// Exceptions
expect(() => method(), throwsException);
expect(() => method(), throwsA(isA<TypeError>()));

// Async
await expectLater(future, completion(expected));
await expectLater(stream, emits(value));
await expectLater(stream, emitsInOrder([1, 2, 3]));
```

---

## 🔄 Testing Async Code

```dart
test('should load data asynchronously', () async {
  final data = await service.loadData();
  expect(data, isNotNull);
});

test('should emit values from stream', () {
  expectLater(
    service.dataStream,
    emitsInOrder([1, 2, 3, emitsDone]),
  );
});
```

---

## 🎭 Mocking (when needed)

```dart
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks([ApiService])
import 'my_test.mocks.dart';

test('should call API', () {
  final mockApi = MockApiService();
  when(mockApi.fetch()).thenAnswer((_) async => data);
  
  final result = await service.process();
  
  verify(mockApi.fetch()).called(1);
  expect(result, expected);
});
```

---

## ✅ TDD Checklist

### Before Starting
- [ ] Is the feature clearly defined?
- [ ] Do I understand the expected behavior?
- [ ] Have I identified edge cases?

### Writing Tests
- [ ] Test name describes behavior, not implementation
- [ ] One test = one concept
- [ ] Arrange-Act-Assert structure
- [ ] Tests are independent
- [ ] No hardcoded values (use constants/fixtures)

### After Writing Code
- [ ] All tests pass
- [ ] Code is minimal (no over-engineering)
- [ ] Edge cases covered
- [ ] Error cases handled
- [ ] Code is readable

### Before Committing
- [ ] `flutter test` runs successfully
- [ ] No skipped tests
- [ ] Coverage is adequate
- [ ] Tests are documented

---

## 🚨 Common Mistakes to Avoid

❌ **Testing implementation details**
```dart
test('should call private method', () { ... }); // BAD
```

✅ **Test behavior/outcomes**
```dart
test('should return formatted recipe', () { ... }); // GOOD
```

---

❌ **Multiple assertions testing different things**
```dart
test('should work', () {
  expect(recipe.title, 'Test');
  expect(recipe.servings, 4);
  expect(recipe.tags, contains('Indian')); // BAD
});
```

✅ **One test, one concept**
```dart
test('should have correct title', () {
  expect(recipe.title, 'Test'); // GOOD
});

test('should have correct servings', () {
  expect(recipe.servings, 4); // GOOD
});
```

---

❌ **Skipping tests**
```dart
skip: test('complex test', () { ... }); // BAD
```

✅ **Fix or remove**
```dart
test('complex test', () { ... }); // GOOD
```

---

## 💡 Pro Tips

1. **Red is good!** - Failing tests mean you're doing TDD right
2. **Keep tests fast** - Mock slow dependencies
3. **Test first, always** - Resist the urge to code first
4. **Refactor often** - Don't wait until code is messy
5. **Read test failures** - They tell you what's broken
6. **Use descriptive names** - Tests are documentation
7. **Test edge cases** - Empty lists, null values, errors
8. **One change at a time** - Small steps, always green

---

## 🎓 Learning Path

1. Start with simple unit tests (models, utilities)
2. Move to service tests (with mocking)
3. Add widget tests
4. Learn integration testing
5. Master TDD workflow

---

## 📞 Need Help?

- Check `TDD_GUIDE.md` for detailed information
- See `TEST_SUITE_SUMMARY.md` for current status
- Review existing tests in `test/` directory
- Ask team members during code review

---

**Remember:** Tests are not a burden, they're an investment in code quality! 🚀
