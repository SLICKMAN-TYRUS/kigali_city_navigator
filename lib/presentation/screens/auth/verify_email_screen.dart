// presentation/screens/auth/verify_email_screen.dart
// Shows after signup, polls for email verification status
// Automatically redirects to home screen once verified

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../domain/providers/auth_provider.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  bool _canResend = false;
  Timer? _resendTimer;
  int _resendCountdown = 60;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  void _startResendTimer() {
    _canResend = false;
    _resendCountdown = 60;

    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _resendCountdown--;
        if (_resendCountdown <= 0) {
          _canResend = true;
          timer.cancel();
        }
      });
    });
  }

  Future<void> _resendEmail() async {
    if (!_canResend) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.resendVerification();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Verification email sent!')),
      );
    }

    _startResendTimer();
  }

  Future<void> _checkVerification() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.checkEmailVerified();

    // AuthWrapper in main.dart will handle navigation if verified
    if (!authProvider.isEmailVerified && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email not verified yet. Please check your inbox.'),
        ),
      );
    }
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Icon
              Icon(
                Icons.mark_email_unread,
                size: 100,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 32),

              // Title
              Text(
                'Verify Your Email',
                style: Theme.of(context).textTheme.displaySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Instructions
              Text(
                'We\'ve sent a verification email to:',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                authProvider.user?.email ?? 'your email',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Instructions continued
              Text(
                'Please check your inbox and click the verification link to continue.',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              // Error message
              if (authProvider.error != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    authProvider.error!,
                    style: TextStyle(color: Colors.red.shade700),
                    textAlign: TextAlign.center,
                  ),
                ),

              // Check verification button
              ElevatedButton.icon(
                onPressed: _checkVerification,
                icon: const Icon(Icons.refresh),
                label: const Text('I\'ve Verified My Email'),
              ),
              const SizedBox(height: 16),

              // Resend email button
              ElevatedButton.icon(
                onPressed: _canResend ? _resendEmail : null,
                icon: const Icon(Icons.send),
                label: Text(_canResend
                    ? 'Resend Email'
                    : 'Resend in $_resendCountdown seconds'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade200,
                  foregroundColor: Colors.black87,
                ),
              ),
              const SizedBox(height: 24),

              // Sign out option
              TextButton(
                onPressed: () => authProvider.signOut(),
                child: const Text('Use a different email'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
