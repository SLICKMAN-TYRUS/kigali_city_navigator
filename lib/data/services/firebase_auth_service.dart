// data/services/firebase_auth_service.dart
// Firebase Auth implementation of AuthRepository
// Handles all Firebase Authentication and Firestore user profile operations

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../repositories/auth_repository.dart';

class FirebaseAuthService implements AuthRepository {
  // Firebase Auth instance
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Firestore instance for user profiles
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  @override
  User? get currentUser => _auth.currentUser;

  // Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        return null; // The user canceled the sign-in
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      // Check if new user -> create profile
      if (userCredential.additionalUserInfo?.isNewUser ?? false) {
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'fullName': userCredential.user!.displayName ?? 'Google User',
          'email': userCredential.user!.email ?? '',
          'createdAt': FieldValue.serverTimestamp(),
          'notificationsEnabled': true,
          'photoUrl': userCredential.user!.photoURL,
        });
      }

      return userCredential;
    } catch (e) {
      // Handle sign-in error specifically or rethrow
      if (e is FirebaseAuthException) {
        throw _handleAuthError(e);
      } else {
        throw Exception('An error occurred during Google Sign-In: $e');
      }
    }
  }

  // Sign in with Facebook
  Future<UserCredential?> signInWithFacebook() async {
    try {
      // Trigger the sign-in flow
      final LoginResult result = await FacebookAuth.instance.login();

      // Check if user completed the login
      if (result.status == LoginStatus.success) {
        final AccessToken accessToken = result.accessToken!;

        // Create a credential from the access token
        final OAuthCredential credential =
            FacebookAuthProvider.credential(accessToken.tokenString);

        // Sign in to Firebase with the Facebook credential
        final UserCredential userCredential =
            await _auth.signInWithCredential(credential);

        // Check if new user -> create profile
        if (userCredential.additionalUserInfo?.isNewUser ?? false) {
          await _firestore
              .collection('users')
              .doc(userCredential.user!.uid)
              .set({
            'fullName': userCredential.user!.displayName ?? 'Facebook User',
            'email': userCredential.user!.email ?? '',
            'createdAt': FieldValue.serverTimestamp(),
            'notificationsEnabled': true,
            'photoUrl': userCredential.user!.photoURL,
          });
        }

        return userCredential;
      } else {
        return null; // User cancelled or failed
      }
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  @override
  Future<UserCredential> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      // Create user in Firebase Authentication
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Send email verification immediately
      await credential.user?.sendEmailVerification();

      // Create user profile document in Firestore
      // This stores additional user data beyond basic auth
      await _firestore.collection('users').doc(credential.user!.uid).set({
        'fullName': fullName,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
        'notificationsEnabled': true, // Default to enabled
      });

      return credential;
    } on FirebaseAuthException catch (e) {
      // Convert Firebase errors to user-friendly messages
      throw _handleAuthError(e);
    }
  }

  @override
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Critical: Check if email is verified before allowing access
      if (!credential.user!.emailVerified) {
        // Sign out immediately if not verified
        await signOut();
        throw Exception(
            'Please verify your email before logging in. Check your inbox.');
      }

      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
  }

  @override
  Future<void> sendEmailVerification() async {
    await _auth.currentUser?.sendEmailVerification();
  }

  @override
  Future<bool> checkEmailVerified() async {
    // Reload user to get latest verification status
    await _auth.currentUser?.reload();
    return _auth.currentUser?.emailVerified ?? false;
  }

  @override
  Future<void> createUserProfile(String uid, Map<String, dynamic> data) async {
    await _firestore.collection('users').doc(uid).set(data);
  }

  @override
  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    return doc.data();
  }

  @override
  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    await _firestore.collection('users').doc(uid).update(data);
  }

  // Helper method to convert Firebase error codes to readable messages
  Exception _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return Exception('No user found with this email address.');
      case 'wrong-password':
        return Exception('Incorrect password. Please try again.');
      case 'email-already-in-use':
        return Exception('An account already exists with this email.');
      case 'weak-password':
        return Exception('Password should be at least 6 characters.');
      case 'invalid-email':
        return Exception('Please enter a valid email address.');
      case 'user-disabled':
        return Exception('This account has been disabled.');
      default:
        return Exception(e.message ?? 'An authentication error occurred.');
    }
  }
}
