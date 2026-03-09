# Kigali City Navigator

A Flutter mobile application that helps Kigali residents and visitors locate and navigate to essential public services and lifestyle destinations including hospitals, police stations, libraries, utility offices, restaurants, cafés, parks, and tourist attractions.

Built with **Firebase** for authentication and real-time data storage, **Google Maps** for embedded map views and turn-by-turn navigation, and **Provider** for clean, scalable state management.

## Screenshots

| Login | Directory | Map View | Detail |
|---|---|---|---|
| Email/password + social login | Search & category filter | All markers on map | Embedded map + directions |

## Features

### Authentication
- **Email/Password** signup and login with form validation (name, email, password confirmation)
- **Enforced email verification** — users cannot access the app until they verify their email. A polling timer checks verification status every 3 seconds, with a manual "I've Verified" button as fallback
- **Google Sign-In** and **Facebook Login** via OAuth, with automatic Firestore profile creation for new social users
- **Secure logout** with confirmation dialog

### Location Listings (CRUD)
- **Create** new listings with validated form fields: name, category dropdown (8 options), address, phone number, description (10–500 chars), latitude (-90 to 90), and longitude (-180 to 180)
- **Read** all listings in real-time using Firestore `snapshots()` streams — new listings appear instantly without refreshing
- **Update** existing listings with a pre-filled edit form (only available to the listing creator)
- **Delete** listings with a confirmation dialog (only available to the listing creator)
- All mutations flow through: `UI → Provider → Service → Firestore`

### Search & Category Filtering
- **Name search** — real-time filtering as the user types, case-insensitive
- **Category chips** — 8 horizontal filter chips (Hospital, Police Station, Library, Utility Office, Restaurant, Café, Park, Tourist Attraction)
- **Stacked filters** — search and category filter combine: e.g. search "Kigali" within category "Restaurant"
- Computed client-side in `ListingProvider` for instant response (no network round-trip per keystroke)

### Map Integration & Navigation
- **Map View tab** — full-screen Google Map centered on Kigali (-1.9403, 29.8739) with markers for every listing. Tap a marker's info window to navigate to its detail page
- **Embedded detail map** — 250px map on each listing's detail page, centered on the listing's coordinates with a single marker
- **Turn-by-turn directions** — "Get Directions" button launches Google Maps with the listing's lat/lng as the destination
- **Phone dialer** — "Call" button launches the phone app with the listing's contact number

### Settings & Profile
- **User profile card** — displays full name, email, and avatar (first letter of name)
- **Notification toggle** — `SwitchListTile` that persists the preference to the Firestore `users` document
- **Sign out** — with confirmation dialog; auth state change routes back to login automatically

## Architecture

The app follows a **clean three-layer architecture** with strict dependency rules:

```
┌─────────────────────────────────────────────────────────┐
│  PRESENTATION LAYER                                     │
│  Screens: login, signup, verify_email, home, directory, │
│           my_listings, map_view, settings, detail,      │
│           add_edit_listing                               │
│  Widgets: listing_card                                  │
│  Rule: NEVER imports Firebase SDKs directly              │
├─────────────────────────────────────────────────────────┤
│  DOMAIN LAYER                                           │
│  AuthProvider (ChangeNotifier)                          │
│    → auth state, email verification, notifications      │
│  ListingProvider (ChangeNotifier)                       │
│    → CRUD, search/filter state, loading/error states    │
│  Rule: Depends on abstract Repository interfaces only   │
├─────────────────────────────────────────────────────────┤
│  DATA LAYER                                             │
│  AuthRepository (abstract) ← FirebaseAuthService        │
│  ListingRepository (abstract) ← FirestoreListingService │
│  ListingModel (Firestore serialization + copyWith)      │
│  Rule: Only layer that imports Firebase packages        │
└─────────────────────────────────────────────────────────┘
```

**Key design decisions:**
- **Dependency injection:** Providers receive their service implementation via constructor (`AuthProvider(FirebaseAuthService())`). This enables swapping to mock services for testing without changing provider or UI code.
- **Abstract repository interfaces:** `AuthRepository` and `ListingRepository` define the contract. Concrete Firebase implementations are isolated in the service layer, so a backend migration would only touch service files.
- **ChangeNotifier + Provider:** Lightweight and Flutter-native. Two global providers (Auth + Listing) cover all state needs without the overhead of BLoC's event/state boilerplate or Riverpod's code generation.

