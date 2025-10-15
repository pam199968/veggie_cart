import 'package:firebase_auth/firebase_auth.dart';
import 'auth_exceptions.dart';

AuthException mapFirebaseAuthException(FirebaseAuthException e) {
  switch (e.code) {
    case 'invalid-email':
      return const AuthException('Adresse e-mail invalide.');
    case 'user-disabled':
      return const AuthException('Ce compte a été désactivé.');
    case 'user-not-found':
      return const AuthException('Aucun utilisateur trouvé avec cet e-mail.');
    case 'wrong-password':
    case 'invalid-credential':
    case 'invalid-login-credentials':
      return const AuthException('Mot de passe incorrect.');
    case 'email-already-in-use':
      return const AuthException('Cette adresse e-mail est déjà utilisée.');
    case 'weak-password':
      return const AuthException('Le mot de passe est trop faible.');
    case 'too-many-requests':
      return const AuthException('Trop de tentatives. Réessayez plus tard.');
    case 'operation-not-allowed':
      return const AuthException('Cette opération n’est pas autorisée.');
    case 'user-null':
      return const AuthException('Impossible de créer le compte utilisateur.');
    case 'user-not-found-in-firestore':
      return const AuthException('Aucun profil utilisateur trouvé.');
    default:
      return AuthException(
        e.message ?? 'Erreur inconnue lors de l’authentification.',
      );
  }
}
