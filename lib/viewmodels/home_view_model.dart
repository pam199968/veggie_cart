import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../repositories/account_repository.dart';
import '../models/delivery_method.dart';

class HomeViewModel extends ChangeNotifier {
  final AccountRepository accountRepository;

  HomeViewModel({required this.accountRepository});

  // Replaced TextEditingController attributes with String attributes
  String name = "";
  String givenName = "";
  String email = "";
  String password = "";
  String confirmPassword = "";
  String phone = "";
  String profile = "";
  String address = "";

  DeliveryMethod selectedDeliveryMethod = DeliveryMethod.farmPickup;
  bool pushNotifications = true;
  bool showSignInForm = true;
  bool showSignUpForm = false;

  Stream<User?> get authStateChanges => FirebaseAuth.instance.authStateChanges();

  void toggleSignInForm() {
    showSignInForm = !showSignInForm;
    notifyListeners();
  }

  void toggleSignUpForm() {
    showSignUpForm = !showSignUpForm;
    showSignInForm = !showSignUpForm; // Assure que le formulaire de connexion est affiché lorsque le formulaire de création est masqué
    notifyListeners();
  }

  Future<void> signOut(BuildContext context) async {
    await accountRepository.signOut(context);
    clearAttributes();
    password = ""; // Assure que le champ mot de passe est vidé lors de la déconnexion
    showSignInForm = true;
    showSignUpForm = false;
    notifyListeners();
  }

  void clearAttributes() {
    name = "";
    givenName = "";
    email = "";
    password = "";
    confirmPassword = "";
    phone = "";
    profile = "";
    address = "";
  }

  Future<void> signIn(BuildContext context) async {
    await accountRepository.signInExistingAccount(
      context: context,
      email: email.trim(),
      password: password.trim(),
    );
    notifyListeners();
  }

  Future<void> signUp(BuildContext context) async {
    await accountRepository.signUp(
      context: context,
      name: name.trim(),
      givenName: givenName.trim(),
      email: email.trim(),
      password: password.trim(),
      phoneNumber: phone.trim(),
      address: address.trim(),
      deliveryMethod: selectedDeliveryMethod,
      pushNotifications: pushNotifications,
    );
    notifyListeners();
  }

  bool isPasswordValid(String password) {
    final passwordRegex = RegExp(r'^(?=.*[A-Z])(?=.*\d)[A-Za-z\d]{8,}');
    return passwordRegex.hasMatch(password);
  }

  bool isEmailValid(String email) {
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}');
    return emailRegex.hasMatch(email);
  }
}