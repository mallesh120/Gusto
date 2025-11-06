#!/bin/bash
# Dev helper script to run Gusto app on Chrome with Google client ID
# Usage: ./scripts/run_chrome.sh

cd "$(dirname "$0")/.." || exit

# Your Google OAuth client ID (replace with your actual ID or set as environment variable)
GOOGLE_CLIENT_ID="${GOOGLE_CLIENT_ID:-55871689441-5scahbli2fi2gqes2pjdmrlm647n5hdu.apps.googleusercontent.com}"
YOUTUBE_API_KEY="${YOUTUBE_API_KEY:-AIzaSyDuukWJbcxmRQta3aEn3qz5d4ICKijT1Tg}"
GEMINI_API_KEY="${GEMINI_API_KEY:-AIzaSyB-Q0ept9S3VZnN5ENg_Rim4SHtKhBQv8M}"

echo "🚀 Running Gusto on Chrome (port 8080)..."
echo "📱 Client ID: ${GOOGLE_CLIENT_ID:0:20}..."
echo "📺 YouTube API Key: ${YOUTUBE_API_KEY:0:20}..."
echo "🔮 Gemini API Key: ${GEMINI_API_KEY:0:20}..."

flutter run -d chrome \
  --web-port=8080 \
  --dart-define=GOOGLE_CLIENT_ID="$GOOGLE_CLIENT_ID" \
  --dart-define=YOUTUBE_API_KEY="$YOUTUBE_API_KEY" \
  --dart-define=GEMINI_API_KEY="$GEMINI_API_KEY"
