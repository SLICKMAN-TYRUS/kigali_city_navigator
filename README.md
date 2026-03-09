# Kigali City Navigator

A Flutter app I built for my Mobile Application Development course. It helps people in Kigali find and navigate to useful places around the city like hospitals, police stations, restaurants, parks, and more. The app uses Firebase for the backend and Google Maps for showing locations on a map.

## Author

**Ajak Chol**
ALU (African Leadership University)
March 2026

## What the App Does

- Sign up / log in with email and password, or use Google or Facebook login
- Email verification is required before you can use the app
- Browse a directory of locations around Kigali
- Search by name and filter by category (8 categories: Hospital, Police Station, Library, Utility Office, Restaurant, Café, Park, Tourist Attraction)
- Add your own listings with name, category, address, phone, description, and GPS coordinates
- Edit or delete listings you created
- View all listings on a Google Map with markers
- Tap a listing to see its detail page with an embedded map, and get directions via Google Maps
- Settings page shows your profile and lets you toggle notifications

## Tech Stack

- **Flutter/Dart** for the frontend
- **Firebase Auth** for login (email/password, Google, Facebook)
- **Cloud Firestore** for storing users and listings in real-time
- **Google Maps Flutter** for the map views and markers
- **Provider** for state management

## How It's Structured

I organized the code into three layers so the UI never talks to Firebase directly:

```
Screens/Widgets (what the user sees)
       ↓
Providers (manage state, handle loading/errors)
       ↓
Services (talk to Firebase Auth and Firestore)
```

The providers get their services through the constructor, so the dependency flows one way. There are also abstract repository classes (`AuthRepository`, `ListingRepository`) that define what methods the services need to implement. This way if I ever wanted to swap Firebase for something else, I'd only need to change the service files.

I used Provider with ChangeNotifier because it's simpler than BLoC and works well for an app this size. There are two providers:

- `AuthProvider` - handles login/signup, email verification (polls every 3 seconds), user profile, notification settings
- `ListingProvider` - handles CRUD for listings, search query, category filter, and exposes Firestore streams for real-time updates

## Firestore Database

Two collections:

**users** (document ID = Firebase Auth UID)
| Field | Type | What it stores |
|---|---|---|
| fullName | string | Display name |
| email | string | Email address |
| createdAt | timestamp | When the account was made |
| notificationsEnabled | boolean | Whether notifications are on |
| photoUrl | string | Profile pic URL from Google/Facebook |

**listings** (auto-generated IDs)
| Field | Type | What it stores |
|---|---|---|
| name | string | Name of the place |
| category | string | One of the 8 categories |
| address | string | Street address |
| contactNumber | string | Phone number |
| description | string | Details about the place |
| latitude | number | GPS lat |
| longitude | number | GPS lng |
| createdBy | string | UID of whoever created it |
| timestamp | timestamp | When it was added |

There's a composite index on `listings` for `createdBy` (ascending) + `timestamp` (descending) since the "My Listings" screen needs to filter by user and sort by date.

### Security Rules

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    match /listings/{listingId} {
      allow read: if true;
      allow create: if request.auth != null;
      allow update, delete: if request.auth != null
                            && resource.data.createdBy == request.auth.uid;
    }
  }
}
```

Basically: you can only edit your own profile, anyone can read listings, but only the person who created a listing can edit or delete it.

## Navigation

The app uses an `AuthWrapper` widget that checks the auth state and decides what to show:

- Not logged in → Login screen (can navigate to Sign Up)
- Logged in but email not verified → Verify Email screen
- Fully logged in → Home screen with 4 tabs

The home screen has a `BottomNavigationBar` with `IndexedStack` so switching tabs doesn't lose your scroll position or search query:

1. **Directory** - all listings with search bar and category chips
2. **My Listings** - just your own listings with edit/delete buttons
3. **Map View** - Google Map with markers for everything
4. **Settings** - profile info, notification toggle, logout

From the directory or map, tapping a listing takes you to a detail page with an embedded map, a directions button (opens Google Maps), and a call button.

## Project Structure

```
lib/
├── main.dart                          # entry point, Firebase init, provider setup
├── firebase_options.dart              # Firebase config (not in git)
├── core/
│   ├── theme/app_theme.dart           # colors, fonts (Montserrat), button styles
│   └── utils/constants.dart           # category list, validation rules, messages
├── data/
│   ├── models/listing_model.dart      # data model with fromFirestore/toFirestore
│   ├── repositories/
│   │   ├── auth_repository.dart       # abstract auth interface
│   │   └── listing_repository.dart    # abstract CRUD interface
│   └── services/
│       ├── firebase_auth_service.dart     # implements auth with Firebase
│       └── firestore_listing_service.dart # implements CRUD with Firestore
├── domain/
│   └── providers/
│       ├── auth_provider.dart         # auth state, verification polling
│       └── listing_provider.dart      # listing state, search, filter
└── presentation/
    ├── screens/
    │   ├── auth/                      # login, signup, verify email
    │   ├── main/                      # home, directory, my listings, map, settings
    │   └── detail/                    # listing detail, add/edit form
    └── widgets/
        └── listing_card.dart          # reusable card widget
```

## How to Run

You need Flutter (>= 3.0.0) and a Firebase project set up.

1. Clone the repo
   ```
   git clone https://github.com/SLICKMAN-TYRUS/kigali_city_navigator.git
   cd kigali_city_navigator
   ```
2. Put `google-services.json` in `android/app/`
3. Add your Google Maps API key to `android/local.properties`:
   ```
   MAPS_API_KEY=your_key_here
   ```
4. Run:
   ```
   flutter pub get
   flutter run
   ```

In Firebase Console, make sure you've:
- Enabled Email/Password, Google, and Facebook sign-in methods
- Created a Firestore database
- Published the security rules above
- Created the composite index on the `listings` collection

## Packages Used

| Package | What it does |
|---|---|
| firebase_core | Firebase setup |
| firebase_auth | Authentication |
| cloud_firestore | Database |
| google_maps_flutter | Maps and markers |
| url_launcher | Opening Google Maps directions and phone dialer |
| provider | State management |
| google_sign_in | Google login |
| flutter_facebook_auth | Facebook login |
| google_fonts | Montserrat font |
| font_awesome_flutter | Icons for categories |
| intl | Date formatting |

## Security Notes

- The Google Maps API key is in `local.properties` which is git-ignored, so it doesn't end up on GitHub. It gets injected at build time through Gradle.
- `google-services.json` and `firebase_options.dart` are also git-ignored.
- The Maps API key is restricted to my app's package name and SHA-1 fingerprint in Google Cloud Console.
- Firestore rules make sure users can only modify their own stuff.

## License

This project was made for a university course assignment. Feel free to use it as a reference, but please don't just copy-paste it for your own submission.
