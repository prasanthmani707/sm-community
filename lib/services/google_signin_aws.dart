import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/app_logger.dart';

class GoogleSignInService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);

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
    final url = Uri.parse(
        "https://xipjn2iir5.execute-api.us-east-2.amazonaws.com/members/get?email=$email");
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
