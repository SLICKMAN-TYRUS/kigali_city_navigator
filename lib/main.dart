// main.dart
// Entry point of Kigali City Navigator
// Initializes Firebase and sets up Provider tree
// Handles auth state routing

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

// Data layer
import 'data/services/firebase_auth_service.dart';
import 'data/services/firestore_listing_service.dart';

// Domain layer
import 'domain/providers/auth_provider.dart';
import 'domain/providers/listing_provider.dart';

// Presentation layer
import 'core/theme/app_theme.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/auth/signup_screen.dart';
import 'presentation/screens/auth/verify_email_screen.dart';
import 'presentation/screens/main/home_screen.dart';
import 'firebase_options.dart';

void main() async {
  // Ensure Flutter bindings are initialized before Firebase
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      // Provide repositories and state management to entire app
      providers: [
        // Auth provider with Firebase implementation
        ChangeNotifierProvider(
          create: (_) => AuthProvider(FirebaseAuthService()),
        ),
        // Listing provider with Firestore implementation
        ChangeNotifierProvider(
          create: (_) => ListingProvider(FirestoreListingService()),
        ),
      ],
      child: MaterialApp(
        title: 'Kigali City Navigator',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme, // Montserrat font applied here

        // Auth wrapper decides initial screen based on login state
        home: const AuthWrapper(),

        // Named routes for navigation
        routes: {
          '/login': (context) => const LoginScreen(),
          '/signup': (context) => const SignupScreen(),
          '/verify': (context) => const VerifyEmailScreen(),
          '/home': (context) => const HomeScreen(),
        },
      ),
    );
  }
}

// Decides which screen to show based on authentication state
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    // Show loading while checking auth state
    if (authProvider.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // User not logged in -> show login
    if (authProvider.user == null) {
      return const LoginScreen();
    }

    // User logged in but email not verified -> show verification
    if (!authProvider.isEmailVerified) {
      return const VerifyEmailScreen();
    }

    // Fully authenticated -> show main app
    return const HomeScreen();
  }
}
