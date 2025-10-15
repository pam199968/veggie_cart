import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  /// 🔹 Sauvegarde la session localement
  Future<void> _saveSession(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('userEmail', email);
  }

  /// 🔹 Efface la session
  Future<void> _clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  /// 🔹 Tente de restaurer une session au lancement
  Future<void> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLogin = prefs.getBool('isLoggedIn') ?? false;
    final savedEmail = prefs.getString('userEmail');

    if (savedLogin && savedEmail != null) {

      // Recharge depuis le repo si besoin (profil complet)
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
    await _clearSession(); // 🔹 efface la persistance locale
    clearUserData();
    password = "";
    showSignInForm = true;
    showSignUpForm = false;
    _isLoggedIn = false;
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
      _saveSession(currentUser.email);
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
      _saveSession(currentUser.email);
    }

    notifyListeners();
  }

  Stream<List<UserModel>> get gardenersStream {
    return accountRepository.getGardenersStream();
  }

  Future<void> toggleGardenerStatus(BuildContext context, UserModel user, bool isGardener) async {
    final updatedUser = user.copyWith(
      profile: isGardener ? Profile.gardener : Profile.customer,
    );
    await accountRepository.updateUserProfile(context: context, user: updatedUser);
  }

  Future<List<UserModel>> searchCustomers(String name) async {
    return await accountRepository.searchCustomersByName(name);
  }

  Future<void> promoteToGardener(BuildContext context, UserModel user) async {
    final updatedUser = user.copyWith(profile: Profile.gardener);
    await accountRepository.updateUserProfile(context: context, user: updatedUser);
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

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await accountRepository.authService.sendPasswordResetEmail(email);
    } catch (e) {
      rethrow; // Laisse le widget gérer l'affichage du message
    }
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
