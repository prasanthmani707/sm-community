import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/app_logger.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GoogleSignInService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);

  /// Get AWS URL from .env safely (after dotenv.load)
  String get baseVerifyUrl => dotenv.env['AWS_MEMBER_VERIFY_URL'] ?? "";

  Future<GoogleSignInAccount?> signInSilently() async {
    try {
      return await _googleSignIn.signInSilently();
    } catch (e, st) {
      AppLogger.e("Silent Google Sign-In failed", error: e, stackTrace: st);
      return null;
    }
  }

  Future<GoogleSignInAccount?> signIn() async {
    try {
      return await _googleSignIn.signIn();
    } catch (e, st) {
      AppLogger.e("Google Sign-In error", error: e, stackTrace: st);
      return null;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.disconnect();
    await _googleSignIn.signOut();
  }

  Future<Map<String, dynamic>?> verifyWithAWS(String email) async {
    final url = Uri.parse("$baseVerifyUrl?email=$email");

    AppLogger.d("Calling AWS URL: $url");

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);

        if (result["data"] != null && result["data"]["email"] == email) {
          return result["data"];
        }
      }
      return null;
    } catch (e, st) {
      AppLogger.e("AWS verification failed", error: e, stackTrace: st);
      return null;
    }
  }
}
