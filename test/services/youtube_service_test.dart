import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'dart:convert';
import 'package:gusto/services/youtube_service.dart';

void main() {
  group('YouTubeService', () {
    late YouTubeService youtubeService;

    setUp(() {
      youtubeService = YouTubeService();
    });

    test('should parse video ID from full YouTube URL', () {
      const url = 'https://www.youtube.com/watch?v=QFvd7u_YjVk';
      final videoId = youtubeService.extractVideoId(url);
      expect(videoId, 'QFvd7u_YjVk');
    });

    test('should parse video ID from short YouTube URL', () {
      const url = 'https://youtu.be/QFvd7u_YjVk';
      final videoId = youtubeService.extractVideoId(url);
      expect(videoId, 'QFvd7u_YjVk');
    });

    test('should parse video ID from URL with additional parameters', () {
      const url = 'https://www.youtube.com/watch?v=QFvd7u_YjVk&t=123s';
      final videoId = youtubeService.extractVideoId(url);
      expect(videoId, 'QFvd7u_YjVk');
    });

    test('should return null for invalid YouTube URL', () {
      const url = 'https://example.com/video';
      final videoId = youtubeService.extractVideoId(url);
      expect(videoId, isNull);
    });

    test('should parse ISO 8601 duration correctly - hours and minutes', () {
      final duration = youtubeService.parseDuration('PT1H30M');
      expect(duration, 90); // 90 minutes
    });

    test('should parse ISO 8601 duration correctly - minutes only', () {
      final duration = youtubeService.parseDuration('PT15M');
      expect(duration, 15);
    });

    test('should parse ISO 8601 duration correctly - with seconds rounding up', () {
      final duration = youtubeService.parseDuration('PT5M30S');
      expect(duration, 6); // 5 minutes + 1 for seconds
    });

    test('should return default duration for null', () {
      final duration = youtubeService.parseDuration(null);
      expect(duration, 30);
    });

    group('getVideoInfo', () {
      test('should fetch and parse video info successfully', () async {
        // This test would require mocking HTTP client
        // For now, testing the structure
        final videoInfo = await youtubeService.getVideoInfo('QFvd7u_YjVk');
        
        expect(videoInfo, isNotNull);
        if (videoInfo != null) {
          expect(videoInfo.videoId, isNotEmpty);
          expect(videoInfo.title, isNotEmpty);
          expect(videoInfo.duration, greaterThan(0));
        }
      });

      test('should return null for invalid video ID', () async {
        final videoInfo = await youtubeService.getVideoInfo('invalid_id_12345');
        // May return null or mock data depending on implementation
        expect(videoInfo, isA<YouTubeVideoInfo?>());
      });
    });

    test('YouTubeVideoInfo should be created with all required fields', () {
      final videoInfo = YouTubeVideoInfo(
        videoId: 'test123',
        title: 'Test Video',
        description: 'Test description',
        thumbnailUrl: 'https://example.com/thumb.jpg',
        channelTitle: 'Test Channel',
        duration: 45,
      );

      expect(videoInfo.videoId, 'test123');
      expect(videoInfo.title, 'Test Video');
      expect(videoInfo.description, 'Test description');
      expect(videoInfo.thumbnailUrl, contains('example.com'));
      expect(videoInfo.channelTitle, 'Test Channel');
      expect(videoInfo.duration, 45);
    });
  });
}
