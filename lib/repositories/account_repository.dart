// Copyright (c) 2025 Patrick Mortas
// All rights reserved.

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../models/user_model.dart';
import '../models/profile.dart';
import '../exceptions/auth_error_mapper.dart';

class AccountRepository {
  final AuthService authService;
  final UserService userService;

  /// 💡 On autorise l’injection d’un FirebaseAuth mocké (utile pour les tests)
  AccountRepository({
    required AuthService authService,
    required UserService userService,
  }) : this.authService = authService,
       this.userService = userService;

  /// 🔗 Crée un compte à partir d’un [UserModel]
  Future<UserModel?> signUp({
    required BuildContext context,
    required UserModel user,
    required String password, // 🔐 le mot de passe reste externe
  }) async {
    try {
      // 1️⃣ Création du compte Firebase (email/password)
      final userCredential = await authService.createUserWithEmail(
        user.email,
        password,
      );

      final firebaseUser = userCredential.user;

      if (firebaseUser == null) {
        throw FirebaseAuthException(
          code: 'user-null',
          message: 'Impossible de créer le compte utilisateur.',
        );
      }

      // 2️⃣ Ajout de l’UID Firebase dans le modèle utilisateur via copyWith
      final newUser = user.copyWith(id: firebaseUser.uid);

      // 3️⃣ Enregistrement du profil utilisateur dans Firestore
      await userService.createUserWithId(firebaseUser.uid, newUser);

      // 4️⃣ Notification visuelle
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Compte créé avec succès 🎉')),
        );
      }

      // 5️⃣ Retourne le nouvel utilisateur si tout s’est bien passé
      return newUser;
    } on FirebaseAuthException catch (e) {
      final authError = mapFirebaseAuthException(e);

      if (context.mounted) showErrorSnack(context, authError.message);
      return null;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erreur inconnue : $e')));
      }
      return null;
    }
  }

  /// 🔄 Met à jour un profil utilisateur existant
  Future<bool> updateUserProfile({
    required BuildContext context,
    required UserModel user,
  }) async {
    try {
      if (user.id == null) {
        throw Exception(
          "Impossible de mettre à jour : l'utilisateur n'a pas d'ID.",
        );
      }

      await userService.updateUser(user);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil mis à jour avec succès ✅')),
        );
      }

      return true;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur mise à jour profil : $e')),
        );
      }
      return false;
    }
  }

  /// 🔐 Connexion à un compte existant
  Future<UserModel?> signInExistingAccount({
    required BuildContext context,
    required String email,
    required String password,
  }) async {
    try {
      // 1️⃣ Connexion via Firebase Auth
      final userCredential = await authService.signInWithExistingAccount(
        email,
        password,
      );
      final firebaseUser = userCredential.user;

      if (firebaseUser == null) {
        throw FirebaseAuthException(
          code: 'user-null',
          message: 'Utilisateur introuvable après la connexion.',
        );
      }

      // 2️⃣ Récupération du profil complet depuis Firestore
      final userModel = await userService.getUserById(firebaseUser.uid);

      if (userModel == null) {
        throw FirebaseAuthException(
          code: 'user-not-found-in-firestore',
          message:
              'Aucun profil utilisateur trouvé dans Firestore pour cet UID.',
        );
      }
      // Vérification si le compte est toujours actif
      if (!userModel.isActive) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ce compte a été désactivé.')),
          );
        }
        await authService.signOut();
        return null;
      }

      // 3️⃣ Notification visuelle
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Connexion réussie ✅')));
      }

      // 4️⃣ Retourne l’objet UserModel
      return userModel;
    } on FirebaseAuthException catch (e) {
      final authError = mapFirebaseAuthException(e);

      if (context.mounted) showErrorSnack(context, authError.message);
      return null;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erreur inconnue : $e')));
      }
      return null;
    }
  }

  /// 🚪 Déconnexion
  Future<void> signOut(BuildContext context) async {
    try {
      await authService.signOut();
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

  // ============================================================
  // 🔹 RÉCUPÉRATION DU PROFIL (pour auto-login)
  // ============================================================

  Future<UserModel?> fetchUserProfile(String email) async {
    try {
      // 1️⃣ Vérifie si l’utilisateur Firebase est toujours connecté
      final currentUser = authService.getCurrentFirebaseUser();

      if (currentUser == null) {
        // Aucun utilisateur Firebase actif
        return null;
      }

      // 2️⃣ Si le mail correspond à celui sauvegardé → on recharge depuis Firestore
      if (currentUser.email == email) {
        final userModel = await userService.getUserById(currentUser.uid);
        return userModel;
      } else {
        // Si pour une raison quelconque le mail ne correspond pas (compte différent)
        return null;
      }
    } catch (e) {
      debugPrint('Erreur fetchUserProfile: $e');
      return null;
    }
  }

  Stream<List<UserModel>> getGardenersStream() {
    return userService.getUsersStream().map((users) {
      return users.where((user) => user.profile == Profile.gardener).toList();
    });
  }

  Stream<List<UserModel>> getCustomersStream() {
    return userService.getUsersStream().map((users) {
      return users.where((user) => user.profile != Profile.gardener).toList();
    });
  }

  Future<List<UserModel>> searchCustomersByName(String name) {
    return userService.searchCustomersByName(name);
  }

  void showErrorSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> disableUserAccount(BuildContext context, UserModel user) async {
    try {
      if (user.id == null) throw Exception('Utilisateur sans ID');

      // Désactive dans Firestore
      final updatedUser = user.copyWith(isActive: false);
      await userService.updateUser(updatedUser);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Le compte de ${user.givenName} a été désactivé.'),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la désactivation : $e')),
        );
      }
    }
  }

  Future<void> enableUserAccount(BuildContext context, UserModel user) async {
    try {
      if (user.id == null) throw Exception('Utilisateur sans ID');

      final updatedUser = user.copyWith(isActive: true);
      await userService.updateUser(updatedUser);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Le compte de ${user.givenName} a été réactivé ✅'),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la réactivation : $e')),
        );
      }
    }
  }
}