## State Management — Provider

```dart
// main.dart — Provider tree setup
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => AuthProvider(FirebaseAuthService())),
    ChangeNotifierProvider(create: (_) => ListingProvider(FirestoreListingService())),
  ],
  child: MaterialApp(home: AuthWrapper()),
)
```

### AuthProvider
Manages: user session, email verification polling (3-sec timer), social login, user profile, notification preferences.

| Getter | Type | Purpose |
|---|---|---|
| `user` | `User?` | Firebase Auth user object |
| `isLoading` | `bool` | Shows loading spinners during async ops |
| `error` | `String?` | Displays error messages in UI |
| `isAuthenticated` | `bool` | `true` only when user != null AND email verified |
| `isEmailVerified` | `bool` | Checks Firebase emailVerified flag |
| `userName` | `String` | From Firestore profile |
| `notificationsEnabled` | `bool` | From Firestore profile |

### ListingProvider
Manages: CRUD operations, real-time Firestore streams, search query, category filter, loading/error states.

| Getter | Type | Purpose |
|---|---|---|
| `listings` | `List<ListingModel>` | Filtered by search + category |
| `allListingsStream` | `Stream` | Real-time all listings |
| `isLoading` | `bool` | Loading state for mutations |
| `error` | `String?` | Error state for mutations |
| `searchQuery` | `String` | Current search text |
| `selectedCategory` | `String?` | Current category filter |

## Firestore Database Design

### `users` collection
Each document is keyed by the Firebase Auth UID.

| Field | Type | Description |
|---|---|---|
| `fullName` | string | User's display name |
| `email` | string | User's email address |
| `createdAt` | timestamp | Account creation time |
| `notificationsEnabled` | boolean | Notification preference toggle |
| `photoUrl` | string | Profile photo URL (social login) |

### `listings` collection
Each document has an auto-generated ID.

| Field | Type | Description |
|---|---|---|
| `name` | string | Place or service name |
| `category` | string | One of 8 predefined categories |
| `address` | string | Physical address |
| `contactNumber` | string | Phone number |
| `description` | string | Detailed description |
| `latitude` | number | Geographic latitude |
| `longitude` | number | Geographic longitude |
| `createdBy` | string | Firebase Auth UID of the creator |
| `timestamp` | timestamp | Creation time |

### Firestore Composite Index
- **Collection:** `listings`
- **Fields:** `createdBy` (Ascending) + `timestamp` (Descending)
- **Purpose:** Required for the "My Listings" query that filters by `createdBy` and sorts by `timestamp` descending

### Firestore Security Rules
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

## Navigation Structure

```
AuthWrapper (listens to AuthProvider)
  ├── Not logged in ───────→ LoginScreen ←→ SignupScreen
  ├── Logged in, unverified → VerifyEmailScreen
  └── Fully authenticated ─→ HomeScreen (IndexedStack)
                                ├── Tab 0: DirectoryScreen
                                ├── Tab 1: MyListingsScreen
                                ├── Tab 2: MapViewScreen
                                └── Tab 3: SettingsScreen
                                
Push routes:
  DirectoryScreen → ListingDetailScreen
  MyListingsScreen → AddEditListingScreen (edit)
  MapViewScreen (marker tap) → ListingDetailScreen
  FAB (+) → AddEditListingScreen (create)
  ListingDetailScreen → Google Maps (external, directions)
  ListingDetailScreen → Phone dialer (external, call)
```

`IndexedStack` keeps all 4 tabs alive simultaneously, preserving scroll positions, search state, and map camera position when switching between tabs.

## Project Structure

