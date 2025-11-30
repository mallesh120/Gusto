import os
import sys

# Add the parent directory to sys.path to allow imports from backend
sys.path.append(os.path.join(os.path.dirname(__file__), '..'))

from backend.services.transcript_service import TranscriptService

def main():
    # Check for API key
    if not os.environ.get("GROQ_API_KEY"):
        print("Warning: GROQ_API_KEY is not set. Tier 2 fallback will not work.")
        print("You can set it via: export GROQ_API_KEY='your_key'")

    # Get video ID from user or use default
    if len(sys.argv) > 1:
        video_id = sys.argv[1]
    else:
        # Default example: A short video or one known to have transcripts
        print("No video ID provided. Using default example.")
        video_id = "jNQXAC9IVRw" # "Me at the zoo" - First YouTube video

    print(f"Fetching transcript for Video ID: {video_id}...")

    service = TranscriptService()
    try:
        transcript = service.get_transcript(video_id)

        print("\n--- Transcript Result ---")
        for line in transcript[:5]: # Print first 5 lines
            print(f"[{line['start']}s]: {line['text']} (Dur: {line['duration']}s)")

        if len(transcript) > 5:
            print(f"... and {len(transcript) - 5} more lines.")

    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    main()
