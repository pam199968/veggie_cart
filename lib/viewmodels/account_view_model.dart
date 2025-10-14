import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../repositories/account_repository.dart';
import '../models/delivery_method.dart';
import '../models/user_model.dart';
import '../models/profile.dart';

class AccountViewModel extends ChangeNotifier {
  final AccountRepository accountRepository;

  /// 👤 Représente l’utilisateur courant (formulaire d’inscription ou utilisateur connecté)
  UserModel currentUser = UserModel(
    name: '',
    givenName: '',
    email: '',
    phoneNumber: '',
    address: '',
    deliveryMethod: DeliveryMethod.farmPickup,
    pushNotifications: true,
    profile: Profile.customer,
  );

  /// 🔐 Champs non stockés dans le modèle utilisateur
  String password = "";
  String confirmPassword = "";

  bool showSignInForm = true;
  bool showSignUpForm = false;

  AccountViewModel({required this.accountRepository});

  Stream<User?> get authStateChanges => FirebaseAuth.instance.authStateChanges();

  void toggleSignInForm() {
    showSignInForm = !showSignInForm;
    notifyListeners();
  }

  void toggleSignUpForm() {
    showSignUpForm = !showSignUpForm;
    showSignInForm = !showSignUpForm;
    notifyListeners();
  }

  Future<void> signOut(BuildContext context) async {
    await accountRepository.signOut(context);
    clearUserData();
    password = "";
    showSignInForm = true;
    showSignUpForm = false;
    notifyListeners();
  }

  /// 🧹 Réinitialise l’objet utilisateur (après déconnexion ou reset de formulaire)
  void clearUserData() {
    currentUser = UserModel(
      name: '',
      givenName: '',
      email: '',
      phoneNumber: '',
      address: '',
      deliveryMethod: DeliveryMethod.farmPickup,
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
      currentUser = connectedUser; // 💾 met à jour le user du ViewModel
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
      currentUser = createdUser; // 💾 met à jour le user du ViewModel
    }

    notifyListeners();
  }

  /// 🔹 Met à jour le profil utilisateur via UserService
  Future<bool> updateUserProfile(BuildContext context, UserModel updatedUser) async {
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

  /// ✅ Validation des champs
  bool isPasswordValid(String password) {
    final passwordRegex = RegExp(r'^(?=.*[A-Z])(?=.*\d)[A-Za-z\d]{8,}');
    return passwordRegex.hasMatch(password);
  }

  bool isEmailValid(String email) {
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}');
    return emailRegex.hasMatch(email);
  }
}
