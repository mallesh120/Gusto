# Gusto

A Flutter recipe management app with Firebase integration and shopping list features.

## Features

- 🛒 **Shopping List**: Add, edit, and manage shopping items with categories
  - Mark items as bought with checkbox
  - Group by category view
  - Filter by category
  - Clear bought items
  - Swipe to delete
- 🔐 **Authentication**: Google Sign-In integration (web + mobile)
- 📱 **Cross-platform**: Web, iOS, Android support

## Getting Started

### Prerequisites

- Flutter SDK (>=3.1.0)
- Firebase project with web app configured
- Google OAuth 2.0 Client ID (for Google Sign-In)

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

**Quick Start Script**: Use the provided helper script:
```bash
# Set your client ID as environment variable (or edit scripts/run_chrome.sh)
export GOOGLE_CLIENT_ID=YOUR_WEB_CLIENT_ID.apps.googleusercontent.com
./scripts/run_chrome.sh
```

#### Option 2: Using meta tag

Add your client ID to `web/index.html` in the `<head>` section:
```html
<meta name="google-signin-client_id" content="YOUR_WEB_CLIENT_ID.apps.googleusercontent.com">
```

### Firebase Setup

1. Create a Firebase project at https://console.firebase.google.com
2. Register your web app in Firebase
3. Copy the Firebase configuration from Firebase Console
4. The configuration is already set in `lib/firebase_options.dart`
5. Enable Google Sign-In in Firebase Authentication → Sign-in method

### Running the App

```bash
# Install dependencies
flutter pub get

# Run on Chrome (web)
flutter run -d chrome --web-port=8080

# Run with Google Sign-In enabled
./scripts/run_chrome.sh

# Run tests
flutter test

# Run analyzer
flutter analyze
```

## Using the Shopping List

1. Launch the app and tap "Open Shopping List" on the welcome screen
2. Tap the **+** button to add items
3. Choose a category from the dropdown
4. Tap an item to edit it
5. Swipe left or right to delete
6. Use the checkbox to mark items as bought
7. Tap the **category icon** in the app bar to group items by category
8. Tap the **filter icon** to filter by specific categories
9. Use the **menu (⋮)** to clear all bought items at once

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── firebase_options.dart     # Firebase configuration
├── models/
│   ├── recipe.dart          # Recipe data model
│   └── shopping_item.dart   # Shopping item data model
├── screens/
│   ├── home/
│   │   └── shopping_list_screen.dart  # Shopping list UI
│   └── onboarding/
│       ├── import_recipe.dart
│       └── welcome.dart      # Welcome/onboarding screen
├── services/
│   ├── auth_service.dart     # Authentication logic
│   └── shopping_service.dart # Shopping list state management
├── utils/
│   └── app_theme.dart        # App theme configuration
└── widgets/
    ├── google_sign_in_button.dart     # Platform-agnostic export
    ├── google_sign_in_button_io.dart  # Mobile/desktop button
    └── google_sign_in_button_web.dart # Web platform button

test/
├── shopping_service_test.dart        # Unit tests for shopping service
├── shopping_list_screen_test.dart    # Widget tests for UI
└── widget_test.dart                  # App smoke test

scripts/
└── run_chrome.sh            # Dev helper for running with client ID
```

## Testing

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/shopping_service_test.dart

# Run with expanded output
flutter test -r expanded
```

### Development Setup

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
