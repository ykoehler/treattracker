# 🎃 TreatTracker

**Plan your Halloween trick-or-treat routes by finding participating houses!**

TreatTracker is a Flutter web application with Firebase backend that helps families plan their Halloween trick-or-treat routes by showing which houses are participating and giving out candy.

## Features

- 🏠 **Parent Interface**: Parents can login, register their address, and indicate if they're participating in Halloween
- 🗺️ **Public Map View**: Anonymous users can view participating houses on a map to plan their route
- 🔐 **Firebase Authentication**: Secure login system for parents
- 💾 **Cloud Firestore**: Real-time database for house information
- 🌐 **Web-First Design**: Responsive design optimized for web browsers

## Tech Stack

- **Frontend**: Flutter Web
- **Authentication**: Firebase Authentication
- **Database**: Cloud Firestore
- **Maps**: Google Maps API
- **State Management**: Provider
- **UI**: Material Design 3

## Project Structure

```
lib/
├── features/
│   ├── auth/           # Authentication screens
│   ├── map/            # Public map view
│   └── admin/          # Parent admin panel
├── models/             # Data models
│   ├── house.dart
│   └── user.dart
├── services/           # Business logic
│   ├── auth_service.dart
│   └── firestore_service.dart
├── widgets/            # Reusable UI components
├── utils/              # Helper functions and constants
└── main.dart           # App entry point
```

## Prerequisites

Before you begin, ensure you have the following installed:

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.9.2 or higher)
- [Firebase CLI](https://firebase.google.com/docs/cli)
- A Firebase project
- Google Maps API key

## Setup Instructions

### 1. Clone the Repository

```bash
cd /Users/ykoehler/Projects/TreatTracker
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Firebase Setup

⚠️ **IMPORTANT: Firebase API keys are sensitive and should NOT be committed to git!**

See [SECURITY.md](SECURITY.md) for detailed security setup instructions.

#### Quick Setup (Recommended)

**The Firebase configuration is already set up for this repository!** Simply run:

```bash
# This will use the existing Firebase project: treattracker-app
flutterfire configure --platforms=web
```

This generates `lib/firebase_options.dart` locally (git-ignored for security).

Select the existing project **`treattracker-app`** when prompted.

#### Create a Firebase Project (For New Projects Only)

Only needed if starting fresh:

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project" and follow the setup wizard
3. Enable **Email/Password** authentication:
   - Go to Authentication → Sign-in method
   - Enable "Email/Password"
4. Create a **Cloud Firestore** database:
   - Go to Firestore Database → Create database
   - Start in production mode (or test mode for development)

#### Configure Firebase for Web

**Using FlutterFire CLI (Recommended):**

```bash
flutterfire configure --platforms=web
```

This automatically:
- Creates/selects a Firebase project
- Generates `lib/firebase_options.dart` with your configuration
- Keeps API keys secure (file is git-ignored)

**Manual Configuration (Not Recommended):**

If you must configure manually, see `SECURITY.md` for safe practices.

#### Set Firestore Security Rules

**Already configured!** The security rules are in `firestore.rules` and deployed to Firebase.

To update rules:

In Firebase Console → Firestore Database → Rules, add:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /houses/{houseId} {
      // Anyone can read participating houses
      allow read: if true;
      
      // Only authenticated users can create houses
      allow create: if request.auth != null;
      
      // Only the owner can update or delete their houses
      allow update, delete: if request.auth != null 
                            && request.auth.uid == resource.data.ownerId;
    }
  }
}
```

### 4. Google Maps Setup

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Enable the **Maps JavaScript API**
3. Create an API key
4. Update `lib/utils/constants.dart`:

```dart
const String googleMapsApiKey = 'YOUR_GOOGLE_MAPS_API_KEY';
```

5. Add the API key to `web/index.html` (add before `</head>`):

```html
<script src="https://maps.googleapis.com/maps/api/js?key=YOUR_GOOGLE_MAPS_API_KEY"></script>
```

### 5. Run the Application

For web (Chrome):
```bash
flutter run -d chrome
```

For production build:
```bash
flutter build web
```

## Usage

### For Parents

1. Click "Parent Login" on the map screen
2. Register with email and password
3. Add your address and indicate if you're participating in Halloween
4. Toggle participation status anytime
5. Add multiple addresses if needed

### For Trick-or-Treaters

1. Open the app (no login required)
2. View the map showing all participating houses
3. Plan your route based on house locations
4. Enjoy Halloween! 🎃

## Development Roadmap

### Current Features (v1.0)
- ✅ Firebase Authentication
- ✅ House registration
- ✅ Participation status toggle
- ✅ Public map view with house list
- ⚠️ Google Maps integration (placeholder)

### Planned Features
- 🗺️ Full Google Maps integration with markers
- 📍 Address geocoding (convert address to coordinates)
- 🔍 Search and filter houses
- 📱 Mobile app support (iOS/Android)
- 🕒 Time windows for trick-or-treating
- 🍬 Candy type indicators
- ⭐ House ratings and reviews
- 📊 Analytics for parents

## 🔒 Security

**Important:** Firebase API keys and configuration are sensitive!

- `lib/firebase_options.dart` is **git-ignored** to protect credentials
- Never commit API keys directly in code
- Use `flutterfire configure` to generate configs locally
- See [SECURITY.md](SECURITY.md) for complete security guidelines

### For New Developers

When you clone this repo:

```bash
# Generate your local Firebase configuration
flutterfire configure --platforms=web

# Select: treattracker-app (existing project)
```

The `firebase_options.dart` file will be created locally but won't be committed to git.

## Environment Variables

For reference, see `.env.example` for the structure of environment variables.

**Note:** With FlutterFire CLI, you don't need `.env` files - the configuration is auto-generated securely.

## Troubleshooting

### Firebase initialization fails

- Run `flutterfire configure --platforms=web` to regenerate config
- Ensure Firebase project is active in Firebase Console
- Check browser console for detailed error messages
- Verify `lib/firebase_options.dart` exists locally

### Google Maps not loading
- Verify API key in `web/index.html`
- Ensure Maps JavaScript API is enabled in Google Cloud Console
- Check for billing issues in Google Cloud

### Dependencies issues
```bash
flutter clean
flutter pub get
```

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is open source and available under the MIT License.

## Acknowledgments

- Flutter team for the amazing framework
- Firebase for backend services
- Google Maps for mapping capabilities

---

**Happy Halloween! 🎃👻🍬**
