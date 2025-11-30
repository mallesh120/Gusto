import os
import glob
import tempfile
import logging
import shutil
from typing import List, Dict, Any, Optional
from youtube_transcript_api import YouTubeTranscriptApi, TranscriptsDisabled, NoTranscriptFound
import yt_dlp
from groq import Groq

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class TranscriptService:
    def __init__(self, groq_api_key: Optional[str] = None):
        """
        Initialize the TranscriptService.

        Args:
            groq_api_key: Optional API key. If not provided, looks for GROQ_API_KEY env var.
        """
        self.groq_api_key = groq_api_key or os.environ.get("GROQ_API_KEY")
        if not self.groq_api_key:
            logger.warning("GROQ_API_KEY is not set. Tier 2 fallback will fail if needed.")

        self.client = Groq(api_key=self.groq_api_key) if self.groq_api_key else None

        # Instantiate YouTubeTranscriptApi (not thread-safe if shared, but fine per instance)
        self.yt_api = YouTubeTranscriptApi()

    def get_transcript(self, video_id: str) -> List[Dict[str, Any]]:
        """
        Retrieves the transcript for a YouTube video using a tiered strategy.

        Tier 1: youtube-transcript-api (Free)
        Tier 2: Download audio -> Groq Whisper (Fallback)

        Args:
            video_id: The YouTube Video ID.

        Returns:
            List of dictionaries: [{'text': 'string', 'start': float, 'duration': float}]
        """
        # Tier 1: Try fetching existing transcript
        try:
            logger.info(f"Tier 1: Attempting to fetch transcript for {video_id} via youtube-transcript-api.")
            # Note: In version 1.2.3 of youtube-transcript-api installed in this environment,
            # the standard static method `YouTubeTranscriptApi.get_transcript` is removed.
            # We must use the instance method `.fetch()` which is documented as a shortcut.
            transcript_obj = self.yt_api.fetch(video_id)

            # .fetch() returns a FetchedTranscript object which is iterable.
            # We convert it to a list of dicts to match the required return format.
            transcript = [item for item in transcript_obj]

            logger.info("Tier 1: Success.")
            return transcript
        except (TranscriptsDisabled, NoTranscriptFound) as e:
            logger.info(f"Tier 1 failed: {e}. Switching to Tier 2.")
        except Exception as e:
            logger.error(f"Tier 1 unexpected error: {e}. Switching to Tier 2.")

        # Tier 2: Download audio and transcribe with Groq
        return self._tier_two_fallback(video_id)

    def _tier_two_fallback(self, video_id: str) -> List[Dict[str, Any]]:
        """
        Tier 2 strategy: Download audio and use Groq Whisper model.
        """
        if not self.client:
            raise ValueError("GROQ_API_KEY is required for Tier 2 fallback.")

        audio_file_path = None
        temp_dir = tempfile.mkdtemp()

        try:
            logger.info(f"Tier 2: Downloading audio for {video_id}...")
            audio_file_path = self._download_audio(video_id, temp_dir)

            logger.info("Tier 2: Transcribing audio with Groq...")
            return self._transcribe_audio(audio_file_path)

        finally:
            # Cleanup: Remove the temporary directory and all its contents
            if os.path.exists(temp_dir):
                try:
                    shutil.rmtree(temp_dir)
                    logger.info("Cleanup: Temporary directory deleted.")
                except OSError as e:
                    logger.warning(f"Cleanup: Failed to delete temporary directory: {e}")

    def _download_audio(self, video_id: str, output_dir: str) -> str:
        """
        Downloads audio using yt-dlp to the specified directory.
        Returns the path to the downloaded file.
        """
        video_url = f"https://www.youtube.com/watch?v={video_id}"

        # yt-dlp options
        ydl_opts = {
            'format': 'bestaudio/best',
            'outtmpl': os.path.join(output_dir, '%(id)s.%(ext)s'),
            'postprocessors': [{
                'key': 'FFmpegExtractAudio',
                'preferredcodec': 'mp3',
                'preferredquality': '64', # Low bitrate to keep size small
            }],
            'quiet': True,
            'no_warnings': True,
        }

        try:
            with yt_dlp.YoutubeDL(ydl_opts) as ydl:
                ydl.download([video_url])
        except yt_dlp.utils.DownloadError as e:
            error_msg = str(e).lower()
            if "ffmpeg" in error_msg or "ffprobe" in error_msg:
                raise RuntimeError("FFmpeg is missing") from e
            raise e

        # Find the file (extension might be mp3)
        files = glob.glob(os.path.join(output_dir, f"{video_id}.*"))
        if not files:
            raise FileNotFoundError("Audio file not found after download.")

        return files[0]

    def _transcribe_audio(self, file_path: str) -> List[Dict[str, Any]]:
        """
        Sends audio to Groq API and formats the response.
        """
        with open(file_path, "rb") as file:
            transcription = self.client.audio.transcriptions.create(
                file=(os.path.basename(file_path), file.read()),
                model="whisper-large-v3",
                response_format="verbose_json",
            )

        # Map response to standardized format
        # Groq verbose_json returns an object with a 'segments' list
        # Each segment has 'start', 'end', 'text'

        segments = transcription.segments
        formatted_transcript = []

        for segment in segments:
            # Handle object vs dictionary access depending on SDK version/response type
            # Pydantic models usually accessed via dot notation, but let's be safe
            start = getattr(segment, 'start', segment.get('start', 0.0))
            end = getattr(segment, 'end', segment.get('end', 0.0))
            text = getattr(segment, 'text', segment.get('text', "")).strip()

            duration = round(end - start, 3)

            formatted_transcript.append({
                'text': text,
                'start': start,
                'duration': duration
            })

        return formatted_transcript
