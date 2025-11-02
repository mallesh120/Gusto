import 'package:flutter_test/flutter_test.dart';
import 'package:gusto/services/recipe_extractor.dart';
import 'package:gusto/services/youtube_service.dart';

void main() {
  group('RecipeExtractor', () {
    late RecipeExtractor recipeExtractor;

    setUp(() {
      recipeExtractor = RecipeExtractor();
    });

    group('extractFromYouTubeVideo', () {
      test('should extract recipe from YouTube video info', () async {
        final videoInfo = YouTubeVideoInfo(
          videoId: 'test123',
          title: 'How to Make Gulab Jamun',
          description: 'Delicious Indian sweet made with milk solids and sugar syrup',
          thumbnailUrl: 'https://example.com/thumb.jpg',
          channelTitle: 'Indian Sweets Channel',
          duration: 45,
        );

        final recipe = await recipeExtractor.extractFromYouTubeVideo(
          'https://www.youtube.com/watch?v=test123',
          videoInfo,
        );

        expect(recipe, isNotNull);
        expect(recipe.title, contains('YouTube Recipe'));
        expect(recipe.ingredients, isNotEmpty);
        expect(recipe.instructions, isNotEmpty);
        expect(recipe.imageUrl, videoInfo.thumbnailUrl);
      });

      test('should handle video with minimal description', () async {
        final videoInfo = YouTubeVideoInfo(
          videoId: 'test456',
          title: 'Simple Recipe',
          description: '',
          thumbnailUrl: 'https://example.com/thumb.jpg',
          channelTitle: 'Test Channel',
          duration: 10,
        );

        final recipe = await recipeExtractor.extractFromYouTubeVideo(
          'https://www.youtube.com/watch?v=test456',
          videoInfo,
        );

        expect(recipe, isNotNull);
        expect(recipe.title, isNotEmpty);
      });

      test('should extract cooking time from video duration', () async {
        final videoInfo = YouTubeVideoInfo(
          videoId: 'test789',
          title: 'Quick Recipe',
          description: 'Fast and easy',
          thumbnailUrl: 'https://example.com/thumb.jpg',
          channelTitle: 'Quick Cooking',
          duration: 90, // 90 minutes
        );

        final recipe = await recipeExtractor.extractFromYouTubeVideo(
          'https://www.youtube.com/watch?v=test789',
          videoInfo,
        );

        expect(recipe.cookingTimeMinutes, greaterThan(0));
      });

      test('should set recipe tags from video metadata', () async {
        final videoInfo = YouTubeVideoInfo(
          videoId: 'test',
          title: 'Indian Biryani Recipe',
          description: 'Traditional dish',
          thumbnailUrl: 'https://example.com/thumb.jpg',
          channelTitle: 'Indian Cooking',
          duration: 60,
        );

        final recipe = await recipeExtractor.extractFromYouTubeVideo(
          'https://www.youtube.com/watch?v=test',
          videoInfo,
        );

        expect(recipe.tags, isNotEmpty);
        expect(recipe.tags, contains('YouTube'));
      });
    });
  });
}
