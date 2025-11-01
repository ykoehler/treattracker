# TreatTracker Features

## Overview
TreatTracker helps families plan their Halloween trick-or-treat routes by showing which houses are participating. The app combines owner-verified houses with community-driven anonymous reporting.

## Key Features

### 🎃 Anonymous House Reporting
- **GPS-Based Reporting**: Anonymous users can report candy-giving houses based on their location
- **Manual Address Entry**: Simple interface with street number and street name fields
- **Street View Preview**: Real-time Street View image updates as you type the address
- **House Details**:
  - 💡 **Lights On/Off**: Track whether lights are on at the house
  - 🎃 **Halloween Decorations**: Note if the house has decorations
- **No Login Required**: Community members can contribute without authentication

### 🏠 Trust & Confidence System

#### Owner-Verified Houses (Green)
- Houses registered by authenticated owners
- Highest trust level
- Icon: `verified_user`
- Color: Dark green background

#### Anonymous Reports with Confidence Levels
Houses reported by the community are color-coded based on confidence:

- **High Confidence** (5+ reports)
  - Color: Green tint
  - Icon: `groups`
  - Multiple community members confirmed

- **Medium Confidence** (3-4 reports)
  - Color: Light green tint
  - Icon: `groups`
  - Several confirmations

- **Low Confidence** (1-2 reports)
  - Color: Yellow tint
  - Icon: `groups`
  - Limited confirmations

### 📍 Location Features

- **Walking Distance Calculation**: Shows houses within 1-hour walking radius (5km)
- **Nearby Badge**: Orange highlight for houses within walking distance
- **GPS Permission**: Requests location access on first use
- **Location Refresh**: Manual refresh button to update position

### 🗺️ Map View

- **Public Access**: Anyone can view the map without logging in
- **Real-time Updates**: Stream of houses updates automatically
- **House List**: Detailed list view showing all participating houses
- **Visual Indicators**:
  - 💡 Lightbulb icon for houses with lights on
  - 🎃 Celebration icon for houses with decorations
  - Report count for anonymous submissions

### 🔐 Security

- **Firebase Authentication**: Secure owner login
- **Anonymous Reporting Allowed**: Special Firestore rules permit unauthenticated writes
- **Data Validation**: Server-side validation of all fields
- **Spam Prevention**: Report count increment only allowed

## Technical Details

### New Data Fields
The `House` model now includes:
- `isAnonymousReport` (bool): Whether reported by anonymous user
- `reportCount` (int): Number of community reports
- `lightsOn` (bool): House lights status
- `halloweenDecorations` (bool): Decoration status

### Firestore Security Rules
```javascript
// Anonymous users can create reports
allow create: if request.auth == null
  && request.resource.data.isAnonymousReport == true
  && request.resource.data.isGivingCandy == true
  // ... field validations

// Anonymous users can increment report count
allow update: if request.auth == null
  && resource.data.isAnonymousReport == true
  && request.resource.data.reportCount == resource.data.reportCount + 1
  // ... limited to specific fields
```

### API Integration

#### Google Street View
The app uses Google Street View Static API to show house images:
```
https://maps.googleapis.com/maps/api/streetview?
  size=600x400&
  location={address}&
  key={YOUR_API_KEY}
```

**Note**: Replace `YOUR_API_KEY` in the following files:
- `lib/utils/constants.dart`
- `lib/features/map/anonymous_report_screen.dart`

## Usage Flow

### For Anonymous Users
1. Open the app (no login required)
2. Grant location permission
3. Tap "Report Houses" floating action button
4. Enter street number and street name
5. Verify with Street View image
6. Toggle lights/decorations status
7. Submit report

### For Homeowners
1. Login with email/password
2. Navigate to admin panel
3. Register your address
4. Set candy participation status
5. Houses appear as "Owner verified" (green)

## Privacy & Data

- Anonymous reports don't collect user identity
- GPS coordinates used only for distance calculations
- Firestore rules prevent unauthorized modifications
- Report counts provide community consensus

## Future Enhancements

- [ ] Interactive Google Maps widget
- [ ] Route planning feature
- [ ] Time-based availability (e.g., "giving candy 6-9pm")
- [ ] Candy types/allergy info
- [ ] Photo uploads from users
- [ ] Heat map visualization

## Support

For issues or questions, please open an issue on the GitHub repository.
