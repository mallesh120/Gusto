import 'dart:convert';
import 'package:http/http.dart' as http;

class YouTubeService {
  // Get API key from environment variables
  static const String _apiKey = String.fromEnvironment(
    'YOUTUBE_API_KEY',
    defaultValue: 'YOUR_YOUTUBE_API_KEY_HERE',
  );
  static const String _baseUrl = 'https://www.googleapis.com/youtube/v3';

  /// Fetches video metadata from YouTube Data API
  Future<YouTubeVideoInfo?> getVideoInfo(String videoId) async {
    if (_apiKey == 'YOUR_YOUTUBE_API_KEY_HERE') {
      print('⚠️ YouTube API key not configured. Using mock data.');
      print('   Run with: flutter run --dart-define=YOUTUBE_API_KEY=your_key');
      return _getMockVideoInfo(videoId);
    }
    
    print('📺 YouTube API: Fetching video info for $videoId...');

    try {
      final url = Uri.parse(
        '$_baseUrl/videos?part=snippet,contentDetails&id=$videoId&key=$_apiKey',
      );

      final response = await http.get(url);

      print('📺 YouTube API: Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['items'] != null && data['items'].isNotEmpty) {
          final item = data['items'][0];
          final snippet = item['snippet'];
          final contentDetails = item['contentDetails'];

          final videoInfo = YouTubeVideoInfo(
            videoId: videoId,
            title: snippet['title'] ?? '',
            description: snippet['description'] ?? '',
            thumbnailUrl: snippet['thumbnails']?['maxres']?['url'] ??
                snippet['thumbnails']?['high']?['url'] ??
                'https://img.youtube.com/vi/$videoId/maxresdefault.jpg',
            channelTitle: snippet['channelTitle'] ?? '',
            duration: _parseDuration(contentDetails['duration']),
          );
          
          print('✅ YouTube API: Video fetched successfully');
          print('   Title: ${videoInfo.title}');
          print('   Channel: ${videoInfo.channelTitle}');
          print('   Description length: ${videoInfo.description.length} chars');
          
          return videoInfo;
        } else {
          print('❌ YouTube API: No video found with ID $videoId');
        }
      } else {
        print('❌ YouTube API: HTTP ${response.statusCode}');
        print('   Error: ${response.body}');
      }
    } catch (e) {
      print('❌ Error fetching YouTube data: $e');
    }

    return null;
  }

  /// Parse ISO 8601 duration format (PT1H30M45S) to minutes
  int _parseDuration(String? duration) {
    if (duration == null) return 30;

    final regex = RegExp(r'PT(?:(\d+)H)?(?:(\d+)M)?(?:(\d+)S)?');
    final match = regex.firstMatch(duration);

    if (match != null) {
      final hours = int.tryParse(match.group(1) ?? '0') ?? 0;
      final minutes = int.tryParse(match.group(2) ?? '0') ?? 0;
      final seconds = int.tryParse(match.group(3) ?? '0') ?? 0;

      return (hours * 60) + minutes + (seconds > 0 ? 1 : 0);
    }

    return 30;
  }

  /// Mock data for demo purposes (when API key is not set)
  YouTubeVideoInfo _getMockVideoInfo(String videoId) {
    // Recognize known videos
    final mockData = {
      'nf9tq7cNkTQ': YouTubeVideoInfo(
        videoId: videoId,
        title: 'How to Make Authentic Chicken Biryani | Restaurant Style Recipe',
        description: '''Learn how to make the perfect chicken biryani at home! This restaurant-style recipe features fragrant basmati rice, tender chicken, and aromatic spices layered and cooked using the traditional dum method.

Ingredients include basmati rice, chicken, yogurt, onions, tomatoes, fresh herbs (mint and cilantro), and whole spices like cardamom, cloves, cinnamon, and saffron. The key is in the layering and the slow cooking process.

Perfect for special occasions or weekend cooking!''',
        thumbnailUrl: 'https://img.youtube.com/vi/$videoId/maxresdefault.jpg',
        channelTitle: 'Indian Cooking Channel',
        duration: 90,
      ),
      'dQw4w9WgXcQ': YouTubeVideoInfo(
        videoId: videoId,
        title: 'Classic Homemade Pasta Recipe | Fresh Italian Pasta',
        description: '''Make fresh pasta from scratch with just flour, eggs, and a bit of olive oil. This traditional Italian recipe will teach you how to create silky smooth pasta dough and cut it into beautiful fettuccine or tagliatelle.

Ingredients: All-purpose flour, eggs, olive oil, salt, and semolina for dusting.

Tips: Knead well, let the dough rest, and don't overcook!''',
        thumbnailUrl: 'https://img.youtube.com/vi/$videoId/maxresdefault.jpg',
        channelTitle: 'Pasta Masters',
        duration: 45,
      ),
    };

    return mockData[videoId] ?? YouTubeVideoInfo(
      videoId: videoId,
      title: 'Delicious Recipe Video',
      description: 'A wonderful cooking tutorial with step-by-step instructions to create an amazing dish at home.',
      thumbnailUrl: 'https://img.youtube.com/vi/$videoId/maxresdefault.jpg',
      channelTitle: 'Cooking Channel',
      duration: 30,
    );
  }
}

