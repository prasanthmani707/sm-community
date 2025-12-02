import 'package:flutter/material.dart';
import '../services/google_signin_AWS.dart';
import '../widgets/common/loading_indicator.dart';
import '../screens/chat.dart';
import '../utils/app_logger.dart';

class GoogleSignInScreen extends StatefulWidget {
  @override
  State<GoogleSignInScreen> createState() => _GoogleSignInScreenState();
}

class _GoogleSignInScreenState extends State<GoogleSignInScreen> {
  final GoogleSignInService _googleSignInService = GoogleSignInService();
  bool loading = false;

  @override
  void initState() {
    super.initState();
    AppLogger.i("GoogleSignInScreen initialized");
    _checkAlreadyLoggedIn();
  }

  Future<void> _checkAlreadyLoggedIn() async {
    setState(() => loading = true);
    final user = await _googleSignInService.signInSilently();
    if (user != null) {
      _verifyAWSAndNavigate(user.email);
    } else {
      setState(() => loading = false);
    }
  }

  Future<void> _signIn() async {
    setState(() => loading = true);
    final user = await _googleSignInService.signIn();
    if (user == null) {
      AppLogger.w("Google Sign-In cancelled");
      setState(() => loading = false);
      return;
    }
    _verifyAWSAndNavigate(user.email);
  }

  Future<void> _verifyAWSAndNavigate(String email) async {
    final data = await _googleSignInService.verifyWithAWS(email);

    if (data != null) {
      final fullName = "${data['first_name']} ${data['last_name']}";
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ChatPage(
            userData: {
              "fullName": fullName,
              "email": email,
              "userId": email.split('@')[0],
            },
          ),
        ),
      );
    } else {
      await _googleSignInService.signOut();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("This email is not in our community")),
      );
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blueAccent, Colors.lightBlue],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: loading
                  ? const LoadingIndicator()
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Join the Splunk Community",
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 26,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Connect, collaborate, and share your knowledge with Splunk enthusiasts worldwide. Sign in to get started!",
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: 220, // reduced button width
                          child: ElevatedButton.icon(
                            onPressed: _signIn,
                            icon: const Icon(Icons.login),
                            label: const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12.0),
                              child: Text(
                                "Sign In with Google",
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.blueAccent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 4,
                            ),
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
