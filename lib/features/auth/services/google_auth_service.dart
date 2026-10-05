import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../shared/utils/app_constants.dart';

class GoogleAuthService {
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: const ['email', 'profile', 'openid'],
    serverClientId: AppConstants.googleClientId,
  );

  /// Starts platform Google Sign-In and returns its ID token only. An account
  /// email or any other profile field is never used as proof of authentication.
  static Future<String?> signIn() async {
    if (await _googleSignIn.isSignedIn()) {
      await _googleSignIn.signOut();
    }

    final account = await _googleSignIn.signIn();
    if (account == null) return null;
    final authentication = await account.authentication;
    return authentication.idToken;
  }

  static Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (error, stackTrace) {
      debugPrint('Google sign-out failed: $error\n$stackTrace');
    }
  }
}