```
lib/
├── main.dart                          # App entry, Firebase init, MultiProvider, AuthWrapper
├── firebase_options.dart              # FlutterFire config (git-ignored)
├── core/
│   ├── theme/app_theme.dart           # Montserrat font, blue/green palette, Material 3
│   └── utils/constants.dart           # 8 categories, validation rules, error messages
├── data/
│   ├── models/listing_model.dart      # fromFirestore(), toFirestore(), copyWith()
│   ├── repositories/
│   │   ├── auth_repository.dart       # Abstract: signUp, signIn, social, verify, profile
│   │   └── listing_repository.dart    # Abstract: CRUD streams + search
│   └── services/
│       ├── firebase_auth_service.dart     # Implements AuthRepository with Firebase
│       └── firestore_listing_service.dart # Implements ListingRepository with Firestore
├── domain/
│   └── providers/
│       ├── auth_provider.dart         # ChangeNotifier: auth state, verification timer
│       └── listing_provider.dart      # ChangeNotifier: CRUD, search, filter, streams
└── presentation/
    ├── screens/
    │   ├── auth/
    │   │   ├── login_screen.dart      # Email/password + Google + Facebook buttons
    │   │   ├── signup_screen.dart     # Registration with 4-field validation
    │   │   └── verify_email_screen.dart # Timer polling + resend cooldown
    │   ├── main/
    │   │   ├── home_screen.dart       # BottomNavigationBar + IndexedStack (4 tabs)
    │   │   ├── directory_screen.dart  # StreamBuilder + search bar + category chips
    │   │   ├── my_listings_screen.dart # User's listings with edit/delete controls
    │   │   ├── map_view_screen.dart   # GoogleMap + markers from Firestore stream
    │   │   └── settings_screen.dart   # Profile card + notification SwitchListTile
    │   └── detail/
    │       ├── listing_detail_screen.dart  # Embedded map + directions + call buttons
    │       └── add_edit_listing_screen.dart # Validated form, create vs edit mode
    └── widgets/
        └── listing_card.dart          # Reusable card with category-specific FontAwesome icons
```

## Getting Started

### Prerequisites
- Flutter SDK ≥ 3.0.0
- A Firebase project with Authentication and Cloud Firestore enabled
- A Google Maps API key (Android)

### Setup
1. Clone the repository:
   ```bash
   git clone https://github.com/SLICKMAN-TYRUS/kigali_city_navigator.git
   cd kigali_city_navigator
   ```
2. Add your Firebase config:
   - Place `google-services.json` in `android/app/`
   - Place `GoogleService-Info.plist` in `ios/Runner/` (if targeting iOS)
   - Add `firebase_options.dart` to `lib/` (generated by FlutterFire CLI)
3. Add your Google Maps API key to `android/local.properties`:
   ```
   MAPS_API_KEY=your_api_key_here
   ```
4. Install dependencies:
   ```bash
   flutter pub get
   ```
5. Run the app:
   ```bash
   flutter run
   ```

### Firestore Setup
1. Create a Cloud Firestore database (any region)
2. Publish the security rules from the "Firestore Security Rules" section above
3. Create the composite index: `listings` → `createdBy` (Asc) + `timestamp` (Desc)

## Dependencies

| Package | Version | Purpose |
|---|---|---|
| `firebase_core` | ^2.24.2 | Firebase initialization |
| `firebase_auth` | ^4.16.0 | Email/password, Google, Facebook authentication |
| `cloud_firestore` | ^4.14.0 | Real-time NoSQL database |
| `google_maps_flutter` | ^2.5.0 | Embedded maps and markers |
| `url_launcher` | ^6.2.2 | Launch directions and phone dialer |
| `provider` | ^6.1.1 | State management (ChangeNotifier) |
| `google_sign_in` | ^6.2.2 | Google OAuth |
| `flutter_facebook_auth` | ^6.0.4 | Facebook OAuth |
| `google_fonts` | ^6.1.0 | Montserrat typography |
| `font_awesome_flutter` | ^10.6.0 | Category icons |
| `intl` | ^0.19.0 | Date formatting |

## Security

- **API keys** are stored in `local.properties` (git-ignored) and injected via Gradle `manifestPlaceholders` at build time — never hardcoded in source
- **Firebase config files** (`google-services.json`, `firebase_options.dart`) are git-ignored
- **Google Maps API key** is restricted to the app's Android package name and SHA-1 certificate fingerprint
- **Firestore rules** enforce owner-only write access on user profiles and listing mutations
- **Email verification** is enforced at both the service layer (blocks sign-in) and provider layer (blocks navigation)
