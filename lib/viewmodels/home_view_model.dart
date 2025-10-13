import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../repositories/account_repository.dart';
import '../models/delivery_method.dart';

class HomeViewModel extends ChangeNotifier {
  final AccountRepository accountRepository;

  HomeViewModel({required this.accountRepository});

  final TextEditingController nameController = TextEditingController();
  final TextEditingController givenNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController profileController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

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
    clearControllers();
    passwordController.clear(); // Assure que le champ mot de passe est vidé lors de la déconnexion
    showSignInForm = true;
    showSignUpForm = false;
    notifyListeners();
  }

  void clearControllers() {
    nameController.clear();
    givenNameController.clear();
    emailController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    phoneController.clear();
    profileController.clear();
    addressController.clear();
  }

  Future<void> signIn(BuildContext context) async {
    await accountRepository.signInExistingAccount(
      context: context,
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
    );
    notifyListeners();
  }

  Future<void> signUp(BuildContext context) async {
    await accountRepository.signUp(
      context: context,
      name: nameController.text.trim(),
      givenName: givenNameController.text.trim(),
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
      phoneNumber: phoneController.text.trim(),
      profile: profileController.text.trim(),
      address: addressController.text.trim(),
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