# Google Maps Setup Guide

## Overview
TreatTracker uses Google Maps Street View Static API to show house images. You need to set up a Google Cloud project and enable the API.

## Setup Steps

### 1. Create Google Cloud Project
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select an existing one
3. Note your project ID

### 2. Enable Required APIs
Navigate to **APIs & Services > Library** and enable:
- ✅ **Maps JavaScript API** (for future interactive map)
- ✅ **Street View Static API** (for house images)
- ✅ **Geocoding API** (for address lookups)

### 3. Create API Key
1. Go to **APIs & Services > Credentials**
2. Click **Create Credentials > API Key**
3. Copy your API key

### 4. Restrict API Key (Recommended)
For security, restrict your API key:

#### Application Restrictions
- **HTTP referrers (web sites)**
  - Add: `localhost:*`
  - Add: `*.firebaseapp.com/*` (your Firebase Hosting domain)
  - Add: `*.web.app/*` (your Firebase Hosting domain)

#### API Restrictions
- Restrict to these APIs:
  - Maps JavaScript API
  - Street View Static API
  - Geocoding API

### 5. Update Your Code

Replace `YOUR_API_KEY` in these files:

#### `lib/utils/constants.dart`
```dart
const String googleMapsApiKey = 'YOUR_ACTUAL_API_KEY_HERE';
```

#### `lib/features/map/anonymous_report_screen.dart`
Find this line (around line 58):
```dart
return 'https://maps.googleapis.com/maps/api/streetview?size=600x400&location=${Uri.encodeComponent(address)}&key=YOUR_API_KEY';
```

Replace with:
```dart
import '../../utils/constants.dart';

// Then in the method:
return 'https://maps.googleapis.com/maps/api/streetview?size=600x400&location=${Uri.encodeComponent(address)}&key=$googleMapsApiKey';
```

### 6. Test Your Setup

1. Run the app locally:
   ```bash
   flutter run -d chrome
   ```

2. Try the anonymous report feature:
   - Allow location permission
   - Click "Report Houses"
   - Enter an address like "123 Main Street"
   - Verify the Street View image loads

### 7. Monitor Usage

Google provides:
- **$200 free credit per month**
- Street View Static API costs $7 per 1000 requests after free tier
- Monitor usage in Google Cloud Console

### Pricing Estimate

For a typical Halloween night:
- 100 users × 10 house reports each = 1000 Street View loads
- Cost: **Free** (within $200 monthly credit)

### Security Notes

⚠️ **Important**:
- Never commit API keys to public repositories
- Use HTTP referrer restrictions
- Enable billing alerts in Google Cloud
- Rotate keys if exposed

### Alternative: Environment Variables

For better security, use environment variables:

1. Create `.env` file (add to `.gitignore`):
   ```
   GOOGLE_MAPS_API_KEY=your_key_here
   ```

2. Use `flutter_dotenv` package to load it

3. Access with `dotenv.env['GOOGLE_MAPS_API_KEY']`

## Troubleshooting

### Street View Images Not Loading

**Check:**
- ✅ API key is correct
- ✅ Street View Static API is enabled
- ✅ HTTP referrer matches your domain
- ✅ Billing is enabled on Google Cloud project
- ✅ Browser console for error messages

**Common errors:**
- `403`: API key restrictions too strict
- `400`: Invalid address format
- No image: Address doesn't have Street View coverage

### Local Testing

For development without API key:
- Street View will show placeholder
- App still functions for reporting
- Consider using a development key

## Support

- [Google Maps Platform Documentation](https://developers.google.com/maps/documentation)
- [Street View Static API Guide](https://developers.google.com/maps/documentation/streetview/overview)
- [API Key Best Practices](https://developers.google.com/maps/api-security-best-practices)
