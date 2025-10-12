import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  Future<User?> signInAnonymously() async {
    final userCredential = await _auth.signInAnonymously();
    return userCredential.user;
  }

  Future<User?> linkAnonymousAccount(String email, String password) async {
    final user = _auth.currentUser;
    if (user == null || !user.isAnonymous) {
      throw FirebaseAuthException(
        code: 'no-anonymous-user',
        message: 'Aucun utilisateur anonyme connecté.',
      );
    }

    final credential = EmailAuthProvider.credential(email: email, password: password);
    final linkedUser = await user.linkWithCredential(credential);
    return linkedUser.user;
  }

  /// 🔹 Déconnexion
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// 🔹 Connexion à un compte existant
  /// Si l’utilisateur est anonyme et que l’email existe déjà,
  /// il se connecte au compte existant.
  Future<User?> signInWithExistingAccount(String email, String password) async {
    final user = _auth.currentUser;

    if (user != null && user.isAnonymous) {
      try {
        // Essayer de créer un utilisateur avec l'email et le mot de passe
        await _auth.createUserWithEmailAndPassword(email: email, password: password);
        // Si la création réussit, lier le compte anonyme
        final credential = EmailAuthProvider.credential(email: email, password: password);
        final linkedUser = await user.linkWithCredential(credential);
        return linkedUser.user;
      } on FirebaseAuthException catch (e) {
        if (e.code == 'email-already-in-use') {
          // Si l'email est déjà utilisé, se connecter au compte existant
          final userCredential = await _auth.signInWithEmailAndPassword(email: email, password: password);
          return userCredential.user;
        } else {
          // Gérer d'autres erreurs
          rethrow;
        }
      }
    } else {
      // Connexion standard si l'utilisateur n'est pas anonyme
      final userCredential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      return userCredential.user;
    }
  }

}
