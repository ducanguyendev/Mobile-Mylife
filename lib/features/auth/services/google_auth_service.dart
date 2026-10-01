import 'package:google_sign_in/google_sign_in.dart';
import '../../../shared/utils/app_constants.dart';

class GoogleAuthService {
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'profile',
      'openid',
    ],
    serverClientId: AppConstants.googleClientId,
  );

  /// Kích hoạt Google Sign-In SDK và lấy token / code xác thực
  static Future<String?> signIn() async {
    try {
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }

      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      if (account == null) {
        return null;
      }

      final GoogleSignInAuthentication auth = await account.authentication;

      // Ưu tiên idToken hoặc serverAuthCode hoặc email của tài khoản Google
      final token = auth.idToken ?? account.serverAuthCode ?? account.email;
      return token;
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
  }
}
