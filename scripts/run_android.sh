#!/bin/bash
# Dev helper script to run Gusto app on Android Emulator
# Usage: ./scripts/run_android.sh [device-id]
# Example: ./scripts/run_android.sh emulator-5554

cd "$(dirname "$0")/.." || exit

# API Keys (replace with your actual keys or set as environment variables)
YOUTUBE_API_KEY="${YOUTUBE_API_KEY:-AIzaSyDuukWJbcxmRQta3aEn3qz5d4ICKijT1Tg}"
GEMINI_API_KEY="${GEMINI_API_KEY:-AIzaSyB-Q0ept9S3VZnN5ENg_Rim4SHtKhBQv8M}"

# Default to the first available Android device/emulator, or a specific device if provided
DEVICE_ID="${1:-}"

if [ -z "$DEVICE_ID" ]; then
  # Try to find a running Android emulator or connected device
  DEVICE_ID=$(flutter devices 2>/dev/null | grep -E "android|emulator" | head -n 1 | awk '{print $NF}' | tr -d '()')
  
  if [ -z "$DEVICE_ID" ]; then
    echo "⚠️  No Android device or emulator found."
    echo "📱 Available devices:"
    flutter devices
    echo ""
    echo "💡 Start an Android emulator first or connect a device"
    echo "   To list emulators: emulator -list-avds"
    echo "   To start an emulator: emulator -avd <avd-name> &"
    exit 1
  fi
fi

echo "🚀 Running Gusto on Android..."
echo "📱 Device: $DEVICE_ID"
echo "📺 YouTube API Key: ${YOUTUBE_API_KEY:0:20}..."
echo "🔮 Gemini API Key: ${GEMINI_API_KEY:0:20}..."
echo ""

flutter run -d "$DEVICE_ID" \
  --dart-define=YOUTUBE_API_KEY="$YOUTUBE_API_KEY" \
  --dart-define=GEMINI_API_KEY="$GEMINI_API_KEY"
