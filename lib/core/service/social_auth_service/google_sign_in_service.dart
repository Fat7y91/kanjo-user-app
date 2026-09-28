import 'package:google_sign_in/google_sign_in.dart';
import '../../../config/api_path.dart';

class GoogleSignInService {
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  Future<GoogleIdTokenResult> signInAndGetIdToken() async {
    try {
      // Initialize Google Sign In with server client ID (REQUIRED in v7.x)
      await _googleSignIn.initialize(
        serverClientId: ApiPath.googleSignInServerClientId,
      );

      // Authenticate the user
      final GoogleSignInAccount? authenticated = await _googleSignIn.authenticate(
        scopeHint: ['email', 'profile'],
      );

      // Check if authentication was cancelled or failed
      if (authenticated == null) {
        return GoogleIdTokenResult(
          success: false,
          error: 'Google sign-in cancelled by user',
        );
      }

      // Check if idToken is available immediately
      if (authenticated.authentication.idToken == null) {
        return GoogleIdTokenResult(
          success: false,
          error: 'Failed to retrieve idToken from authentication',
        );
      }

      final GoogleSignInAuthentication auth = authenticated.authentication;
      final String? idToken = auth.idToken;

      if (idToken == null || idToken.isEmpty) {
        return GoogleIdTokenResult(
          success: false,
          error: 'idToken is null or empty',
        );
      }

      return GoogleIdTokenResult(
        success: true,
        idToken: idToken,
      );
    } catch (e) {
      return GoogleIdTokenResult(
        success: false,
        error: 'Google Sign In Error: ${e.toString()}',
      );
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
  }
}

class GoogleIdTokenResult {
  final bool success;
  final String? idToken;
  final String? error;

  GoogleIdTokenResult({
    required this.success,
    this.idToken,
    this.error,
  });
}
