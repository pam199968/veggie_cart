import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// 🔍 Renvoie l'utilisateur actuellement connecté (ou null si aucun)
  User? get currentUser => _auth.currentUser;

  /// 🆕 Crée un utilisateur avec email et mot de passe
  Future<UserCredential> createUserWithEmail(String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential;
    } on FirebaseAuthException catch (e) {
      throw FirebaseAuthException(
        code: e.code,
        message: e.message ?? 'Erreur lors de la création du compte.',
      );
    }
  }

  /// 🔐 Connexion avec un compte existant
  Future<UserCredential> signInWithExistingAccount(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential;
    } on FirebaseAuthException catch (e) {
      throw FirebaseAuthException(
        code: e.code,
        message: e.message ?? 'Erreur lors de la connexion.',
      );
    }
  }

  /// 🚪 Déconnexion
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Erreur lors de la déconnexion : $e');
    }
  }

  /// 📨 Réinitialisation du mot de passe
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw FirebaseAuthException(
        code: e.code,
        message: e.message ?? 'Erreur lors de la réinitialisation du mot de passe.',
      );
    }
  }

  /// 🔄 Rafraîchit l'utilisateur actuel (utile après modification de profil)
  Future<void> reloadCurrentUser() async {
    final user = _auth.currentUser;
    if (user != null) {
      await user.reload();
    }
  }

  /// ✅ Vérifie si un utilisateur est connecté
  bool get isLoggedIn => _auth.currentUser != null;
}
