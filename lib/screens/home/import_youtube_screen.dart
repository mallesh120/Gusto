import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/recipe.dart';
import '../../services/recipe_service.dart';
import '../../services/youtube_service.dart';
import '../../services/recipe_extractor.dart';
import '../../utils/app_theme.dart';
import 'recipe_detail_screen.dart';

class ImportFromYouTubeScreen extends StatefulWidget {
  const ImportFromYouTubeScreen({super.key});

  @override
  State<ImportFromYouTubeScreen> createState() => _ImportFromYouTubeScreenState();
}

class _ImportFromYouTubeScreenState extends State<ImportFromYouTubeScreen> {
  final _urlController = TextEditingController();
  final _youtubeService = YouTubeService();
  final _recipeExtractor = RecipeExtractor();
  
  bool _isLoading = false;
  String? _error;
  Recipe? _parsedRecipe;
  String? _videoThumbnail;

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Import from YouTube'),
      ),
      body: _parsedRecipe != null
          ? _buildPreview()
          : _buildUrlInput(),
    );
  }

  Widget _buildUrlInput() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.smart_display_rounded, color: Colors.red),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Extract Recipe from YouTube Video',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'We\'ll analyze the video title, description, and transcript to extract the recipe information.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _urlController,
            decoration: InputDecoration(
              labelText: 'YouTube Video URL',
              hintText: 'https://youtube.com/watch?v=...',
              prefixIcon: const Icon(Icons.link_rounded),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              errorText: _error,
            ),
            keyboardType: TextInputType.url,
            autofocus: true,
            onSubmitted: (_) => _importFromYouTube(),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _isLoading ? null : _importFromYouTube,
            icon: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.download_rounded),
            label: Text(_isLoading ? 'Extracting Recipe...' : 'Extract Recipe'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(16),
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: _importSampleYouTube,
            child: const Text('Try with sample video'),
          ),
          const SizedBox(height: 32),
          _buildInfoSection(),
        ],
      ),
    );
  }

  Widget _buildInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'How It Works',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            _buildInfoItem(
              icon: Icons.video_library_rounded,
              title: '1. Video Analysis',
              description: 'We fetch the video metadata and transcript',
            ),
            const SizedBox(height: 12),
            _buildInfoItem(
              icon: Icons.psychology_rounded,
              title: '2. AI Extraction',
              description: 'AI identifies ingredients and cooking steps',
            ),
            const SizedBox(height: 12),
            _buildInfoItem(
              icon: Icons.edit_rounded,
              title: '3. Review & Save',
              description: 'Review and edit before adding to cookbook',
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded, color: AppTheme.primary, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Note: This is a demo with simulated extraction. Full implementation would use YouTube Data API + AI.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.primary,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppTheme.primary, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPreview() {
    final recipe = _parsedRecipe!;
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle_rounded, color: AppTheme.secondary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Recipe Extracted!',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              Text(
                                'Review and edit before saving',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (_videoThumbnail != null) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Stack(
                      children: [
                        Image.network(
                          _videoThumbnail!,
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            height: 200,
                            color: AppTheme.surfaceVariant,
                            child: Icon(
                              Icons.video_library_rounded,
                              size: 48,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ),
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withValues(alpha: 0.3),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 12,
                          left: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.smart_display_rounded, color: Colors.white, size: 14),
                                const SizedBox(width: 4),
                                const Text(
                                  'YouTube',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                Text(
                  recipe.title,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                if (recipe.description.isNotEmpty) ...[
                  Text(
                    recipe.description,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                  ),
                  const SizedBox(height: 16),
                ],
                Row(
                  children: [
                    Icon(Icons.timer_rounded, size: 16, color: AppTheme.textSecondary),
                    const SizedBox(width: 4),
                    Text('${recipe.cookingTimeMinutes} min'),
                    const SizedBox(width: 16),
                    Icon(Icons.people_rounded, size: 16, color: AppTheme.textSecondary),
                    const SizedBox(width: 4),
                    Text('${recipe.servings} servings'),
                  ],
                ),
                const SizedBox(height: 24),
                _buildSection('Ingredients', recipe.ingredients),
                const SizedBox(height: 24),
                _buildSection('Instructions', recipe.instructions),
                if (recipe.notes.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Text(
                    'Chef\'s Notes',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.accent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.accent.withValues(alpha: 0.3)),
                    ),
                    child: Text(recipe.notes),
                  ),
                ],
              ],
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _parsedRecipe = null;
                        _videoThumbnail = null;
                        _urlController.clear();
                        _error = null;
                      });
                    },
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _saveRecipe,
                    child: const Text('Save Recipe'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSection(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        ...items.asMap().entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title == 'Ingredients' ? '•' : '${entry.key + 1}.',
                  style: TextStyle(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(entry.value),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Future<void> _importFromYouTube() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) {
      setState(() => _error = 'Please enter a YouTube URL');
      return;
    }

    if (!_isYouTubeUrl(url)) {
      setState(() => _error = 'Please enter a valid YouTube URL');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Extract video ID
      final videoId = _extractVideoId(url);
      if (videoId == null) {
        throw Exception('Could not extract video ID from URL');
      }

      // Fetch video info from YouTube
      final videoInfo = await _youtubeService.getVideoInfo(videoId);
      if (videoInfo == null) {
        throw Exception('Could not fetch video information');
      }

      // Extract recipe using AI-powered parser
      final recipe = await _recipeExtractor.extractFromYouTubeVideo(url, videoInfo);
      
      setState(() {
        _parsedRecipe = recipe;
        _videoThumbnail = videoInfo.thumbnailUrl;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to extract recipe: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  bool _isYouTubeUrl(String url) {
    return url.contains('youtube.com/watch') || 
           url.contains('youtu.be/') ||
           url.contains('youtube.com/shorts/');
  }

  String? _extractVideoId(String url) {
    // Extract video ID from various YouTube URL formats
    final patterns = [
      RegExp(r'youtube\.com/watch\?v=([a-zA-Z0-9_-]+)'),
      RegExp(r'youtu\.be/([a-zA-Z0-9_-]+)'),
      RegExp(r'youtube\.com/shorts/([a-zA-Z0-9_-]+)'),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(url);
      if (match != null && match.groupCount >= 1) {
        return match.group(1);
      }
    }
    return null;
  }

  void _importSampleYouTube() {
    _urlController.text = 'https://www.youtube.com/watch?v=nf9tq7cNkTQ';
    _importFromYouTube();
  }

  Future<void> _saveRecipe() async {
    if (_parsedRecipe == null) return;

    try {
      await context.read<RecipeService>().addRecipe(_parsedRecipe!);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Recipe from YouTube saved successfully!')),
        );
        
        // Navigate to the recipe detail screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => RecipeDetailScreen(recipe: _parsedRecipe!),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving recipe: ${e.toString()}'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }
}
