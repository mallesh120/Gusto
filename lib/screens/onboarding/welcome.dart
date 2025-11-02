import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';
import '../../models/recipe.dart';
import 'import_recipe.dart';
import '../../widgets/google_sign_in_button.dart';
import '../home/shopping_list_screen.dart';
import '../home/recipe_detail_screen.dart';
import '../home/cookbook_screen.dart';
import '../home/meal_plan_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primary.withOpacity(0.05),
              AppTheme.secondary.withOpacity(0.05),
              AppTheme.background,
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - 48,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                const SizedBox(height: 40),
                Expanded(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppTheme.primary,
                                  AppTheme.secondary,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(32),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primary.withOpacity(0.3),
                                  blurRadius: 24,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.restaurant_menu,
                              size: 64,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 48),
                          Text(
                            'Gusto',
                            style: Theme.of(context)
                                .textTheme
                                .displayLarge
                                ?.copyWith(
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 16),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32),
                            child: Text(
                              '"Anyone can cook."\n- Auguste Gusteau',
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                    color: AppTheme.textSecondary,
                                    height: 1.6,
                                    fontStyle: FontStyle.italic,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      const GoogleSignInButton(),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ImportRecipeScreen(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            elevation: 2,
                            shadowColor: AppTheme.primary.withOpacity(0.4),
                          ),
                          child: const Text("Let's Get Started"),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const CookbookScreen(),
                              ),
                            );
                          },
                          child: const Text('View My Cookbook'),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const MealPlanScreen(),
                              ),
                            );
                          },
                          child: const Text('Meal Planner'),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ShoppingListScreen(),
                              ),
                            );
                          },
                          child: const Text('Open Shopping List'),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: TextButton.icon(
                          onPressed: () {
                            // Sample recipe for demonstration
                            final sampleRecipe = Recipe(
                              id: 'sample-1',
                              title: 'Classic Margherita Pizza',
                              description: 'A traditional Italian pizza with fresh mozzarella, tomatoes, and basil.',
                              imageUrl: 'https://images.unsplash.com/photo-1574071318508-1cdbab80d002?w=800',
                              ingredients: [
                                '2 cups all-purpose flour',
                                '1 tsp active dry yeast',
                                '3/4 cup warm water',
                                '2 tbsp olive oil',
                                '1 tsp salt',
                                '1 cup tomato sauce',
                                '8 oz fresh mozzarella cheese',
                                'Fresh basil leaves',
                                '1 tbsp olive oil for drizzling',
                              ],
                              instructions: [
                                'Mix warm water and yeast. Let it sit for 5 minutes until foamy.',
                                'In a large bowl, combine flour and salt. Add yeast mixture and olive oil.',
                                'Knead the dough for 8-10 minutes until smooth and elastic.',
                                'Place dough in an oiled bowl, cover, and let rise for 1 hour.',
                                'Preheat oven to 475°F (245°C). If using a pizza stone, place it in the oven.',
                                'Roll out dough to desired thickness on a floured surface.',
                                'Spread tomato sauce evenly, leaving a 1-inch border.',
                                'Tear mozzarella and distribute over the sauce.',
                                'Bake for 12-15 minutes until crust is golden and cheese is bubbly.',
                                'Remove from oven, top with fresh basil and drizzle with olive oil.',
                              ],
                              cookingTimeMinutes: 30,
                              servings: 4,
                              userId: 'demo',
                              createdAt: DateTime.now(),
                              tags: ['Italian', 'Pizza', 'Vegetarian', 'Easy'],
                              notes: 'For best results, use a pizza stone. You can also add your favorite toppings!',
                              isImported: false,
                            );

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RecipeDetailScreen(recipe: sampleRecipe),
                              ),
                            );
                          },
                          icon: const Icon(Icons.visibility_rounded),
                          label: const Text('View Sample Recipe'),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}