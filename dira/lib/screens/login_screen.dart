import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isSignUp = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _authenticate() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    if (email.isEmpty || password.isEmpty) {
      _showMessage('Please enter email and password.', isError: true);
      return;
    }
    setState(() => _isLoading = true);
    try {
      if (_isSignUp) {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
      } else {
        await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
      }
      // Navigation happens automatically via the AuthGate StreamBuilder in main.dart
    } on FirebaseAuthException catch (e) {
      _showMessage(e.message ?? 'Authentication failed.', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _resetPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      _showMessage('Enter your email above first, then tap "Forgot password".', isError: true);
      return;
    }
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      _showMessage('Password reset email sent.');
    } on FirebaseAuthException catch (e) {
      _showMessage(e.message ?? 'Could not send reset email.', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.medical_services_outlined, size: 72, color: colorScheme.primary),
              const SizedBox(height: 16),
              Text('ClinicOps', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text(_isSignUp ? 'Create your account' : 'Sign in to your clinic',
                  style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 32),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined)),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password', prefixIcon: Icon(Icons.lock_outline)),
              ),
              const SizedBox(height: 24),
              _isLoading
                  ? const CircularProgressIndicator()
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _authenticate,
                        child: Text(_isSignUp ? 'Sign Up' : 'Login'),
                      ),
                    ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => setState(() => _isSignUp = !_isSignUp),
                child: Text(_isSignUp ? 'Already have an account? Login' : "Don't have an account? Sign Up"),
              ),
              if (!_isSignUp)
                TextButton(onPressed: _resetPassword, child: const Text('Forgot password?')),
            ],
          ),
        ),
      ),
    );
  }
}