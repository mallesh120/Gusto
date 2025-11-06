# Gusto Build Scripts

Quick helper scripts to run the Gusto app on different platforms with all necessary API keys configured.

## Scripts

### 🌐 Web (Chrome)
```bash
./scripts/run_chrome.sh
```
Runs the app on Chrome at http://localhost:8080

### 📱 iOS Simulator
```bash
# Run on any booted iPhone simulator
./scripts/run_ios.sh

# Run on a specific simulator
./scripts/run_ios.sh "iPhone 15 Pro"
./scripts/run_ios.sh "iPhone 17 Pro"
```

**Note:** Make sure to boot an iOS simulator first using Xcode or:
```bash
# List available simulators
xcrun simctl list devices available | grep "iPhone"

# Boot a specific simulator
open -a Simulator
```

### 🤖 Android Emulator
```bash
# Run on any running emulator/device
./scripts/run_android.sh

# Run on a specific device
./scripts/run_android.sh emulator-5554
```

**Note:** Start an Android emulator first:
```bash
# List available emulators
emulator -list-avds

# Start an emulator
emulator -avd <avd-name> &
```

## Environment Variables

All scripts support environment variables for API keys:

```bash
export YOUTUBE_API_KEY="your-youtube-api-key"
export GEMINI_API_KEY="your-gemini-api-key"
export GOOGLE_CLIENT_ID="your-google-client-id"  # Chrome only
```

If not set, the scripts use the default keys configured in the script files.

## Features

- ✅ Auto-detects available devices/simulators
- ✅ Pre-configured with API keys
- ✅ Easy device selection
- ✅ Helpful error messages
- ✅ Environment variable support

## Troubleshooting

### iOS
If you get "No booted iPhone simulator found":
1. Open Xcode or Simulator app
2. Boot an iPhone simulator
3. Run the script again

### Android
If you get "No Android device or emulator found":
1. Start Android Studio
2. Launch an emulator from AVD Manager
3. Or connect a physical Android device with USB debugging enabled

### Chrome
If the app doesn't load:
- Make sure port 8080 is not in use
- Check Firebase configuration for web platform
- Verify authorized domains in Firebase Console
