import '../models/recipe.dart';
import 'youtube_service.dart';
import 'gemini_service.dart';

class RecipeExtractor {
  final GeminiService _geminiService = GeminiService();

  /// Extract recipe from YouTube video info using intelligent parsing
  /// First tries Gemini AI, then falls back to pattern matching
  Future<Recipe> extractFromYouTubeVideo(
    String url,
    YouTubeVideoInfo videoInfo,
  ) async {
    // Try Gemini AI extraction first
    try {
      final geminiRecipe = await _geminiService.extractRecipe(
        videoTitle: videoInfo.title,
        videoDescription: videoInfo.description,
        channelName: videoInfo.channelTitle,
      );

      if (geminiRecipe != null && geminiRecipe.isComplete) {
        print('✅ Gemini AI extracted recipe successfully');
        return _createRecipeFromGemini(url, videoInfo, geminiRecipe);
      }
    } catch (e) {
      print('Gemini extraction failed, using fallback: $e');
    }

    // Fallback to pattern-based extraction
    print('⚡ Using pattern-based extraction');
    return _extractUsingPatterns(url, videoInfo);
  }

  Recipe _createRecipeFromGemini(
    String url,
    YouTubeVideoInfo videoInfo,
    ExtractedRecipe geminiRecipe,
  ) {
    return Recipe(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: geminiRecipe.title.startsWith('YouTube Recipe:')
          ? geminiRecipe.title
          : 'YouTube Recipe: ${geminiRecipe.title}',
      description: geminiRecipe.description,
      imageUrl: videoInfo.thumbnailUrl,
      ingredients: geminiRecipe.ingredients,
      instructions: geminiRecipe.instructions,
      cookingTimeMinutes: geminiRecipe.cookingTime,
      servings: geminiRecipe.servings,
      userId: 'local_user',
      createdAt: DateTime.now(),
      tags: [...geminiRecipe.tags, 'YouTube'],
      notes: _generateNotesWithGemini(url, videoInfo, geminiRecipe.notes),
      isImported: true,
    );
  }

  String _generateNotesWithGemini(
    String url,
    YouTubeVideoInfo videoInfo,
    String geminiNotes,
  ) {
    final buffer = StringBuffer();
    buffer.writeln('Video source: $url');
    buffer.writeln('Channel: ${videoInfo.channelTitle}');
    buffer.writeln('Duration: ${videoInfo.duration} minutes');
    buffer.writeln();
    if (geminiNotes.isNotEmpty) {
      buffer.writeln('💡 Chef\'s Tips:');
      buffer.writeln(geminiNotes);
      buffer.writeln();
    }
    buffer.writeln('✨ Recipe extracted using AI from video content');
    return buffer.toString();
  }

  /// Fallback pattern-based extraction (original implementation)
  Future<Recipe> _extractUsingPatterns(
    String url,
    YouTubeVideoInfo videoInfo,
  ) async {
    // Simulate processing time
    await Future.delayed(const Duration(seconds: 2));

    // Parse ingredients and instructions from description
    final ingredients = _extractIngredients(videoInfo.description);
    final instructions = _extractInstructions(videoInfo.description);

    // Generate recipe title
    final title = _generateRecipeTitle(videoInfo.title);

    // Extract recipe description (first paragraph)
    final description = _extractDescription(videoInfo.description);

    return Recipe(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: description,
      imageUrl: videoInfo.thumbnailUrl,
      ingredients: ingredients.isNotEmpty ? ingredients : _generateDefaultIngredients(videoInfo),
      instructions: instructions.isNotEmpty ? instructions : _generateDefaultInstructions(videoInfo),
      cookingTimeMinutes: videoInfo.duration,
      servings: videoInfo.estimateServings(),
      userId: 'local_user',
      createdAt: DateTime.now(),
      tags: videoInfo.getTags(),
      notes: _generateNotes(url, videoInfo),
      isImported: true,
    );
  }

