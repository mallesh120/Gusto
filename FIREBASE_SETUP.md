# Firebase Authentication Setup Guide

## Error: `configuration-not-found`

This error means Google Sign-In needs to be enabled in your Firebase Console.

## Quick Fix Steps

### 1. Enable Google Sign-In Provider

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: **gusto-476917**
3. Navigate to **Authentication** > **Sign-in method**
4. Click on **Google** in the providers list
5. Click **Enable** toggle
6. Add your email as the support email
7. Click **Save**

### 2. Add Authorized Domains (for Web)

1. In Firebase Console, go to **Authentication** > **Settings**
2. Click **Authorized domains** tab
3. Add these domains:
   - `localhost` (for local testing)
   - `127.0.0.1` (alternative local)
   - Your production domain (when deploying)

### 3. Verify Configuration

Your current Firebase config (from `lib/firebase_options.dart`):
```
Project ID: gusto-476917
Auth Domain: gusto-476917.firebaseapp.com
```

## Alternative: Use Email/Password (Temporary)

If you need to test quickly without Google Sign-In:

1. Enable **Email/Password** provider in Firebase Console
2. Use the email/password sign-in methods in `AuthService`
3. Update `WelcomeScreen` to show email/password fields

## Testing Locally

After enabling Google Sign-In, run:
```bash
flutter run -d chrome
```

The app should now show the Google Sign-In popup when you click "Continue with Google".

## Troubleshooting

**Still getting errors?**

1. **Clear browser cache**: Hard refresh (Cmd+Shift+R on Mac)
2. **Check Firebase Console**: Ensure Google provider is enabled
3. **Check authorized domains**: Localhost should be in the list
4. **Restart Flutter**: Kill all dart/chrome processes and restart

**Check logs:**
Look for these debug messages in the console:
- 🌐 Using Firebase popup for web Google Sign In
- ❌ AuthService.signInWithGoogle error (if it fails)

## Production Deployment

Before deploying to production:

1. Add your production domain to authorized domains
2. Consider adding a Web Client ID in Firebase Console
3. Update `web/index.html` with any required meta tags
4. Test thoroughly on your production domain

## Need Help?

Check the [Firebase Auth Web Documentation](https://firebase.google.com/docs/auth/web/google-signin)
