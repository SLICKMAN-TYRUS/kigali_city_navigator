// data/repositories/auth_repository.dart
// Abstract interface for authentication operations
// Separates auth logic from implementation details

import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthRepository {
  // Stream of auth state changes (logged in/out)
  Stream<User?> get authStateChanges;

  // Currently signed in user
  User? get currentUser;

  // Sign up with email and password
  Future<UserCredential> signUp({
    required String email,
    required String password,
    required String fullName,
  });

  // Sign in with email and password
  Future<UserCredential> signIn({
    required String email,
    required String password,
  });

  // Sign out
  Future<void> signOut();

  // Email verification
  Future<void> sendEmailVerification();
  Future<bool> checkEmailVerified();

  // Firestore user profile operations
  Future<void> createUserProfile(String uid, Map<String, dynamic> data);
  Future<Map<String, dynamic>?> getUserProfile(String uid);
  Future<void> updateUserProfile(String uid, Map<String, dynamic> data);
}
