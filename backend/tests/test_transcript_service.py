import unittest
from unittest.mock import patch, MagicMock, mock_open
import os
import shutil
from backend.services.transcript_service import TranscriptService
from youtube_transcript_api import TranscriptsDisabled, NoTranscriptFound
import yt_dlp

class TestTranscriptService(unittest.TestCase):
    def setUp(self):
        # Setup env var for testing
        os.environ['GROQ_API_KEY'] = 'fake_key'
        self.service = TranscriptService()

    def tearDown(self):
        if 'GROQ_API_KEY' in os.environ:
            del os.environ['GROQ_API_KEY']

    @patch('backend.services.transcript_service.YouTubeTranscriptApi')
    def test_tier_1_success(self, mock_yt_api_class):
        """Test that Tier 1 returns result immediately on success."""
        # Mock the instance returned by YouTubeTranscriptApi()
        mock_api_instance = mock_yt_api_class.return_value

        # Mock the fetch method
        expected_transcript = [{'text': 'Hello', 'start': 0.0, 'duration': 1.0}]
        mock_api_instance.fetch.return_value = expected_transcript

        # Re-initialize service to pick up the mocked class
        service = TranscriptService()
        result = service.get_transcript('video123')

        self.assertEqual(result, expected_transcript)
        mock_api_instance.fetch.assert_called_once_with('video123')

    @patch('backend.services.transcript_service.YouTubeTranscriptApi')
    @patch('backend.services.transcript_service.TranscriptService._tier_two_fallback')
    def test_tier_1_failure_triggers_tier_2(self, mock_tier_two, mock_yt_api_class):
        """Test that Tier 2 is called if Tier 1 raises TranscriptsDisabled."""
        # Mock failure on fetch
        mock_api_instance = mock_yt_api_class.return_value
        mock_api_instance.fetch.side_effect = TranscriptsDisabled("No transcript")

        expected_transcript = [{'text': 'Fallback', 'start': 0.0, 'duration': 1.0}]
        mock_tier_two.return_value = expected_transcript

        service = TranscriptService()
        result = service.get_transcript('video123')

        self.assertEqual(result, expected_transcript)
        mock_tier_two.assert_called_once_with('video123')

    @patch('backend.services.transcript_service.yt_dlp.YoutubeDL')
    @patch('backend.services.transcript_service.glob.glob')
    @patch('backend.services.transcript_service.shutil.rmtree')
    @patch('backend.services.transcript_service.os.path.exists')
    @patch('backend.services.transcript_service.Groq')
    def test_tier_2_success(self, mock_groq_class, mock_exists, mock_rmtree, mock_glob, mock_ydl):
        """Test Tier 2 full flow (download -> transcribe -> format)."""
        # Mock glob to find the downloaded file
        mock_glob.return_value = ['/tmp/temp_dir/video123.mp3']

        # Mock os.path.exists to return True so cleanup happens
        mock_exists.return_value = True

        # Mock Groq client and response
        mock_client = MagicMock()
        mock_groq_class.return_value = mock_client
        self.service.client = mock_client # Update service with mock client

        mock_segment = MagicMock()
        mock_segment.start = 0.0
        mock_segment.end = 2.0
        mock_segment.text = "Hello world"

        mock_response = MagicMock()
        mock_response.segments = [mock_segment]

        mock_client.audio.transcriptions.create.return_value = mock_response

        # Use mock_open to bypass file reading
        with patch('builtins.open', mock_open(read_data=b'audio_data')):
            result = self.service._tier_two_fallback('video123')

        # Check format mapping
        expected = [{'text': 'Hello world', 'start': 0.0, 'duration': 2.0}]
        self.assertEqual(result, expected)

        # Check cleanup - assert rmtree was called with the temp dir
        # Note: we need to check if rmtree was called with ANY string, as temp dir name is random
        mock_rmtree.assert_called_once()

    @patch('backend.services.transcript_service.yt_dlp.YoutubeDL')
    def test_tier_2_ffmpeg_missing(self, mock_ydl):
        """Test that missing FFmpeg raises specific RuntimeError."""
        mock_instance = mock_ydl.return_value.__enter__.return_value
        # Simulate yt-dlp DownloadError with ffmpeg mention
        mock_instance.download.side_effect = yt_dlp.utils.DownloadError("ERROR: ffmpeg not found")

        with self.assertRaises(RuntimeError) as cm:
            self.service._download_audio('video123', '/tmp')

        self.assertEqual(str(cm.exception), "FFmpeg is missing")

if __name__ == '__main__':
    unittest.main()
