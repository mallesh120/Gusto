import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';
import 'import_recipe.dart';
import '../../widgets/google_sign_in_button.dart';
import '../home/shopping_list_screen.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.cream,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Text(
                '"Anyone can cook."',
                style: Theme.of(context).textTheme.displayLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                '- Auguste Gusteau',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              const GoogleSignInButton(),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ImportRecipeScreen(),
                  ),
                ),
                child: const Text("Let's Get Started"),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ShoppingListScreen(),
                  ),
                ),
                child: const Text('Open Shopping List'),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}