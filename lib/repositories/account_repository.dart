import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../models/user_model.dart';
import '../models/delivery_method.dart';

class AccountRepository {
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();

  /// 🔗 Crée un compte email/password
  Future<void> signUp({
    required BuildContext context,
    required String name,
    required String givenName,
    required String email,
    required String password,
    required String phoneNumber,
    required String profile,
    required String address,
    required DeliveryMethod deliveryMethod,
    required bool pushNotifications,
  }) async {
    try {
      // Crée le compte directement via AuthService
      final userCredential = await _authService.createUserWithEmail(email, password);
      final user = userCredential.user;

      if (user == null) {
        throw FirebaseAuthException(
          code: 'user-null',
          message: 'Impossible de créer le compte utilisateur.',
        );
      }

      // Crée le modèle utilisateur dans Firestore
      final newUser = UserModel(
        name: name,
        givenName: givenName,
        email: email,
        phoneNumber: phoneNumber,
        profile: profile,
        address: address,
        deliveryMethod: deliveryMethod,
        pushNotifications: pushNotifications,
      );

      await _userService.createUserWithId(user.uid, newUser);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Compte créé avec succès 🎉')),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur Auth : ${e.message}')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur inconnue : $e')),
        );
      }
    }
  }

  /// 🔐 Connexion à un compte existant
  Future<void> signInExistingAccount({
    required BuildContext context,
    required String email,
    required String password,
  }) async {
    try {
      await _authService.signInWithExistingAccount(email, password);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Connexion réussie ✅')),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur connexion : ${e.message}')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur inconnue : $e')),
        );
      }
    }
  }

  /// 🚪 Déconnexion
  Future<void> signOut(BuildContext context) async {
    try {
      await _authService.signOut();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Déconnecté avec succès !')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la déconnexion : $e')),
        );
      }
    }
  }
}
