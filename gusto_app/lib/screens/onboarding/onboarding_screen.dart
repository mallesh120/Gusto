import 'package:flutter/material.dart';
import 'package:gusto_app/screens/auth_screen.dart';
import 'package:gusto_app/screens/onboarding/welcome_screen.dart';
import 'package:gusto_app/screens/onboarding/aha_moment_screen.dart';
import 'package:gusto_app/screens/onboarding/loading_screen.dart';
import 'package:gusto_app/screens/onboarding/payoff_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();

  void _onNext() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeIn,
    );
  }

  void _onFinish() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const AuthScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          WelcomeScreen(onNext: _onNext),
          AhaMomentScreen(onNext: _onNext),
          LoadingScreen(onNext: _onNext),
          PayoffScreen(onNext: _onFinish),
        ],
      ),
    );
  }
}
