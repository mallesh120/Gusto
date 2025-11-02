# YouTube Recipe Import Feature 🎥

## Overview
Extract recipes directly from YouTube cooking videos! This feature analyzes video content and converts it into a structured recipe format that you can save to your cookbook.

## How It Works

### User Experience
1. **Paste YouTube URL**: Enter any YouTube video URL (watch, shorts, or youtu.be format)
2. **AI Extraction**: The app analyzes the video metadata, description, and transcript
3. **Review & Edit**: Preview the extracted recipe with video thumbnail
4. **Save to Cookbook**: Add to your collection with one tap

### Supported YouTube URL Formats
- `https://www.youtube.com/watch?v=VIDEO_ID`
- `https://youtu.be/VIDEO_ID`
- `https://www.youtube.com/shorts/VIDEO_ID`

## Features

### 📹 Video Analysis
- **Thumbnail Display**: Shows the video's maxresdefault thumbnail
- **YouTube Badge**: Red YouTube overlay on preview
- **Video ID Extraction**: Automatically parses from various URL formats

### 🤖 AI-Powered Extraction (Simulated)
The feature demonstrates how AI would extract:
- **Recipe Title**: From video title
- **Description**: From video description
- **Ingredients**: With quantities and measurements
- **Instructions**: Step-by-step numbered directions
- **Timing**: Cooking time estimation
- **Servings**: Number of portions
- **Chef's Notes**: Tips and tricks from the video

### 🎨 User Interface
- **Info Card**: Explains the 3-step process (Analysis → AI → Review)
- **Loading State**: 3-second extraction animation
- **Success Feedback**: Green checkmark when complete
- **Video Thumbnail**: High-quality preview with gradient overlay
- **Action Buttons**: Cancel or Save to cookbook

## Technical Implementation

### Current (Demo) Version
```dart
// Simulated extraction with Future.delayed
await Future.delayed(const Duration(seconds: 3));

// Returns sample recipe (Homemade Pasta)
Recipe(
  title: 'YouTube Recipe: Perfect Homemade Pasta',
  ingredients: [...],
  instructions: [...],
  tags: ['Italian', 'Pasta', 'Homemade', 'YouTube'],
  notes: 'Video source: $url\n\nTip from chef: ...',
  isImported: true,
)
```

### Production Implementation Roadmap

For a real implementation, you would integrate:

#### 1. YouTube Data API v3
```dart
import 'package:googleapis/youtube/v3.dart';

// Fetch video metadata
final video = await youtube.videos.list(['snippet', 'contentDetails'], 
  id: [videoId]
);

final title = video.items[0].snippet.title;
final description = video.items[0].snippet.description;
final duration = video.items[0].contentDetails.duration;
```

#### 2. YouTube Transcript API
```dart
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

// Get video captions/transcript
final yt = YoutubeExplode();
final manifest = await yt.videos.closedCaptions.getManifest(videoId);
final trackInfo = manifest.getByLanguage('en');
final track = await yt.videos.closedCaptions.get(trackInfo);
final transcript = track.captions.map((e) => e.text).join(' ');
```

#### 3. AI/LLM Integration
Choose one of:

**OpenAI GPT-4**
```dart
import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';

final openAI = OpenAI.instance.build(token: apiKey);
final request = CompleteText(
  prompt: '''
Extract a recipe from this YouTube video content:
Title: $title
Description: $description
Transcript: $transcript

Return structured JSON with: title, ingredients[], instructions[], 
cookingTime, servings, tags[], notes
''',
  model: GptTurbo0301Model(),
);
final response = await openAI.onCompleteText(request: request);
```

**Google Gemini**
```dart
import 'package:google_generative_ai/google_generative_ai.dart';

final model = GenerativeModel(
  model: 'gemini-pro',
  apiKey: apiKey,
);
final content = [Content.text(prompt)];
final response = await model.generateContent(content);
```

**Anthropic Claude**
```dart
import 'package:anthropic_sdk/anthropic_sdk.dart';

final client = Anthropic(apiKey: apiKey);
final response = await client.messages.create(
  model: 'claude-3-sonnet-20240229',
  messages: [Message(role: 'user', content: prompt)],
);
```

#### 4. Structured Parsing
```dart
class RecipeExtractor {
  Future<Recipe> extractFromVideo(String videoUrl) async {
    // 1. Extract video ID
    final videoId = _extractVideoId(videoUrl);
    
    // 2. Fetch YouTube metadata
    final metadata = await _fetchVideoMetadata(videoId);
    
    // 3. Get transcript
    final transcript = await _fetchTranscript(videoId);
    
    // 4. Combine data for AI
    final prompt = _buildExtractionPrompt(metadata, transcript);
    
    // 5. Call LLM API
    final llmResponse = await _callLLM(prompt);
    
    // 6. Parse JSON response
    final recipeData = jsonDecode(llmResponse);
    
    // 7. Create Recipe object
    return Recipe.fromJson(recipeData);
  }
}
```

## Required Dependencies

Add to `pubspec.yaml`:

