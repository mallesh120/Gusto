// Web implementation: render the platform-provided Google Sign-In button by
// using google_sign_in_web.web_only.renderButton(). Also listen to the
// authenticationEvents stream so that when the platform button completes
// authentication we exchange the ID token for a Firebase credential.
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:google_sign_in_web/web_only.dart' as web;
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class GoogleSignInButton extends StatefulWidget {
  const GoogleSignInButton({super.key});

  @override
  State<GoogleSignInButton> createState() => _GoogleSignInButtonState();
}

class _GoogleSignInButtonState extends State<GoogleSignInButton> {
  @override
  void initState() {
    super.initState();
    // Capture the AuthService once to avoid using BuildContext in async
    // callbacks which can cause analyzer warnings.
    final auth = Provider.of<AuthService>(context, listen: false);

    // Subscribe to authenticationEvents so that when the platform button
    // completes authentication, we exchange the ID token for a Firebase
    // credential in the app.
    GoogleSignIn.instance.authenticationEvents.listen((event) async {
      // The sign-in event contains the authenticated user.
      if (event is GoogleSignInAuthenticationEventSignIn) {
        final account = event.user;
        try {
          await auth.signInWithGoogleAccount(account);
        } catch (e) {
          if (!mounted) return;
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Google sign in failed: $e')),
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // If the underlying plugin indicates authenticate is supported, we can
    // show a regular button as a fallback. Otherwise render the platform
    // button via the web-only `renderButton()` which returns a Widget.
    final signIn = GoogleSignIn.instance;
    // If a web client id was provided via --dart-define, prefer to initialize
    // and render the platform button. If not, show a helpful instruction so
    // the developer doesn't hit the plugin initialization assertion.
    const String googleClientId = String.fromEnvironment('GOOGLE_CLIENT_ID', defaultValue: '');
    if (signIn.supportsAuthenticate()) {
      return ElevatedButton.icon(
        icon: const Icon(Icons.login, size: 20),
        label: const Text('Sign in with Google'),
        onPressed: () async {
          try {
            await context.read<AuthService>().signInWithGoogle();
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Google sign in failed: $e')),
              );
            }
          }
        },
      );
    }

    // If no client id was provided via dart-define, we must avoid calling
    // web.renderButton() because the web plugin requires initialization with
    // a client id (or a meta tag in web/index.html). Calling renderButton()
    // before initialization throws a runtime assertion. Provide a clear
    // fallback that instructs the developer to configure the client id.
    if (googleClientId.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ElevatedButton.icon(
            icon: const Icon(Icons.login, size: 20),
            label: const Text('Sign in with Google'),
            onPressed: null,
          ),
          const SizedBox(height: 8),
          const Text(
            'Configure Google Sign-In for web: add a meta tag to web/index.html or pass --dart-define=GOOGLE_CLIENT_ID=YOUR_CLIENT_ID when running.',
          ),
        ],
      );
    }

    // We have a client id from dart-define — ensure the plugin is initialized
    // before rendering the platform button. Use a FutureBuilder so we don't
    // call renderButton() synchronously and risk the plugin asserting.
    return FutureBuilder<void>(
      future: GoogleSignIn.instance.initialize(clientId: googleClientId),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const SizedBox(
            height: 48,
            child: Center(child: CircularProgressIndicator()),
          );
        }
        // Initialization complete — safe to render the platform-provided
        // button widget from google_sign_in_web.
        return web.renderButton();
      },
    );
  }
}
