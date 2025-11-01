import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'firebase_options.dart';
import 'utils/app_theme.dart';
import 'services/auth_service.dart';
import 'services/shopping_service.dart';
import 'screens/onboarding/welcome.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Initialize GoogleSignIn singleton once at startup.
  // For web you must provide a clientId (or set a meta tag in web/index.html).
  // You can pass client IDs via `--dart-define=GOOGLE_CLIENT_ID=<id>` and
  // `--dart-define=GOOGLE_SERVER_CLIENT_ID=<id>` when running.
  const String googleClientId = String.fromEnvironment('GOOGLE_CLIENT_ID', defaultValue: '');
  const String googleServerClientId = String.fromEnvironment('GOOGLE_SERVER_CLIENT_ID', defaultValue: '');
  if (kIsWeb) {
    if (googleClientId.isNotEmpty) {
      await GoogleSignIn.instance.initialize(
        clientId: googleClientId,
        serverClientId: googleServerClientId.isNotEmpty ? googleServerClientId : null,
      );
    } else {
      // If no client ID is provided via --dart-define, the web plugin will
      // try to read a <meta name="google-signin-client_id"> tag in
      // `web/index.html`. If neither is present, attempts to authenticate on
      // web will fail with an assertion. Log a friendly reminder.
      // Do NOT call initialize() without a clientId on web — it will assert.
      // The developer should add a meta tag or pass --dart-define values.
      // Example to run with a client id:
      // flutter run -d chrome --dart-define=GOOGLE_CLIENT_ID=your-client-id
      debugPrint('GoogleSignIn: running on Web without GOOGLE_CLIENT_ID; '
          'ensure you set a meta tag in web/index.html or pass --dart-define.');
    }
  } else {
    await GoogleSignIn.instance.initialize();
  }
  runApp(const GustoApp());
}

class GustoApp extends StatelessWidget {
  const GustoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>(
          create: (_) => AuthService(),
        ),
        ChangeNotifierProvider(
          create: (_) => ShoppingService(),
        ),
        StreamProvider(
          create: (context) => context.read<AuthService>().authStateChanges,
          initialData: null,
        ),
      ],
      child: MaterialApp(
        title: 'Gusto',
        theme: AppTheme.theme,
        home: const OnboardingScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}