class YouTubeVideoInfo {
  final String videoId;
  final String title;
  final String description;
  final String thumbnailUrl;
  final String channelTitle;
  final int duration; // in minutes

  YouTubeVideoInfo({
    required this.videoId,
    required this.title,
    required this.description,
    required this.thumbnailUrl,
    required this.channelTitle,
    required this.duration,
  });

  /// Extract cooking-related keywords from title and description
  List<String> getTags() {
    final text = '${title.toLowerCase()} ${description.toLowerCase()}';
    final tags = <String>[];

    // Cuisine types
    final cuisines = {
      'italian': 'Italian',
      'indian': 'Indian',
      'chinese': 'Chinese',
      'mexican': 'Mexican',
      'thai': 'Thai',
      'japanese': 'Japanese',
      'french': 'French',
      'mediterranean': 'Mediterranean',
      'korean': 'Korean',
      'american': 'American',
    };

    // Dish types
    final dishes = {
      'pasta': 'Pasta',
      'biryani': 'Biryani',
      'curry': 'Curry',
      'pizza': 'Pizza',
      'salad': 'Salad',
      'soup': 'Soup',
      'dessert': 'Dessert',
      'cake': 'Cake',
      'bread': 'Bread',
      'chicken': 'Chicken',
      'beef': 'Beef',
      'fish': 'Fish',
      'vegetarian': 'Vegetarian',
      'vegan': 'Vegan',
    };

    // Cooking styles
    final styles = {
      'quick': 'Quick',
      'easy': 'Easy',
      'healthy': 'Healthy',
      'homemade': 'Homemade',
      'restaurant': 'Restaurant-Style',
      'authentic': 'Authentic',
      'traditional': 'Traditional',
      'spicy': 'Spicy',
    };

    for (final entry in {...cuisines, ...dishes, ...styles}.entries) {
      if (text.contains(entry.key)) {
        tags.add(entry.value);
      }
    }

    // Always add YouTube tag
    tags.add('YouTube');

    return tags.isEmpty ? ['YouTube', 'Homemade'] : tags;
  }

  /// Estimate servings from description
  int estimateServings() {
    final text = description.toLowerCase();
    
    // Look for serving patterns
    final patterns = [
      RegExp(r'serves?\s+(\d+)'),
      RegExp(r'(\d+)\s+servings?'),
      RegExp(r'(\d+)\s+people'),
      RegExp(r'(\d+)\s+portions?'),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        return int.tryParse(match.group(1) ?? '4') ?? 4;
      }
    }

    return 4; // Default
  }
}
