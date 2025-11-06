import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/app_theme.dart';
import '../../services/subscription_service.dart';
import '../../services/auth_service.dart';
import '../../models/user_subscription.dart';

class PremiumScreen extends StatelessWidget {
  const PremiumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final subscriptionService = Provider.of<SubscriptionService>(context);
    final user = authService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Upgrade to Premium'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.primary,
                    AppTheme.secondary,
                  ],
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.star_rounded,
                    size: 80,
                    color: Colors.amber[300],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Gusto Premium',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Unlock unlimited recipes and features',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Features List
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Premium Features',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 24),
                  _FeatureItem(
                    icon: Icons.all_inclusive,
                    title: 'Unlimited Recipe Imports',
                    description: 'Import as many YouTube recipes as you want',
                    color: AppTheme.primary,
                  ),
                  _FeatureItem(
                    icon: Icons.restaurant_menu,
                    title: 'Unlimited Recipe Storage',
                    description: 'Save unlimited custom recipes',
                    color: AppTheme.secondary,
                  ),
                  _FeatureItem(
                    icon: Icons.calendar_month,
                    title: 'Advanced Meal Planning',
                    description: 'Plan meals for 30+ days ahead',
                    color: const Color(0xFF95E1D3),
                  ),
                  _FeatureItem(
                    icon: Icons.analytics,
                    title: 'Nutritional Information',
                    description: 'See detailed nutrition facts for all recipes',
                    color: const Color(0xFF4ECDC4),
                  ),
                  _FeatureItem(
                    icon: Icons.share,
                    title: 'Recipe Sharing',
                    description: 'Share your recipes with friends and family',
                    color: const Color(0xFFFF6B6B),
                  ),
                  _FeatureItem(
                    icon: Icons.download,
                    title: 'Export Your Data',
                    description: 'Download all your recipes and meal plans',
                    color: const Color(0xFFFECE2F),
                  ),
                  _FeatureItem(
                    icon: Icons.auto_awesome,
                    title: 'AI Recipe Generation',
                    description: 'Generate custom recipes with AI',
                    color: Colors.purple,
                  ),
                  _FeatureItem(
                    icon: Icons.support_agent,
                    title: 'Priority Support',
                    description: 'Get help when you need it',
                    color: Colors.indigo,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Free Tier Limits
            if (!subscriptionService.isPremium) ...[
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.orange[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.orange[700]),
                        const SizedBox(width: 12),
                        Text(
                          'Your Current Limits',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange[900],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _LimitIndicator(
                      label: 'Recipe Imports',
                      current: subscriptionService.subscription?.recipesImported ?? 0,
                      limit: UserSubscription.freeRecipeImportLimit,
                    ),
                    const SizedBox(height: 12),
                    _LimitIndicator(
                      label: 'Saved Recipes',
                      current: subscriptionService.subscription?.recipesCreated ?? 0,
                      limit: UserSubscription.freeRecipeCreateLimit,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],

            // Pricing
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppTheme.primary.withOpacity(0.1), AppTheme.secondary.withOpacity(0.1)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.primary, width: 2),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Premium Lifetime',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '\$',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '29',
                              style: TextStyle(
                                fontSize: 56,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primary,
                                height: 1,
                              ),
                            ),
                            const Text(
                              '.99',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'One-time payment • Lifetime access',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: subscriptionService.isPremium
                                ? null
                                : () => _handleUpgrade(context, user?.uid),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: AppTheme.primary,
                              foregroundColor: Colors.white,
                            ),
                            child: Text(
                              subscriptionService.isPremium ? 'Already Premium ✓' : 'Upgrade Now',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '30-day money-back guarantee',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleUpgrade(BuildContext context, String? userId) async {
    if (userId == null) return;

    try {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      final subscriptionService = Provider.of<SubscriptionService>(context, listen: false);
      
      // In production, integrate with payment provider (Stripe, RevenueCat, etc.)
      // For now, simulate upgrade
      await Future.delayed(const Duration(seconds: 1));
      await subscriptionService.upgradeToPremium(userId);

      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading
        
        // Show success
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.celebration, color: Colors.amber),
                SizedBox(width: 12),
                Text('Welcome to Premium!'),
              ],
            ),
            content: const Text(
              'You now have unlimited access to all premium features. Enjoy!',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop(); // Close premium screen
                },
                child: const Text('Start Cooking!'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Upgrade failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LimitIndicator extends StatelessWidget {
  final String label;
  final int current;
  final int limit;

  const _LimitIndicator({
    required this.label,
    required this.current,
    required this.limit,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (current / limit).clamp(0.0, 1.0);
    final isAtLimit = current >= limit;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '$current / $limit',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isAtLimit ? Colors.red[700] : AppTheme.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation(
              isAtLimit ? Colors.red[700] : Colors.orange[700],
            ),
            minHeight: 8,
          ),
        ),
      ],
    );
  }
}
