# Gusto - Recipe App

Welcome to Gusto, your personal recipe keeper, meal planner, and cooking companion. This document will guide you through the setup process to get the application running on your local machine.

## Getting Started

Follow these instructions to get a copy of the project up and running for development and testing purposes.

### 1. Prerequisites

Before you begin, ensure you have the Flutter SDK installed on your machine. If you haven't installed it yet, please follow the official guide for your operating system:

-   [Flutter Installation Guide](https://docs.flutter.dev/get-started/install)

Once installed, you can verify your installation by running:
```sh
flutter doctor
```
Make sure there are no critical issues reported by the doctor.

### 2. Firebase Setup

This project uses Firebase for backend services, including authentication and database. You will need to create your own Firebase project to run the app.

1.  **Create a Firebase Project:**
    -   Go to the [Firebase Console](https://console.firebase.google.com/).
    -   Click on "Add project" and follow the on-screen instructions to create a new project.

2.  **Configure Authentication:**
    -   In the Firebase Console, navigate to the **Authentication** section.
    -   Click on the "Sign-in method" tab.
    -   Enable the following providers:
        -   Email/Password
        -   Google
        -   Apple

3.  **Set up Cloud Firestore:**
    -   Navigate to the **Firestore Database** section.
    -   Click "Create database" and start in **test mode** for initial development.

4.  **Add Firebase to Your App:**
    -   Follow the instructions to add both an **Android** and an **iOS** app to your Firebase project.
    -   **For Android:**
        -   Download the `google-services.json` file.
        -   Place it in the `gusto_app/android/app/` directory.
    -   **For iOS:**
        -   Download the `GoogleService-Info.plist` file.
        -   Place it in the `gusto_app/ios/Runner/` directory using Xcode.

### 3. Installation & Running

Once the prerequisites and Firebase setup are complete, you can run the app.

1.  **Install Dependencies:**
    -   Navigate to the project's root directory (`gusto_app`) and run the following command to fetch all the necessary packages:
    ```sh
    flutter pub get
    ```

2.  **Run the App:**
    -   Connect a device or start an emulator/simulator.
    -   Run the application with the following command:
    ```sh
    flutter run
    ```

That's it! The Gusto app should now be running on your device.
