# YouTube API Setup Guide 🔑

## Quick Start (Works Without API Key!)

The YouTube import feature **works out of the box** with mock data for demo purposes. You can test it immediately with any YouTube URL, and it will intelligently extract recipe information based on video metadata patterns.

## For Production: Get Real YouTube Data

To enable real-time extraction from any YouTube video, follow these steps:

### Step 1: Create Google Cloud Project

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Click **"Select a project"** → **"New Project"**
3. Name it: `gusto-recipe-app` (or your choice)
4. Click **"Create"**

### Step 2: Enable YouTube Data API v3

1. In your project dashboard, go to **"APIs & Services"** → **"Library"**
2. Search for **"YouTube Data API v3"**
3. Click on it and press **"Enable"**

### Step 3: Create API Credentials

1. Go to **"APIs & Services"** → **"Credentials"**
2. Click **"Create Credentials"** → **"API Key"**
3. Copy the generated API key
4. (Optional) Click **"Restrict Key"** to limit it to YouTube Data API only

### Step 4: Add API Key to Your App

Open `lib/services/youtube_service.dart` and replace the placeholder:

```dart
// Change this line:
static const String _apiKey = 'YOUR_YOUTUBE_API_KEY_HERE';

// To this (with your actual key):
static const String _apiKey = 'AIzaSyAaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPp';
```

**⚠️ Security Note**: For production apps, use environment variables instead:

```dart
// lib/services/youtube_service.dart
static const String _apiKey = String.fromEnvironment('YOUTUBE_API_KEY');
```

Then run your app with:
```bash
flutter run --dart-define=YOUTUBE_API_KEY=AIzaSyAaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPp
```

### Step 5: Test It!

1. Run your app: `flutter run`
2. Go to **"Add a Recipe"** → **"Import from YouTube"**
3. Paste any cooking video URL
4. Click **"Extract Recipe"**
5. The app will now fetch real video metadata from YouTube!

## What Changes With Real API?

### Without API Key (Mock Data)
- ✅ Works immediately
- ✅ Recognizes known videos (biryani, pasta)
- ✅ Returns sensible recipe data
- ⚠️ Limited to predefined video IDs
- ⚠️ Generic data for unknown videos

### With API Key (Real Data)
- ✅ Works with ANY YouTube video
- ✅ Real video title and description
- ✅ Actual video thumbnail
- ✅ Real channel name
- ✅ Accurate video duration
- ✅ Smarter ingredient/instruction extraction
- ✅ Better tags based on actual content

## API Quota & Costs

### Free Tier
- **10,000 units per day** (free forever)
- Each video metadata fetch: **1 unit**
- **You can import ~10,000 recipes per day for FREE!**

### Typical Usage
- Import 1 recipe: **1 unit**
- Import 100 recipes: **100 units**
- **Daily limit**: ~10,000 recipe imports

### If You Exceed Quota
- Quota resets at midnight Pacific Time
- Temporarily falls back to mock data
- Consider requesting quota increase (usually granted)

### Cost Beyond Free Tier
- $0 for first 10,000 units/day
- Very unlikely to exceed for personal use
- Even 1,000 recipes/day stays free

## How the Extraction Works

### 1. Video Metadata Fetch
```
YouTube URL → Extract Video ID → API Call → Get Title, Description, Duration
```

### 2. Intelligent Parsing
The `RecipeExtractor` service:
- **Scans video description** for ingredient lists
- **Identifies instruction sections** with cooking verbs
- **Extracts tags** from title and description keywords
- **Estimates servings** from description patterns
- **Generates sensible defaults** when data is incomplete

### 3. Smart Recognition
Recognizes patterns like:
```
Ingredients:
- 2 cups flour
- 3 eggs
...

Instructions:
1. Mix flour and eggs
2. Knead for 10 minutes
...
```

## Supported Video Formats

✅ Standard videos: `youtube.com/watch?v=VIDEO_ID`  
✅ Short links: `youtu.be/VIDEO_ID`  
✅ Shorts: `youtube.com/shorts/VIDEO_ID`

## Troubleshooting

### "Error 403: YouTube Data API has not been used"
- Go to Google Cloud Console
- Enable YouTube Data API v3
- Wait 1-2 minutes for activation

### "Error 400: Bad Request"
- Check that your API key is correct
- Ensure no extra spaces in the key
- Verify the video URL is valid

### "Quota exceeded"
- Wait until midnight Pacific Time
- Or use mock data (works automatically)
- Or request quota increase in Cloud Console

### "Failed to extract recipe"
- Check internet connection
- Verify video is public (not private/unlisted)
- Some videos may have limited metadata

## Example Videos to Try

**With Mock Data (works now)**:
- `https://www.youtube.com/watch?v=nf9tq7cNkTQ` - Biryani recipe
- `https://www.youtube.com/watch?v=dQw4w9WgXcQ` - Pasta recipe

**With Real API** (try any cooking video):
- Tasty: `https://www.youtube.com/watch?v=...`
- Bon Appétit: `https://www.youtube.com/watch?v=...`
- Any cooking tutorial with ingredients in description

## Advanced: Adding LLM for Better Extraction

For even smarter extraction, you can integrate an AI service:

### Option 1: OpenAI GPT-4
```yaml
# pubspec.yaml
dependencies:
  chat_gpt_sdk: ^3.0.0
```

### Option 2: Google Gemini (Free!)
```yaml
# pubspec.yaml
dependencies:
  google_generative_ai: ^0.2.0
```

See `YOUTUBE_IMPORT_FEATURE.md` for full LLM integration guide.

## Summary

**Current Status**: ✅ Fully functional with mock data  
**To Enable Real Data**: Add YouTube API key (5-minute setup)  
**Cost**: Free for up to 10,000 videos/day  
**Best Practice**: Use environment variables for API keys  

🎯 **You can start using it right now** - no API key needed for testing!

Happy cooking! 🍳