```yaml
dependencies:
  # YouTube data fetching
  youtube_explode_dart: ^2.0.0
  googleapis: ^13.0.0
  googleapis_auth: ^1.6.0
  
  # Choose ONE AI provider:
  
  # Option 1: OpenAI
  chat_gpt_sdk: ^3.0.0
  
  # Option 2: Google Gemini
  google_generative_ai: ^0.2.0
  
  # Option 3: Anthropic Claude
  anthropic_sdk: ^0.1.0
  
  # HTTP client
  http: ^1.2.0
  
  # JSON parsing
  json_annotation: ^4.8.1
```

## API Keys Setup

### 1. YouTube Data API
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project
3. Enable "YouTube Data API v3"
4. Create credentials (API key)
5. Store in environment:
```dart
const String youtubeApiKey = String.fromEnvironment('YOUTUBE_API_KEY');
```

### 2. AI Provider API Key
Choose one and sign up:
- [OpenAI](https://platform.openai.com/): GPT-4 access
- [Google AI Studio](https://makersuite.google.com/): Gemini API
- [Anthropic](https://console.anthropic.com/): Claude access

Store securely:
```dart
const String aiApiKey = String.fromEnvironment('AI_API_KEY');
```

## Usage Examples

### Basic Usage
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const ImportFromYouTubeScreen(),
  ),
);
```

### From Import Hub
Already integrated in `lib/screens/onboarding/import_recipe.dart`:
```dart
// Red gradient YouTube option
_OptionCard(
  icon: Icons.smart_display_rounded,
  title: 'Import from YouTube',
  description: 'Extract recipe from cooking video',
  gradient: const LinearGradient(
    colors: [Color(0xFFFF0000), Color(0xFFCC0000)],
  ),
  onTap: () => Navigator.push(...),
)
```

## Recommended Video Sources

Works great with these cooking channels:
- **Tasty** - Quick recipe videos
- **Bon Appétit** - Professional chef tutorials
- **Binging with Babish** - Detailed recipe walkthroughs
- **Joshua Weissman** - Step-by-step cooking
- **Chef John (Food Wishes)** - Classic recipes
- **Adam Ragusea** - Home cooking focused
- **Ethan Chlebowski** - Recipe science

## Limitations (Current Demo)

- ⚠️ **Simulated Extraction**: Returns hardcoded Homemade Pasta recipe
- ⚠️ **No Real API Calls**: 3-second delay simulates processing
- ⚠️ **Fixed Output**: Same recipe for all URLs
- ⚠️ **No Transcript Analysis**: Would need real implementation
- ⚠️ **Basic Validation**: Only checks URL format

## Future Enhancements

1. **Multi-Language Support**: Detect video language, translate recipes
2. **Timestamp Linking**: Link recipe steps to video timestamps
3. **Ingredient Recognition**: Computer vision on video frames
4. **Batch Import**: Save entire playlists as cookbook
5. **Creator Attribution**: Link back to original chef/channel
6. **Smart Tags**: Auto-tag cuisine type, dietary restrictions
7. **Difficulty Detection**: Analyze complexity from video
8. **Equipment List**: Extract required tools/appliances
9. **Nutritional Estimation**: Calculate from ingredients
10. **Shopping List Auto-Add**: Import ingredients directly to list

## Cost Considerations

### YouTube Data API
- **Quota**: 10,000 units/day (free tier)
- **Video List**: 1 unit
- **Typical Usage**: ~1 unit per import
- **Cost**: Free for most apps

### AI API Costs (Approximate)
- **OpenAI GPT-4**: $0.01-0.03 per recipe extraction
- **Google Gemini Pro**: Free tier available, then ~$0.001 per recipe
- **Anthropic Claude**: $0.015 per recipe extraction

**Recommendation**: Use Gemini Pro for cost-effective production deployment.

## Privacy & Legal

- ✅ **User Data**: YouTube URLs only, no personal data stored
- ✅ **Video Content**: Public videos only, respects copyright
- ✅ **Attribution**: Saves original video URL in recipe notes
- ⚠️ **Terms of Service**: Must comply with YouTube API ToS
- ⚠️ **Commercial Use**: Review YouTube and AI provider policies

## Testing

Test with these sample URLs:
```dart
// Italian pasta tutorial
'https://www.youtube.com/watch?v=dQw4w9WgXcQ'

// Quick 5-minute recipe
'https://youtu.be/dQw4w9WgXcQ'

// Shorts format
'https://www.youtube.com/shorts/dQw4w9WgXcQ'
```

## Contributing

To enable real YouTube extraction:

1. Add API keys to `.env`:
```
YOUTUBE_API_KEY=your_key_here
AI_API_KEY=your_key_here
```

2. Update `_extractRecipeFromYouTube()` in `import_youtube_screen.dart`
3. Add error handling for API failures
4. Test with various video types
5. Implement caching to reduce API calls

## Support

For issues or questions:
- Check YouTube Data API [documentation](https://developers.google.com/youtube/v3)
- Review AI provider docs
- Test with sample videos first
- Monitor API quota usage

---

**Status**: ✅ Feature Complete (Demo Version)  
**Lines of Code**: ~570 lines  
**Dependencies**: 0 new (demo), 4+ for production  
**Ready for**: User testing and production API integration  

🎬 Happy cooking with YouTube recipes!