  String _generateRecipeTitle(String videoTitle) {
    // Clean up video title for recipe
    String title = videoTitle;
    
    // Remove common YouTube phrases
    final removePatterns = [
      RegExp(r'\s*\|.*$'), // Remove everything after |
      RegExp(r'\s*-.*$'), // Remove everything after -
      RegExp(r'\[.*?\]'), // Remove [brackets]
      RegExp(r'\(.*?\)'), // Remove (parentheses)
      RegExp(r'how to make\s+', caseSensitive: false),
      RegExp(r'recipe\s+video', caseSensitive: false),
      RegExp(r'cooking\s+tutorial', caseSensitive: false),
    ];

    for (final pattern in removePatterns) {
      title = title.replaceAll(pattern, '');
    }

    title = title.trim();
    
    // Add "YouTube Recipe: " prefix if not too long
    if (title.length < 50) {
      return 'YouTube Recipe: $title';
    }

    return title;
  }

  String _extractDescription(String fullDescription) {
    // Get first paragraph or first 200 characters
    final lines = fullDescription.split('\n');
    final firstParagraph = lines.isNotEmpty ? lines[0] : '';
    
    if (firstParagraph.length > 200) {
      return '${firstParagraph.substring(0, 197)}...';
    }

    return firstParagraph.isEmpty 
        ? 'A delicious recipe extracted from YouTube.' 
        : firstParagraph;
  }

  List<String> _extractIngredients(String description) {
    final ingredients = <String>[];
    final lines = description.split('\n');

    bool inIngredientsSection = false;
    
    for (final line in lines) {
      final trimmed = line.trim();
      
      // Check if we're entering ingredients section
      if (trimmed.toLowerCase().contains('ingredient')) {
        inIngredientsSection = true;
        continue;
      }

      // Check if we're leaving ingredients section
      if (inIngredientsSection && 
          (trimmed.toLowerCase().contains('instruction') ||
           trimmed.toLowerCase().contains('method') ||
           trimmed.toLowerCase().contains('step'))) {
        break;
      }

      // Extract ingredient lines
      if (inIngredientsSection && trimmed.isNotEmpty) {
        // Look for ingredient patterns: amount + unit + ingredient
        if (_looksLikeIngredient(trimmed)) {
          // Clean up the line
          String ingredient = trimmed;
          ingredient = ingredient.replaceFirst(RegExp(r'^[-•*]\s*'), '');
          if (ingredient.isNotEmpty) {
            ingredients.add(ingredient);
          }
        }
      }
    }

    return ingredients;
  }

  bool _looksLikeIngredient(String line) {
    // Check if line looks like an ingredient
    // Usually starts with number, bullet, or contains measurement words
    final patterns = [
      RegExp(r'^\d+'),  // Starts with number
      RegExp(r'^[-•*]'),  // Starts with bullet
      RegExp(r'\b(cup|tbsp|tsp|oz|lb|kg|g|ml|l|pinch|bunch|clove|piece)\b', caseSensitive: false),
    ];

    return patterns.any((pattern) => pattern.hasMatch(line)) &&
           !line.toLowerCase().contains('http') &&
           line.length < 100; // Ingredients are usually short
  }

  List<String> _extractInstructions(String description) {
    final instructions = <String>[];
    final lines = description.split('\n');

    bool inInstructionsSection = false;

    for (final line in lines) {
      final trimmed = line.trim();
      
      // Check if we're entering instructions section
      if (trimmed.toLowerCase().contains('instruction') ||
          trimmed.toLowerCase().contains('method') ||
          trimmed.toLowerCase().contains('steps')) {
        inInstructionsSection = true;
        continue;
      }

      // Extract instruction lines
      if (inInstructionsSection && trimmed.isNotEmpty) {
        if (_looksLikeInstruction(trimmed)) {
          // Clean up the line
          String instruction = trimmed;
          instruction = instruction.replaceFirst(RegExp(r'^\d+\.?\s*'), '');
          instruction = instruction.replaceFirst(RegExp(r'^[-•*]\s*'), '');
          
          if (instruction.isNotEmpty && instruction.length > 10) {
            instructions.add(instruction);
          }
        }
      }
    }

    return instructions;
  }

