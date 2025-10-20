import 'dart:async';
import 'package:flutter/material.dart';

class LoadingScreen extends StatefulWidget {
  final VoidCallback onNext;

  const LoadingScreen({super.key, required this.onNext});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  final List<String> _tips = [
    "Tip: Roll a lemon on the counter before squeezing to get more juice.",
    "Tip: Add a pinch of sugar to tomato-based sauces to balance the acidity.",
    "Tip: Use a damp paper towel to keep herbs fresh in the refrigerator.",
    "Tip: Let meat rest after cooking for a juicier result.",
  ];
  int _currentTipIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      setState(() {
        _currentTipIndex = (_currentTipIndex + 1) % _tips.length;
      });
    });

    // Simulate a network request
    Future.delayed(const Duration(seconds: 5), widget.onNext);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 40),
            // Placeholder for the illustration
            const Icon(Icons.lightbulb_outline, size: 100, color: Colors.grey),
            const SizedBox(height: 20),
            Text(
              _tips[_currentTipIndex],
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
