#!/bin/bash
# Dev helper script to run Gusto app on iOS Simulator
# Usage: ./scripts/run_ios.sh [device-name]
# Example: ./scripts/run_ios.sh "iPhone 15 Pro"

cd "$(dirname "$0")/.." || exit

# API Keys (replace with your actual keys or set as environment variables)
YOUTUBE_API_KEY="${YOUTUBE_API_KEY:-AIzaSyDuukWJbcxmRQta3aEn3qz5d4ICKijT1Tg}"
GEMINI_API_KEY="${GEMINI_API_KEY:-AIzaSyB-Q0ept9S3VZnN5ENg_Rim4SHtKhBQv8M}"

# Default to the first available booted iOS simulator, or a specific device if provided
DEVICE_NAME="${1:-}"

if [ -z "$DEVICE_NAME" ]; then
  # Try to find a booted iPhone simulator
  DEVICE_NAME=$(xcrun simctl list devices booted | grep "iPhone" | head -n 1 | sed -E 's/^[[:space:]]*([^(]+).*/\1/' | xargs)
  
  if [ -z "$DEVICE_NAME" ]; then
    echo "⚠️  No booted iPhone simulator found."
    echo "📱 Available iPhone simulators:"
    xcrun simctl list devices available | grep "iPhone" | head -n 10
    echo ""
    echo "💡 Boot a simulator first or specify one: ./scripts/run_ios.sh \"iPhone 15 Pro\""
    exit 1
  fi
fi

echo "🚀 Running Gusto on iOS Simulator..."
echo "📱 Device: $DEVICE_NAME"
echo "📺 YouTube API Key: ${YOUTUBE_API_KEY:0:20}..."
echo "🔮 Gemini API Key: ${GEMINI_API_KEY:0:20}..."
echo ""

flutter run -d "$DEVICE_NAME" \
  --dart-define=YOUTUBE_API_KEY="$YOUTUBE_API_KEY" \
  --dart-define=GEMINI_API_KEY="$GEMINI_API_KEY"
