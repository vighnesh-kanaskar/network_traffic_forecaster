import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ============================================================
  // CREATE ACCOUNT
  // ============================================================

  Future<UserCredential> signUp({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    // Save the user's name inside Firebase Authentication.
    final fullName = '${firstName.trim()} ${lastName.trim()}'.trim();

    await credential.user?.updateDisplayName(fullName);

    // Refresh the Firebase user so displayName is immediately available.
    await credential.user?.reload();

    return credential;
  }

  // ============================================================
  // LOGIN
  // ============================================================

  Future<UserCredential> login({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  Future<void> logout() async {
    await _auth.signOut();
  }

  // ============================================================
  // CURRENT USER
  // ============================================================

  User? get currentUser => _auth.currentUser;
}