  bool _looksLikeInstruction(String line) {
    // Instructions usually contain action verbs and are longer
    final actionVerbs = [
      'heat', 'add', 'mix', 'stir', 'cook', 'boil', 'fry', 'bake',
      'chop', 'cut', 'dice', 'slice', 'pour', 'combine', 'whisk',
      'blend', 'serve', 'garnish', 'season', 'place', 'remove',
    ];

    final lowerLine = line.toLowerCase();
    return line.length > 20 &&
           actionVerbs.any((verb) => lowerLine.contains(verb)) &&
           !lowerLine.contains('http');
  }

  List<String> _generateDefaultIngredients(YouTubeVideoInfo videoInfo) {
    // Generate generic ingredients based on video tags and title
    final title = videoInfo.title.toLowerCase();
    final desc = videoInfo.description.toLowerCase();

    // Check for specific dishes
    if (title.contains('biryani') || desc.contains('biryani')) {
      return _getBiryaniIngredients();
    } else if (title.contains('pasta') || desc.contains('pasta')) {
      return _getPastaIngredients();
    } else if (title.contains('curry') || desc.contains('curry')) {
      return _getCurryIngredients();
    } else if (title.contains('pizza') || desc.contains('pizza')) {
      return _getPizzaIngredients();
    }

    // Generic ingredients
    return [
      'Main ingredient (see video for specifics)',
      'Salt to taste',
      'Black pepper to taste',
      'Cooking oil or butter',
      'Fresh herbs for garnish',
      '(Watch video for complete ingredient list)',
    ];
  }

  List<String> _generateDefaultInstructions(YouTubeVideoInfo videoInfo) {
    final channelTitle = videoInfo.channelTitle;
    
    return [
      'Watch the video for detailed visual instructions.',
      'Prepare all ingredients as shown by ${channelTitle.isNotEmpty ? channelTitle : 'the chef'}.',
      'Follow along with the video, pausing as needed.',
      'Pay attention to cooking times and temperatures mentioned.',
      'Taste and adjust seasonings as you go.',
      'Plate and serve as demonstrated in the video.',
      '',
      'Note: This is an auto-generated summary. Watch the full video for complete instructions.',
    ];
  }

  String _generateNotes(String url, YouTubeVideoInfo videoInfo) {
    return '''Video source: $url
Channel: ${videoInfo.channelTitle}
Duration: ${videoInfo.duration} minutes

💡 Tips:
• Watch the video for visual guidance
• Pause and rewind as needed while cooking
• The chef demonstrates techniques that are easier to see than read
• Subscribe to ${videoInfo.channelTitle} for more recipes!

⚠️ Note: Ingredients and instructions were auto-extracted from the video description. Watch the video for complete details.''';
  }

  // Predefined ingredient lists for common dishes
  List<String> _getBiryaniIngredients() {
    return [
      '2 cups basmati rice',
      '500g chicken or meat',
      '1 cup yogurt',
      '2 onions (sliced)',
      '3 tomatoes (chopped)',
      '2 tbsp ginger-garlic paste',
      'Fresh mint and cilantro',
      'Whole spices (bay leaf, cardamom, cloves, cinnamon)',
      'Biryani masala or garam masala',
      'Saffron soaked in milk',
      'Ghee or oil',
      'Salt to taste',
    ];
  }

  List<String> _getPastaIngredients() {
    return [
      '2 cups all-purpose flour',
      '3 large eggs',
      '1 tbsp olive oil',
      '1/2 tsp salt',
      'Semolina flour for dusting',
    ];
  }

  List<String> _getCurryIngredients() {
    return [
      'Main protein (chicken, lamb, or vegetables)',
      '2 onions (chopped)',
      '3 tomatoes (pureed)',
      '2 tbsp ginger-garlic paste',
      'Curry powder or spice blend',
      'Coconut milk or cream',
      'Cooking oil',
      'Fresh cilantro',
      'Salt to taste',
    ];
  }

  List<String> _getPizzaIngredients() {
    return [
      '2 1/2 cups all-purpose flour',
      '1 packet active dry yeast',
      '1 cup warm water',
      '2 tbsp olive oil',
      '1 tsp salt',
      '1 tsp sugar',
      'Pizza sauce',
      'Mozzarella cheese',
      'Toppings of choice',
    ];
  }
}
