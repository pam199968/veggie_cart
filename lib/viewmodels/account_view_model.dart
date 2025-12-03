// Copyright (c) 2025 Patrick Mortas
// All rights reserved.

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../repositories/delivery_method_repository.dart';
import '../repositories/account_repository.dart';
import '../models/user_model.dart';
import '../models/profile.dart';

class AccountViewModel extends ChangeNotifier {
  final AccountRepository accountRepository;

  /// Secure Storage
  static const _storage = FlutterSecureStorage();

  /// 👤 Représente l’utilisateur courant (formulaire ou utilisateur connecté)
  UserModel currentUser = UserModel(
    name: '',
    givenName: '',
    email: '',
    phoneNumber: '',
    address: '',
    deliveryMethod: DeliveryMethodRepository.defaultMethod,
    pushNotifications: true,
    profile: Profile.customer,
  );

  /// 🔐 Champs non stockés dans le modèle utilisateur
  String password = "";
  String confirmPassword = "";

  bool showSignInForm = true;
  bool showSignUpForm = false;

  AccountViewModel({required this.accountRepository});

  void toggleSignInForm() {
    showSignInForm = !showSignInForm;
    notifyListeners();
  }

  void toggleSignUpForm() {
    showSignUpForm = !showSignUpForm;
    showSignInForm = !showSignUpForm;
    notifyListeners();
  }

  // ============================================================
  // 🧠 PERSISTENCE DE SESSION
  // ============================================================

  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;

  /// 🔹 Sauvegarde la session en SecureStorage
  Future<void> _saveSession(String email) async {
    await _storage.write(key: 'isLoggedIn', value: 'true');
    await _storage.write(key: 'userEmail', value: email);
  }

  /// 🔹 Efface la session
  Future<void> _clearSession() async {
    await _storage.deleteAll();
  }

  /// 🔹 Tente de restaurer une session au lancement
  Future<void> tryAutoLogin() async {
    final savedLogin = await _storage.read(key: 'isLoggedIn');
    final savedEmail = await _storage.read(key: 'userEmail');

    if (savedLogin == 'true' && savedEmail != null) {
      final userFromDb = await accountRepository.fetchUserProfile(savedEmail);

      if (userFromDb != null) {
        currentUser = userFromDb;
        _isLoggedIn = true;
        notifyListeners();
      }
    }
  }

  Future<void> signOut(BuildContext context) async {
    await accountRepository.signOut(context);
    await _clearSession();
    clearUserData();
    password = "";
    showSignInForm = true;
    showSignUpForm = false;
    _isLoggedIn = false;
    notifyListeners();
  }

  /// 🧹 Réinitialise l’utilisateur
  void clearUserData() {
    currentUser = UserModel(
      name: '',
      givenName: '',
      email: '',
      phoneNumber: '',
      address: '',
      deliveryMethod: DeliveryMethodRepository.defaultMethod,
      pushNotifications: true,
      profile: Profile.customer,
    );
    password = "";
    confirmPassword = "";
  }

  bool get isAuthenticated => currentUser.id != null;

  Future<void> signIn(BuildContext context) async {
    final connectedUser = await accountRepository.signInExistingAccount(
      context: context,
      email: currentUser.email,
      password: password,
    );

    if (connectedUser != null) {
      currentUser = connectedUser;
      await _saveSession(currentUser.email);
    }

    notifyListeners();
  }

  Future<void> signUp(BuildContext context) async {
    final createdUser = await accountRepository.signUp(
      context: context,
      user: currentUser.copyWith(
        name: currentUser.name.trim(),
        givenName: currentUser.givenName.trim(),
        email: currentUser.email.trim(),
        phoneNumber: currentUser.phoneNumber.trim(),
        address: currentUser.address.trim(),
      ),
      password: password.trim(),
    );

    if (createdUser != null) {
      currentUser = createdUser;
      await _saveSession(currentUser.email);
    }

    notifyListeners();
  }

  Stream<List<UserModel>> get gardenersStream {
    return accountRepository.getGardenersStream();
  }

  Stream<List<UserModel>> get customersStream {
    return accountRepository.getCustomersStream();
  }

  Future<void> toggleGardenerStatus(
    BuildContext context,
    UserModel user,
    bool isGardener,
  ) async {
    final updatedUser = user.copyWith(
      profile: isGardener ? Profile.gardener : Profile.customer,
    );
    await accountRepository.updateUserProfile(
      context: context,
      user: updatedUser,
    );
  }

  Future<List<UserModel>> searchCustomers(String name) async {
    return await accountRepository.searchCustomersByName(name);
  }

  Future<void> promoteToGardener(BuildContext context, UserModel user) async {
    final updatedUser = user.copyWith(profile: Profile.gardener);
    await accountRepository.updateUserProfile(
      context: context,
      user: updatedUser,
    );
  }

  Future<bool> updateUserProfile(
    BuildContext context,
    UserModel updatedUser,
  ) async {
    final success = await accountRepository.updateUserProfile(
      context: context,
      user: updatedUser,
    );

    if (success) {
      currentUser = updatedUser;
      notifyListeners();
    }

    return success;
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await accountRepository.authService.sendPasswordResetEmail(email);
  }

  Future<void> disableCustomerAccount(
    BuildContext context,
    UserModel user,
  ) async {
    await accountRepository.disableUserAccount(context, user);
    notifyListeners();
  }

  Future<void> enableCustomerAccount(
    BuildContext context,
    UserModel user,
  ) async {
    await accountRepository.enableUserAccount(context, user);
    notifyListeners();
  }

  bool isPasswordValid(String password) {
    final passwordRegex = RegExp(r'^(?=.*[A-Z])(?=.*\d)[^\s]{8,}$');
    // Doit contenir au moins 8 caractères, une majuscule et un chiffre
    return passwordRegex.hasMatch(password);
  }

  bool isEmailValid(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}',
    );
    return emailRegex.hasMatch(email);
  }
}
