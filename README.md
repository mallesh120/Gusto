# Gusto

A Flutter recipe management app with Firebase integration.

## Getting Started

### Setting up Google Sign-In

For web authentication to work, you need to configure a Google OAuth 2.0 Client ID. Follow these steps:

1. Go to the [Google Cloud Console](https://console.cloud.google.com)
2. Select your project
3. Navigate to APIs & Services > Credentials
4. Create or select a Web Application OAuth 2.0 Client ID
5. Note down your Client ID (ends with .apps.googleusercontent.com)

You can provide the Client ID in one of two ways:

#### Option 1: Using dart-define (Recommended for development)

Run the app with your client ID:
```bash
flutter run -d chrome --dart-define=GOOGLE_CLIENT_ID=YOUR_WEB_CLIENT_ID.apps.googleusercontent.com
```

For server-side token validation, optionally add a server client ID:
```bash
flutter run -d chrome \
  --dart-define=GOOGLE_CLIENT_ID=YOUR_WEB_CLIENT_ID.apps.googleusercontent.com \
  --dart-define=GOOGLE_SERVER_CLIENT_ID=YOUR_SERVER_CLIENT_ID.apps.googleusercontent.com
```

#### Option 2: Using meta tag

Add your client ID to `web/index.html` in the `<head>` section:
```html
<meta name="google-signin-client_id" content="YOUR_WEB_CLIENT_ID.apps.googleusercontent.com">
```

### Development Setup

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
