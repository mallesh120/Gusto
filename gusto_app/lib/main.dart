import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:gusto_app/screens/auth_wrapper.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ProviderScope(child: GustoApp()));
}

class GustoApp extends StatelessWidget {
  const GustoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gusto',
      theme: ThemeData(
        primaryColor: const Color(0xFFE2725B),
        scaffoldBackgroundColor: const Color(0xFFF5F5DC),
        textTheme: TextTheme(
          headlineLarge: GoogleFonts.lora(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          bodyMedium: GoogleFonts.lato(
            fontSize: 16,
          ),
        ),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          secondary: const Color(0xFF8F9779),
          primary: const Color(0xFFE2725B)
        ),
      ),
      home: AuthWrapper(),
    );
  }
}
