# TreatTracker - Quick Start Guide

## What You Have

A fully scaffolded Flutter web application for Halloween trick-or-treat route planning with:

✅ **Complete Project Structure**
- Feature-based architecture (auth, map, admin)
- Data models (House, User)
- Firebase services (Authentication, Firestore)
- UI screens (Login, Admin, Map)

✅ **Dependencies Installed**
- Firebase Core, Auth, Firestore
- Provider for state management
- Google Maps Flutter Web
- Material Design 3 UI

✅ **Core Features Implemented**
- Parent authentication (login/register)
- House registration and management
- Participation status toggle
- Public anonymous map view
- Real-time data synchronization

✅ **Security Configured**
- Firebase options are git-ignored
- Firestore security rules deployed
- API keys protected from version control

## 🚀 Quick Launch (5 Minutes)

### Step 1: Generate Firebase Configuration

```bash
flutterfire configure --platforms=web
```

**Select:** `treattracker-app` (existing project)

This creates `lib/firebase_options.dart` locally (git-ignored for security).

### Step 2: Run the Application

```bash
flutter run -d chrome
```

That's it! The app is now running with Firebase fully configured.

## 🔒 Security First

**Important:** `lib/firebase_options.dart` is **NOT** in git!

- ✅ Protected by `.gitignore`
- ✅ Generated locally for each developer
- ✅ Contains sensitive Firebase credentials
- ✅ Never committed to version control

See [SECURITY.md](SECURITY.md) for complete security guidelines.

## Next Steps (Optional)

### 1. Enable Firebase Authentication

Already done! Email/Password authentication is enabled on the Firebase project.

### 2. Test the App

1. Click "Parent Login" button
2. Register a new account with email/password
3. Add your address and set participation status
4. View the public map (no login required)

### 3. Deploy to Firebase Hosting

```bash
flutter build web
firebase deploy --only hosting
```

Your app will be live at: `https://treattracker-app.web.app`

## File Locations

**Configuration Files:**
- `lib/firebase_options.dart` - Auto-generated (git-ignored)
- `firebase.json` - Firebase hosting config
- `firestore.rules` - Database security rules
- `.firebaserc` - Firebase project reference

**Important Code:**
- `lib/main.dart` - App entry point
- `lib/services/auth_service.dart` - Authentication logic
- `lib/services/firestore_service.dart` - Database operations

## Default Behavior

**Without Firebase Config:**
The app will show initialization errors until you run `flutterfire configure`.

**With Firebase Config:**
Everything works! Authentication, database, and real-time sync are all operational.

## Architecture Highlights

**Authentication Flow:**
- Anonymous users → Public map view
- Login button → Authentication screen  
- Authenticated users → Admin panel with house management

**Data Flow:**
- AuthService → Firebase Authentication
- FirestoreService → Cloud Firestore
- Provider → State management across widgets

**Security:**
- Only authenticated users can add houses
- Users can only edit/delete their own houses
- Public map shows all participating houses (read-only)

## For Team Members

When cloning the repository:

```bash
# 1. Clone the repo
git clone https://github.com/ykoehler/treattracker.git
cd treattracker

# 2. Install dependencies
flutter pub get

# 3. Generate Firebase config (REQUIRED)
flutterfire configure --platforms=web

# 4. Select existing project
# Choose: treattracker-app

# 5. Run the app
flutter run -d chrome
```

## Need Help?

- **Full Documentation:** See [README.md](README.md)
- **Security Setup:** See [SECURITY.md](SECURITY.md)
- **Firebase Console:** https://console.firebase.google.com/project/treattracker-app
- **GitHub Repo:** https://github.com/ykoehler/treattracker

---

**Project Status:** ✅ Ready to run! Just generate your Firebase config and launch.
