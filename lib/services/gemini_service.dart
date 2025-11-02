import 'dart:convert';
import 'package:http/http.dart' as http;

class GeminiService {
  // Get your API key from: https://makersuite.google.com/app/apikey
  static const String _apiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: 'YOUR_GEMINI_API_KEY_HERE',
  );

  static const String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta';
  static const String _model = 'gemini-2.0-flash';

  GeminiService();

  /// Extract recipe from YouTube video metadata using Gemini AI REST API
  Future<ExtractedRecipe?> extractRecipe({
    required String videoTitle,
    required String videoDescription,
    required String channelName,
  }) async {
    if (_apiKey == 'YOUR_GEMINI_API_KEY_HERE') {
      print('⚠️ Gemini API key not configured. Using fallback extraction.');
      print('   Run with: flutter run --dart-define=GEMINI_API_KEY=your_key');
      return null;
    }

    print('🤖 Gemini AI: Analyzing video...');
    print('   Title: $videoTitle');
    print('   Description length: ${videoDescription.length} chars');

    try {
      final prompt = _buildExtractionPrompt(
        title: videoTitle,
        description: videoDescription,
        channel: channelName,
      );

      print('🤖 Gemini AI: Sending request to $_model...');
      
      final url = Uri.parse('$_baseUrl/models/$_model:generateContent?key=$_apiKey');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt}
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.3,
            'topK': 40,
            'topP': 0.95,
            'maxOutputTokens': 8192,
          }
        }),
      );

      print('🤖 Gemini AI: Response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        
        if (jsonResponse['candidates'] != null && 
            jsonResponse['candidates'].isNotEmpty &&
            jsonResponse['candidates'][0]['content'] != null &&
            jsonResponse['candidates'][0]['content']['parts'] != null &&
            jsonResponse['candidates'][0]['content']['parts'].isNotEmpty) {
          
          final text = jsonResponse['candidates'][0]['content']['parts'][0]['text'];
          
          print('🤖 Gemini AI: Received response');
          print('   Response preview: ${text.substring(0, text.length > 100 ? 100 : text.length)}...');
          
          final recipe = _parseGeminiResponse(text);
          
          print('✅ Gemini AI: Recipe extracted!');
          print('   Title: ${recipe.title}');
          print('   Ingredients: ${recipe.ingredients.length}');
          print('   Instructions: ${recipe.instructions.length} steps');
          
          return recipe;
        } else {
          print('❌ Gemini AI: Unexpected response structure');
          print('   Response: ${response.body}');
        }
      } else {
        print('❌ Gemini AI: HTTP ${response.statusCode}');
        print('   Error: ${response.body}');
      }
    } catch (e, stackTrace) {
      print('❌ Gemini extraction error: $e');
      print('   Stack trace: $stackTrace');
    }

    return null;
  }

  String _buildExtractionPrompt({
    required String title,
    required String description,
    required String channel,
  }) {
    return '''You are a professional chef AI with extensive culinary knowledge. Extract or GENERATE a COMPLETE, DETAILED recipe that allows someone to cook this dish WITHOUT watching the video.

VIDEO TITLE: $title
CHANNEL: $channel
VIDEO DESCRIPTION:
$description

CRITICAL MISSION: The user needs a COMPLETE recipe they can follow from start to finish without the video. If the description lacks details, USE YOUR CULINARY EXPERTISE to provide standard, authentic preparation steps for this dish.

Return ONLY valid JSON:
{
  "title": "Clean dish name",
  "description": "Appetizing 2-3 sentence description",
  "ingredients": ["Exact quantity + ingredient", ...],
  "instructions": ["Detailed step 1", "Detailed step 2", ...],
  "cookingTime": 30,
  "servings": 4,
  "tags": ["cuisine", "dish type", ...],
  "notes": "Chef tips and warnings"
}

REQUIREMENTS:

INGREDIENTS (15+ items for complex dishes):
- Exact quantities: "2 cups basmati rice", "500g chicken breast", "1/2 tsp salt"
- Include EVERYTHING needed: oil, water, salt, garnishes
- Group by type if helpful (For the curry / For the rice / For garnish)
- Based on dish name if description lacks details

INSTRUCTIONS (MINIMUM 10-15 STEPS):
You MUST provide complete cooking steps even if video description is vague.

ALWAYS include these phases:
1. PREP (2-3 steps): Wash, soak, chop, marinate
2. MISE EN PLACE (1-2 steps): Prepare all ingredients, gather equipment
3. COOKING BASE (3-4 steps): Heat oil, cook aromatics, build flavors
4. MAIN COOKING (4-6 steps): Cook protein/main ingredient with specific times
5. ASSEMBLY (2-3 steps): Combine, layer, or mix components
6. FINAL COOKING (1-2 steps): Final heat application (baking, dum, simmering)
7. FINISHING (2-3 steps): Rest, garnish, plate, serve

FORMAT each step like this:
"Heat 3 tablespoons ghee in a heavy-bottomed pot over medium-high heat until shimmering (about 2 minutes)"
"Add sliced onions and fry for 10-12 minutes, stirring occasionally, until deep golden brown and caramelized"
"Add chicken pieces and sear on all sides for 5-7 minutes until exterior is golden and meat is 70% cooked"

INCLUDE in every step:
- Specific amounts ("3 tbsp", "500g", "2 cups")
- Exact times ("10 minutes", "until golden", "2-3 hours")
- Heat levels ("medium-high", "low heat", "350°F")
- Visual/texture cues ("until golden brown", "knife inserted comes clean", "bubbling gently")
- Why when important ("this creates steam for layering", "seals in juices")

EXAMPLES BY DISH TYPE:

For Biryani - 15+ steps:
1. Wash and soak rice
2. Marinate chicken with yogurt and spices
3. Boil water for rice
4. Heat ghee, fry onions until golden
5. Add whole spices, bloom them
6. Add ginger-garlic paste, cook out raw smell
7. Add chicken, sear all sides
8. Add tomatoes, cook down to paste
9. Add yogurt marinade, cook curry
10. Parboil rice to 70% done
11. Layer rice over curry
12. Add saffron milk, fried onions, herbs
13. Seal pot, cook on high 3 min
14. Reduce to low, dum cook 25-30 min
15. Rest 5 min, then gently mix and serve

For Pasta - 10+ steps:
For Curry - 12+ steps:
For Baking - 12+ steps:

If description says "watch video for details":
IGNORE that and provide complete standard recipe for the dish based on title.

If uncertain about exact recipe:
1. Identify dish type from title
2. Provide authentic traditional recipe for that dish
3. Note: "Traditional preparation method provided"

NEVER write:
❌ "Watch video for details"
❌ "See video for ingredients"
❌ "Follow video instructions"
❌ "Prepare as shown"

ALWAYS write:
✅ Complete, specific, actionable steps
✅ Every single ingredient with quantity
✅ Exact cooking times and temperatures
✅ Multiple detailed steps for each phase

Remember: Someone should be able to cook this dish PERFECTLY using ONLY your recipe, without ever seeing the video.''';
  }

  ExtractedRecipe _parseGeminiResponse(String responseText) {
    try {
      // Remove markdown code blocks if present
      String jsonText = responseText.trim();
      
      // Remove markdown JSON code block markers
      if (jsonText.startsWith('```json')) {
        jsonText = jsonText.substring(7);
      } else if (jsonText.startsWith('```')) {
        jsonText = jsonText.substring(3);
      }
      
      if (jsonText.endsWith('```')) {
        jsonText = jsonText.substring(0, jsonText.length - 3);
      }
      
      jsonText = jsonText.trim();

      final Map<String, dynamic> recipeJson = jsonDecode(jsonText);

      return ExtractedRecipe(
        title: recipeJson['title'] ?? 'Untitled Recipe',
        description: recipeJson['description'] ?? '',
        ingredients: (recipeJson['ingredients'] as List?)
            ?.map((e) => e.toString())
            .toList() ?? [],
        instructions: (recipeJson['instructions'] as List?)
            ?.map((e) => e.toString())
            .toList() ?? [],
        cookingTime: recipeJson['cookingTime'] ?? 30,
        servings: recipeJson['servings'] ?? 4,
        tags: (recipeJson['tags'] as List?)
            ?.map((e) => e.toString())
            .toList() ?? [],
        notes: recipeJson['notes'] ?? '',
      );
    } catch (e) {
      print('⚠️ Error parsing Gemini response: $e');
      print('   Response text: $responseText');
      
      // Return a basic recipe structure
      return ExtractedRecipe(
        title: 'Parse Error',
        description: 'Failed to parse AI response',
        ingredients: [],
        instructions: [],
        cookingTime: 30,
        servings: 4,
        tags: [],
        notes: 'Error: $e',
      );
    }
  }
}

class ExtractedRecipe {
  final String title;
  final String description;
  final List<String> ingredients;
  final List<String> instructions;
  final int cookingTime;
  final int servings;
  final List<String> tags;
  final String notes;

  ExtractedRecipe({
    required this.title,
    required this.description,
    required this.ingredients,
    required this.instructions,
    required this.cookingTime,
    required this.servings,
    required this.tags,
    required this.notes,
  });

  bool get isComplete => ingredients.isNotEmpty && instructions.isNotEmpty;

  @override
  String toString() {
    return 'ExtractedRecipe(title: $title, ingredients: ${ingredients.length}, instructions: ${instructions.length})';
  }
}
