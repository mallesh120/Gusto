import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class GoogleSignInButton extends StatelessWidget {
  const GoogleSignInButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: Image.asset(
        'assets/icons/google_logo.png',
        height: 20,
        width: 20,
        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
      ),
      label: const Text('Sign in with Google'),
      onPressed: () async {
        final messenger = ScaffoldMessenger.of(context);
        try {
          await context.read<AuthService>().signInWithGoogle();
        } catch (e) {
          messenger.showSnackBar(
            SnackBar(content: Text('Google sign in failed: $e')),
          );
        }
      },
    );
  }
}
