import 'package:flutter/material.dart';
import 'package:gusto_app/models/recipe_model.dart';
import 'package:wakelock/wakelock.dart';

class CookingModeScreen extends StatefulWidget {
  final Recipe recipe;

  const CookingModeScreen({super.key, required this.recipe});

  @override
  State<CookingModeScreen> createState() => _CookingModeScreenState();
}

class _CookingModeScreenState extends State<CookingModeScreen> {
  int _currentStep = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    Wakelock.enable();
  }

  @override
  void dispose() {
    _pageController.dispose();
    Wakelock.disable();
    super.dispose();
  }

  void _onNext() {
    if (_currentStep < widget.recipe.instructions.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    }
  }

  void _onPrevious() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.recipe.instructions.length,
        onPageChanged: (index) {
          setState(() {
            _currentStep = index;
          });
        },
        itemBuilder: (context, index) {
          return GestureDetector(
            onTapUp: (details) {
              final width = MediaQuery.of(context).size.width;
              if (details.globalPosition.dx > width / 2) {
                _onNext();
              } else {
                _onPrevious();
              }
            },
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Placeholder for looping video
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: const Center(
                        child: Icon(Icons.videocam, size: 80, color: Colors.grey),
                      ),
                    ),
                    const SizedBox(height: 40),
                    Text(
                      'Step ${index + 1}',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      widget.recipe.instructions[index],
                      style: Theme.of(context).textTheme.displaySmall,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
