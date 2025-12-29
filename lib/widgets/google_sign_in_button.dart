import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class GoogleSignInButton extends StatefulWidget {
  final VoidCallback? onSignInSuccess;
  final VoidCallback? onSignInError;

  const GoogleSignInButton({
    Key? key,
    this.onSignInSuccess,
    this.onSignInError,
  }) : super(key: key);

  @override
  _GoogleSignInButtonState createState() => _GoogleSignInButtonState();
}

class _GoogleSignInButtonState extends State<GoogleSignInButton> {
  bool _isLoading = false;

  Future<void> _handleSignIn() async {
    setState(() => _isLoading = true);

    try {
      final userCredential = await auth.signInWithGoogle();

      if (userCredential != null) {
        // Successfully signed in
        widget.onSignInSuccess?.call();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Successfully signed in with Google!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        // User cancelled sign-in
        widget.onSignInError?.call();
      }
    } catch (e) {
      widget.onSignInError?.call();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sign-in failed: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: _isLoading ? null : _handleSignIn,
      icon: _isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Image.asset(
              'assets/google_logo.png', // You'll need to add this image
              width: 20,
              height: 20,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.account_circle, color: Colors.white);
              },
            ),
      label: Text(_isLoading ? 'Signing in...' : 'Sign in with Google'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 2,
      ),
    );
  }
}

// Alternative: Simple Google Sign-In button without custom image
class SimpleGoogleSignInButton extends StatefulWidget {
  final VoidCallback? onSignInSuccess;
  final VoidCallback? onSignInError;

  const SimpleGoogleSignInButton({
    Key? key,
    this.onSignInSuccess,
    this.onSignInError,
  }) : super(key: key);

  @override
  _SimpleGoogleSignInButtonState createState() => _SimpleGoogleSignInButtonState();
}

class _SimpleGoogleSignInButtonState extends State<SimpleGoogleSignInButton> {
  bool _isLoading = false;

  Future<void> _handleSignIn() async {
    setState(() => _isLoading = true);

    try {
      final userCredential = await auth.signInWithGoogle();

      if (userCredential != null) {
        widget.onSignInSuccess?.call();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Successfully signed in with Google!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        widget.onSignInError?.call();
      }
    } catch (e) {
      widget.onSignInError?.call();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sign-in failed: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextButton(
        onPressed: _isLoading ? null : _handleSignIn,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isLoading)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
              )
            else
              const Icon(
                Icons.account_circle,
                color: Colors.blue,
                size: 24,
              ),
            const SizedBox(width: 12),
            Text(
              _isLoading ? 'Signing in...' : 'Continue with Google',
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}