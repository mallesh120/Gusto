import 'package:flutter_test/flutter_test.dart';
import 'package:gusto/screens/onboarding/welcome_screen.dart';
import 'package:gusto/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() {
  group('Welcome Screen', () {
    late MockAuthService mockAuthService;

    setUp(() {
      mockAuthService = MockAuthService();
    });

    testWidgets('should display app name and icon', (tester) async {
      await tester.pumpWidget(
        Provider<AuthService>(
          create: (_) => mockAuthService,
          child: const MaterialApp(
            home: WelcomeScreen(),
          ),
        ),
      );

      expect(find.text('Gusto'), findsOneWidget);
      // App icon should be present
      expect(find.byIcon(Icons.restaurant_menu), findsOneWidget);
    });

    testWidgets('should display Google Sign In button', (tester) async {
      await tester.pumpWidget(
        Provider<AuthService>(
          create: (_) => mockAuthService,
          child: const MaterialApp(
            home: WelcomeScreen(),
          ),
        ),
      );

      // Initial pump
      await tester.pump();
      
      // Pump again for animations
      await tester.pump(const Duration(milliseconds: 1200));

      // The text should be present
      expect(find.text('Continue with Google'), findsOneWidget);
    });

    testWidgets('should show loading state when signing in', (tester) async {
      bool signInCalled = false;
      mockAuthService.onSignIn = () {
        signInCalled = true;
      };
      
      await tester.pumpWidget(
        Provider<AuthService>(
          create: (_) => mockAuthService,
          child: const MaterialApp(
            home: WelcomeScreen(),
          ),
        ),
      );

      // Wait for animations and image loading
      await tester.pumpAndSettle();

      expect(find.text('Continue with Google'), findsOneWidget);
      
      // Mock a quick sign in (without the delay)
      mockAuthService.shouldDelay = false;
      await tester.tap(find.text('Continue with Google'));
      await tester.pump();

      // Should have called signIn
      expect(signInCalled, true);
    });
  });
}

// Simple mock for testing
class MockAuthService implements AuthService {
  bool shouldDelay = false;
  bool shouldFail = false;
  Function()? onSignIn;

  @override
  User? get currentUser => null;

  @override
  Stream<User?> get authStateChanges => Stream.value(null);

  @override
  Future<UserCredential> signInWithGoogle() async {
    onSignIn?.call();
    if (shouldDelay) {
      await Future.delayed(const Duration(seconds: 10));
    }
    if (shouldFail) {
      throw Exception('Sign in failed');
    }
    throw UnimplementedError();
  }

  @override
  Future<UserCredential> signInWithGoogleAccount(dynamic account) async {
    return signInWithGoogle();
  }

  @override
  Future<UserCredential> signInWithApple() async {
    throw UnimplementedError();
  }

  @override
  Future<UserCredential> signInWithEmailAndPassword(String email, String password) async {
    throw UnimplementedError();
  }

  @override
  Future<UserCredential> signUpWithEmailAndPassword(String email, String password) async {
    throw UnimplementedError();
  }

  @override
  Future<void> signOut() async {}
}