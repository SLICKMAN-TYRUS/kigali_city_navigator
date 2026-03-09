# Kigali City Navigator

A Flutter mobile application that helps Kigali residents and visitors locate and navigate to essential public services and lifestyle destinations including hospitals, police stations, libraries, utility offices, restaurants, cafés, parks, and tourist attractions.

## Features

- **User Authentication** — Email/password signup and login with enforced email verification. Google and Facebook social login supported.
- **Listings CRUD** — Create, read, update, and delete service/place listings stored in Cloud Firestore with real-time updates.
- **Search & Filter** — Search listings by name and filter by category (Hospital, Police Station, Library, Utility Office, Restaurant, Café, Park, Tourist Attraction).
- **Map Integration** — Embedded Google Maps on listing detail pages showing marker at the listing's coordinates. Full Map View tab displaying all listings as markers.
- **Turn-by-Turn Navigation** — Launch Google Maps directions to any listing from the detail page.
- **Settings** — View user profile, toggle location-based notifications (persisted to Firestore), and sign out.

## Firestore Database Structure

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

### Firestore Indexes
- **Composite index** on `listings`: `createdBy` (Ascending) + `timestamp` (Descending) — required for the "My Listings" query.

### Firestore Security Rules
- `users/{userId}`: Read/write only by the authenticated owner.
- `listings/{listingId}`: Read by anyone. Create by any authenticated user. Update/delete only by the creator (`createdBy == auth.uid`).

## State Management — Provider

The app uses the **Provider** package for state management with a clean three-layer architecture:

```
UI (Screens/Widgets)
  ↓ reads state / calls methods
Provider (AuthProvider, ListingProvider)
  ↓ delegates to repository interface
Service Layer (FirebaseAuthService, FirestoreListingService)
  ↓ executes
Firebase (Auth, Firestore)
```

- **AuthProvider** — Manages authentication state, email verification polling, user profile, and notification preferences. Exposes `isLoading`, `error`, `isAuthenticated`, `isEmailVerified`, and `userName` to the UI.
- **ListingProvider** — Manages listing CRUD operations, search query, and category filter. Exposes real-time Firestore streams and computed filtered results. Handles loading and error states for every operation.

UI widgets never call Firebase APIs directly. All database interactions pass through the provider layer into the service layer.

## Project Structure

```
lib/
├── main.dart                          # App entry point, Firebase init, Provider tree
├── firebase_options.dart              # FlutterFire CLI generated config
├── core/
│   ├── theme/app_theme.dart           # Montserrat theme, brand colors
│   └── utils/constants.dart           # Categories, validation rules, messages
├── data/
│   ├── models/listing_model.dart      # Listing data model with Firestore serialization
│   ├── repositories/
│   │   ├── auth_repository.dart       # Abstract auth interface
│   │   └── listing_repository.dart    # Abstract listing CRUD interface
│   └── services/
│       ├── firebase_auth_service.dart     # Firebase Auth + social login implementation
│       └── firestore_listing_service.dart # Firestore CRUD implementation
├── domain/
│   └── providers/
│       ├── auth_provider.dart         # Auth state management
│       └── listing_provider.dart      # Listing state management
└── presentation/
    ├── screens/
    │   ├── auth/
    │   │   ├── login_screen.dart      # Email/password + social login
    │   │   ├── signup_screen.dart     # Registration with validation
    │   │   └── verify_email_screen.dart # Email verification with polling
    │   ├── main/
    │   │   ├── home_screen.dart       # BottomNavigationBar with 4 tabs
    │   │   ├── directory_screen.dart  # Browse listings with search & filter
    │   │   ├── my_listings_screen.dart # User's own listings with edit/delete
    │   │   ├── map_view_screen.dart   # Google Map with all listing markers
    │   │   └── settings_screen.dart   # Profile, notifications, logout
    │   └── detail/
    │       ├── listing_detail_screen.dart  # Full listing info with embedded map
    │       └── add_edit_listing_screen.dart # Create/edit listing form
    └── widgets/
        └── listing_card.dart          # Reusable listing card with category icons
```

## Firebase Setup

1. Create a Firebase project and enable **Authentication** (Email/Password, Google, Facebook).
2. Create a **Cloud Firestore** database.
3. Add the `google-services.json` to `android/app/`.
4. Add the Google Maps API key to `android/local.properties`:
   ```
   MAPS_API_KEY=your_api_key_here
   ```
5. Run `flutter pub get` to install dependencies.
6. Run `flutter run` to launch the app.

## Dependencies

- `firebase_core`, `firebase_auth`, `cloud_firestore` — Firebase backend
- `google_maps_flutter` — Embedded maps
- `url_launcher` — Launch directions and phone calls
- `provider` — State management
- `google_sign_in`, `flutter_facebook_auth` — Social authentication
- `google_fonts` — Montserrat typography
- `font_awesome_flutter` — Category icons
- `intl` — Date formatting
