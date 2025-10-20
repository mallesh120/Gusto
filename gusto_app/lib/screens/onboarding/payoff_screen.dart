import 'package:flutter/material.dart';

class PayoffScreen extends StatelessWidget {
  final VoidCallback onNext;

  const PayoffScreen({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Voilà! Your first recipe is saved.",
              style: Theme.of(context).textTheme.headlineLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Card(
              elevation: 4.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Placeholder for Hero Image
                    Container(
                      height: 150,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: const Center(
                          child: Icon(Icons.photo_camera,
                              size: 50, color: Colors.grey)),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Classic Lemon Tart", // Mock data
                      style: Theme.of(context)
                          .textTheme
                          .headlineLarge
                          ?.copyWith(fontSize: 20),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                        "A buttery crust and a bright, zesty lemon filling make this a timeless dessert."),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: onNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              child: const Text('Save & Sync My Cookbook'),
            ),
          ],
        ),
      ),
    );
  }
}
