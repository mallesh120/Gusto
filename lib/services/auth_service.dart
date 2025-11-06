import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // Use the singleton GoogleSignIn instance (new 7.x API)
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Email/Password Sign Up
  Future<UserCredential> signUpWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Email/Password Sign In
  Future<UserCredential> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Google Sign In
  Future<UserCredential> signInWithGoogle() async {
    try {
      // On web, use Firebase's built-in popup/redirect flow instead of google_sign_in
      // The google_sign_in package doesn't support authenticate() on web
      if (kIsWeb) {
        debugPrint('🌐 Using Firebase popup for web Google Sign In');
        GoogleAuthProvider googleProvider = GoogleAuthProvider();
        googleProvider.addScope('email');
        googleProvider.addScope('profile');
        
        // Set custom parameters to improve UX
        googleProvider.setCustomParameters({
          'prompt': 'select_account', // Always show account selection
        });
        
        // Use popup for web - requires authorized domains in Firebase Console
        // Go to: Firebase Console > Authentication > Settings > Authorized domains
        // Add: localhost, your-domain.com
        return await _auth.signInWithPopup(googleProvider);
      }

      final GoogleSignIn signIn = _googleSignIn;

      // Interactive authenticate where supported, otherwise attempt lightweight
      // authentication and fall back to authenticate.
      // Determine signed-in user. `authenticate` returns a non-null account
      // while `attemptLightweightAuthentication` may return null.
      final GoogleSignInAccount googleUser;
      if (signIn.supportsAuthenticate()) {
        googleUser = await signIn.authenticate();
      } else {
        final GoogleSignInAccount? maybeUser =
            await signIn.attemptLightweightAuthentication();
        googleUser = maybeUser ?? await signIn.authenticate();
      }

      // Authentication contains the ID token (OpenID Connect ID token)
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      // Authorization tokens (access token) are obtained via the authorization client.
      String? accessToken;
      try {
        // Request common scopes for access token if needed. Adjust scopes as required.
        const List<String> scopes = <String>['email', 'openid'];
        final GoogleSignInClientAuthorization? authorization =
            await googleUser.authorizationClient.authorizationForScopes(scopes);
        accessToken = authorization?.accessToken;
      } catch (_) {
        accessToken = null;
      }

      final credential = GoogleAuthProvider.credential(
        accessToken: accessToken,
        idToken: googleAuth.idToken,
      );

      return await _auth.signInWithCredential(credential);
    } catch (e) {
      // Debug logging to help diagnose web auth issues during development.
      try {
        debugPrint('❌ AuthService.signInWithGoogle error: ${e.runtimeType} -> $e');
        if (e is FirebaseAuthException) {
          debugPrint('   FirebaseAuthException code=${e.code} message=${e.message}');
          if (e.code == 'configuration-not-found') {
            debugPrint('   ⚠️ Firebase Auth configuration issue:');
            debugPrint('   1. Go to Firebase Console > Authentication');
            debugPrint('   2. Enable Google Sign-In provider');
            debugPrint('   3. Add authorized domain (localhost for testing)');
          }
        }
      } catch (_) {}
      throw _handleAuthError(e);
    }
  }

  // Sign in to Firebase using an already-obtained GoogleSignInAccount.
  // This is used by web where the platform button performs the authentication
  // and the app needs to exchange the ID token for a Firebase credential.
  Future<UserCredential> signInWithGoogleAccount(
    GoogleSignInAccount account,
  ) async {
    try {
      final GoogleSignInAuthentication googleAuth = account.authentication;

      String? accessToken;
      try {
        const List<String> scopes = <String>['email', 'openid'];
        final GoogleSignInClientAuthorization? authorization =
            await account.authorizationClient.authorizationForScopes(scopes);
        accessToken = authorization?.accessToken;
      } catch (_) {
        accessToken = null;
      }

      final credential = GoogleAuthProvider.credential(
        accessToken: accessToken,
        idToken: googleAuth.idToken,
      );

      return await _auth.signInWithCredential(credential);
    } catch (e) {
      // Debug logging to help diagnose web auth issues during development.
      try {
        debugPrint('AuthService.signInWithGoogleAccount error: ${e.runtimeType} -> $e');
        if (e is FirebaseAuthException) {
          debugPrint('FirebaseAuthException code=${e.code} message=${e.message}');
        }
      } catch (_) {}
      throw _handleAuthError(e);
    }
  }

  // Apple Sign In
  Future<UserCredential> signInWithApple() async {
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      return await _auth.signInWithCredential(oauthCredential);
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Sign Out
  Future<void> signOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  String _handleAuthError(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'weak-password':
          return 'The password provided is too weak.';
        case 'email-already-in-use':
          return 'An account already exists for that email.';
        case 'invalid-email':
          return 'The email address is not valid.';
        case 'user-not-found':
          return 'No user found for that email.';
        case 'wrong-password':
          return 'Wrong password provided.';
        case 'popup-closed-by-user':
          return 'Sign in cancelled.';
        case 'popup-blocked':
          return 'Sign in popup was blocked. Please allow popups for this site.';
        case 'cancelled-popup-request':
          return 'Sign in cancelled.';
        case 'network-request-failed':
          return 'Network error. Please check your internet connection.';
        case 'configuration-not-found':
          return 'Google Sign-In is not properly configured. Please contact support.';
        case 'auth/invalid-api-key':
          return 'Invalid Firebase configuration. Please check your setup.';
        case 'unauthorized-domain':
          return 'This domain is not authorized for Google Sign-In.';
        default:
          return 'Authentication error: ${error.message}';
      }
    }
    return error.toString();
  }
}