import 'package:firebase_auth/firebase_auth.dart';

class AuthRepository {
  final FirebaseAuth _auth;
  AuthRepository([FirebaseAuth? auth]) : _auth = auth ?? FirebaseAuth.instance;

  Stream<User?> authChanges() => _auth.authStateChanges();
  User? get current => _auth.currentUser;

  Future<User> signIn(String email, String password) async {
    final c = await _auth.signInWithEmailAndPassword(email: email, password: password);
    return c.user!;
  }

  Future<User> register(String email, String password) async {
    final c = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    return c.user!;
  }

  Future<void> signOut() => _auth.signOut();

  Future<void> sendPasswordReset(String email) =>
      _auth.sendPasswordResetEmail(email: email);
}
