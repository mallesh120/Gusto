import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';

class ImportRecipeScreen extends StatefulWidget {
  const ImportRecipeScreen({super.key});

  @override
  State<ImportRecipeScreen> createState() => _ImportRecipeScreenState();
}

class _ImportRecipeScreenState extends State<ImportRecipeScreen> {
  final _urlController = TextEditingController();
  bool _isLoading = false;

  Future<void> _importRecipe() async {
    if (_urlController.text.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    // TODO: Implement recipe import logic
    await Future.delayed(const Duration(seconds: 2)); // Simulate API call

    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.cream,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.brown),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Import Recipe',
                style: Theme.of(context).textTheme.displayLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _urlController,
                decoration: InputDecoration(
                  hintText: 'Paste a recipe link here...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _importRecipe,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text('Add to my Cookbook'),
              ),
              if (!_isLoading) ...[
                const SizedBox(height: 32),
                const Text(
                  'Supported websites:',
                  style: TextStyle(
                    color: AppTheme.brown,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  '• AllRecipes\n• Food Network\n• NYT Cooking\n• Simply Recipes',
                  style: TextStyle(color: AppTheme.brown),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}