// domain/providers/auth_provider.dart
// Manages authentication state across the entire app
// UI widgets listen to this and rebuild automatically when auth state changes

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepo;

  // Internal state variables
  User? _user;
  Map<String, dynamic>? _userProfile;
  bool _isLoading = false;
  String? _error;
  bool _isEmailVerified = false;

  // Timer for polling email verification status
  Timer? _verificationTimer;

  // Constructor - sets up auth state listener
  AuthProvider(this._authRepo) {
    // Listen to Firebase auth state changes
    _authRepo.authStateChanges.listen((User? user) async {
      _user = user;

      if (user != null) {
        _isEmailVerified = user.emailVerified;

        // Load user profile from Firestore if email is verified
        if (_isEmailVerified) {
          _userProfile = await _authRepo.getUserProfile(user.uid);
          _stopVerificationTimer();
        } else {
          // Start polling for verification if not verified
          _startVerificationTimer();
        }
      } else {
        _userProfile = null;
        _isEmailVerified = false;
        _stopVerificationTimer();
      }

      notifyListeners();
    });
  }

  // Getters - UI reads these to know current state
  User? get user => _user;
  Map<String, dynamic>? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null && _isEmailVerified;
  bool get isEmailVerified => _isEmailVerified;
  String? get userName => _userProfile?['fullName'];
  bool get notificationsEnabled =>
      _userProfile?['notificationsEnabled'] ?? true;

  // Sign up new user
  Future<bool> signUp(String email, String password, String fullName) async {
    _setLoading(true);
    _clearError();

    try {
      await _authRepo.signUp(
        email: email,
        password: password,
        fullName: fullName,
      );
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // Sign in existing user
  Future<bool> signIn(String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      await _authRepo.signIn(email: email, password: password);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // Sign in with Google
  Future<bool> signInWithGoogle() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await (_authRepo as dynamic).signInWithGoogle();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Sign in with Facebook
  Future<bool> signInWithFacebook() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _authRepo.signInWithFacebook();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    _setLoading(true);
    await _authRepo.signOut();
    _setLoading(false);
  }

  // Check email verification status manually
  Future<void> checkEmailVerified() async {
    final verified = await _authRepo.checkEmailVerified();
    if (verified != _isEmailVerified) {
      _isEmailVerified = verified;

      if (verified && _user != null) {
        _userProfile = await _authRepo.getUserProfile(_user!.uid);
        _stopVerificationTimer();
      }

      notifyListeners();
    }
  }

  // Resend verification email
  Future<void> resendVerification() async {
    try {
      await _authRepo.sendEmailVerification();
    } catch (e) {
      _setError(e.toString());
    }
  }

  // Update notification preference in Firestore
  Future<void> setNotifications(bool value) async {
    if (_user == null) return;

    try {
      await _authRepo.updateUserProfile(_user!.uid, {
        'notificationsEnabled': value,
      });

      // Update local cache
      _userProfile = {...?_userProfile, 'notificationsEnabled': value};
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  // Start polling for email verification (every 3 seconds)
  void _startVerificationTimer() {
    _verificationTimer?.cancel();
    _verificationTimer = Timer.periodic(
      const Duration(seconds: 3),
      (_) => checkEmailVerified(),
    );
  }

  // Stop polling
  void _stopVerificationTimer() {
    _verificationTimer?.cancel();
    _verificationTimer = null;
  }

  // Helper methods for state management
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    _isLoading = false;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _stopVerificationTimer();
    super.dispose();
  }
}
