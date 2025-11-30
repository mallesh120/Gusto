# Backend Services

This directory contains backend services for the application, including the `TranscriptService`.

## TranscriptService

The `TranscriptService` extracts transcripts from YouTube videos using a tiered strategy:
1.  **Tier 1:** `youtube-transcript-api` (Attempts to fetch existing transcripts).
2.  **Tier 2 (Fallback):** Downloads audio using `yt-dlp` and transcribes it using Groq's `whisper-large-v3` model.

### Prerequisites

To use the `TranscriptService` (specifically the Tier 2 fallback), you must have **FFmpeg** installed on your system.

#### Installing FFmpeg

**MacOS (using Homebrew):**
```bash
brew install ffmpeg
```

**Linux (Ubuntu/Debian):**
```bash
sudo apt-get update
sudo apt-get install ffmpeg
```

**Windows:**
1.  Download the executable from [ffmpeg.org](https://ffmpeg.org/download.html).
2.  Extract the files.
3.  Add the `bin` folder to your system `PATH` environment variable.

### Environment Variables

The service requires the following environment variable for Tier 2:
*   `GROQ_API_KEY`: Your Groq API key.

### Usage

See `backend/demo_transcript.py` for an example usage script.
