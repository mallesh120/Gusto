// Conditional import: web implementation will be used when running on web,
// otherwise the IO implementation will be used.
// Conditional export: re-export the platform-specific implementation so the
// `GoogleSignInButton` symbol is available to the rest of the app.
export 'google_sign_in_button_io.dart'
    if (dart.library.html) 'google_sign_in_button_web.dart';

// The imported file must export a `class GoogleSignInButton extends StatelessWidget`.
