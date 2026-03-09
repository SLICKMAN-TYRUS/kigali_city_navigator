// presentation/screens/auth/login_screen.dart
// Login screen with email/password authentication
// Validates input and shows loading/error states

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../domain/providers/auth_provider.dart';
import '../../../core/utils/constants.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final success = await authProvider.signIn(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (success && mounted) {
      // Navigation handled by AuthWrapper in main.dart
      // Just show success feedback
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Welcome back!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // App logo/icon
                  Icon(
                    Icons.location_city,
                    size: 80,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(height: 24),

                  // Title
                  Text(
                    Constants.appName,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                  const SizedBox(height: 8),

                  // Tagline
                  Text(
                    Constants.tagline,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
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
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Text(
                        authProvider.error!,
                        style: TextStyle(color: Colors.red.shade700),
                        textAlign: TextAlign.center,
                      ),
                    ),

                  // Email field
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return Constants.errorRequired;
                      }
                      if (!value.contains('@')) {
                        return Constants.errorEmail;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Password field
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return Constants.errorRequired;
                      }
                      if (value.length < Constants.minPasswordLength) {
                        return Constants.errorPassword;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Login button
                  ElevatedButton(
                    onPressed: authProvider.isLoading ? null : _login,
                    child: authProvider.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Login'),
                  ),
                  const SizedBox(height: 16),

                  // Sign up link
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/signup');
                    },
                    child: const Text("Don't have an account? Sign up"),
                  ),

                  const SizedBox(height: 24),

                  // Divider
                  const Row(
                    children: [
                      Expanded(child: Divider()),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text("OR"),
                      ),
                      Expanded(child: Divider()),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Google Login Button
                  ElevatedButton.icon(
                    onPressed: () async {
                      final provider =
                          Provider.of<AuthProvider>(context, listen: false);
                      final success = await provider.signInWithGoogle();

                      if (!success && mounted && provider.error != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(provider.error!)),
                        );
                      }
                      // If success, AuthWrapper handles navigation
                    },
                    icon: const Icon(Icons.g_mobiledata,
                        color: Colors.black, size: 32),
                    label: const Text('Continue with Google'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Facebook Login Button
                  ElevatedButton.icon(
                    onPressed: () async {
                      final provider =
                          Provider.of<AuthProvider>(context, listen: false);
                      final success = await provider.signInWithFacebook();

                      if (!success && mounted && provider.error != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(provider.error!)),
                        );
                      }
                      // If success, AuthWrapper handles navigation
                    },
                    icon: const Icon(Icons.facebook, color: Colors.white),
                    label: const Text('Continue with Facebook'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1877F2), // Facebook Blue
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
