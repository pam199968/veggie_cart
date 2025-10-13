import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../repositories/account_repository.dart';
import '../models/delivery_method.dart';
import '../viewmodels/home_view_model.dart'; // Correction du chemin d'importation
import '../i18n/strings.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _givenNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController(); // Ajout d'un contrôleur pour la confirmation du mot de passe

  DeliveryMethod _selectedDeliveryMethod = DeliveryMethod.farmPickup;
  bool _pushNotifications = true;

  @override
  void dispose() {
    _confirmPasswordController.dispose(); // Libération du contrôleur lors de la destruction du widget
    super.dispose();
  }

  // Added clearControllers method to clear TextEditingControllers
  void clearControllers() {
    _nameController.clear();
    _givenNameController.clear();
    _emailController.clear();
    _passwordController.clear();
    _confirmPasswordController.clear();
    _phoneController.clear();
    _addressController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final homeViewModel = context.watch<HomeViewModel>(); // Récupération du ViewModel via Provider
    final accountRepository = context.read<AccountRepository>();
    return StreamBuilder<User?>(
      stream: accountRepository.authStateChanges,
      builder: (context, snapshot) {
        final user = snapshot.data;

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(Strings.appTitle),
            backgroundColor: Colors.greenAccent,
            actions: [
              if (user != null && !user.isAnonymous)
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () {
                    homeViewModel.signOut(context); // Fournit le contexte à la méthode signOut
                    clearControllers(); // Clear text controllers on sign out
                  },
                  tooltip: Strings.logoutTooltip,
                ),
            ],
          ),
          body: Center(
            child: SingleChildScrollView(
              child: user == null
                  ? homeViewModel.showSignUpForm
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'img/logo.jpeg',
                              height: 100,
                              width: 100,
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: 300, // Ajuste la largeur pour correspondre à la longueur maximale
                              child: TextField(
                                controller: _nameController,
                                decoration: const InputDecoration(labelText: Strings.nameLabel),
                                maxLength: 40,
                                maxLines: 1,
                              ),
                            ),
                            SizedBox(
                              width: 300,
                              child: TextField(
                                controller: _givenNameController,
                                decoration: const InputDecoration(labelText: Strings.givenNameLabel),
                                maxLength: 40,
                                maxLines: 1,
                              ),
                            ),
                            SizedBox(
                              width: 300,
                              child: TextField(
                                controller: _emailController,
                                decoration: const InputDecoration(labelText: Strings.emailLabel),
                                maxLength: 40,
                                maxLines: 1,
                              ),
                            ),
                            SizedBox(
                              width: 300,
                              child: TextField(
                                controller: _passwordController,
                                obscureText: true,
                                decoration: const InputDecoration(labelText: Strings.passwordLabel),
                                maxLength: 20,
                                maxLines: 1,
                              ),
                            ),
                            const SizedBox(height: 5),
                            const SizedBox(
                              width: 300,
                              child: Text(
                                Strings.passwordHint,
                                style: TextStyle(fontSize: 12, color: Colors.grey),
                                textAlign: TextAlign.start,
                              ),
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              width: 300,
                              child: TextField(
                                controller: _confirmPasswordController,
                                obscureText: true,
                                decoration: const InputDecoration(labelText: Strings.confirmPasswordLabel),
                                maxLength: 40,
                                maxLines: 1,
                              ),
                            ),
                            SizedBox(
                              width: 300,
                              child: TextField(
                                controller: _phoneController,
                                decoration: const InputDecoration(labelText: Strings.phoneLabel),
                                maxLength: 14,
                                maxLines: 1,
                              ),
                            ),
                            SizedBox(
                              width: 300,
                              child: TextField(
                                controller: _addressController,
                                decoration: const InputDecoration(labelText: Strings.addressLabel),
                                maxLength: 120,
                                maxLines: 4,
                              ),
                            ),
                            const SizedBox(height: 10),
                            DeliveryMethodDropdown(
                              notifier: ValueNotifier<DeliveryMethod>(_selectedDeliveryMethod),
                            ),
                            PushNotificationSwitch(
                              notifier: ValueNotifier<bool>(_pushNotifications),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton(
                                  onPressed: () async {
                                    final homeViewModel = context.read<HomeViewModel>();

                                    if (!homeViewModel.isEmailValid(_emailController.text.trim())) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text(Strings.emailError),
                                        ),
                                      );
                                      return;
                                    }

                                    if (!homeViewModel.isPasswordValid(_passwordController.text.trim())) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text(Strings.passwordError),
                                        ),
                                      );
                                      return;
                                    }

                                    if (_passwordController.text.trim() != _confirmPasswordController.text.trim()) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text(Strings.passwordMismatchError)),
                                      );
                                      return;
                                    }

                                    // Assign values to HomeViewModel attributes
                                    homeViewModel.name = _nameController.text.trim();
                                    homeViewModel.givenName = _givenNameController.text.trim();
                                    homeViewModel.email = _emailController.text.trim();
                                    homeViewModel.password = _passwordController.text.trim();
                                    homeViewModel.phone = _phoneController.text.trim();
                                    homeViewModel.address = _addressController.text.trim();
                                    homeViewModel.selectedDeliveryMethod = _selectedDeliveryMethod;
                                    homeViewModel.pushNotifications = _pushNotifications;

                                    await homeViewModel.signUp(context);
                                    clearControllers();
                                    if (mounted) {
                                      homeViewModel.toggleSignUpForm(); // Masque le formulaire après création
                                    }
                                  },
                                  child: const Text(Strings.createAccountButton),
                                ),
                                const SizedBox(width: 10),
                                TextButton(
                                  onPressed: () {
                                    final homeViewModel = context.read<HomeViewModel>();
                                    homeViewModel.toggleSignUpForm(); // Appelle la méthode du ViewModel pour basculer les formulaires
                                  },
                                  child: const Text(Strings.cancelButton),
                                ),
                              ],
                            ),
                          ],
                        )
                      : homeViewModel.showSignInForm
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'img/logo.jpeg',
                                  height: 100,
                                  width: 100,
                                ),
                                const SizedBox(height: 20),
                                SizedBox(
                                  width: 300,
                                  child: TextField(
                                    controller: _emailController,
                                    decoration: const InputDecoration(labelText: Strings.emailLabel),
                                    maxLength: 40,
                                    maxLines: 1,
                                  ),
                                ),
                                SizedBox(
                                  width: 300,
                                  child: TextField(
                                    controller: _passwordController,
                                    obscureText: true,
                                    decoration: const InputDecoration(labelText: Strings.passwordLabel),
                                    maxLength: 20,
                                    maxLines: 1,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () async {
                                        final homeViewModel = context.read<HomeViewModel>();
                                        homeViewModel.email = _emailController.text.trim();
                                        homeViewModel.password = _passwordController.text.trim();
                                        await homeViewModel.signIn(context);
                                        clearControllers();
                                        homeViewModel.toggleSignInForm(); // Masque le formulaire après connexion
                                      },
                                      child: const Text(Strings.signInButton),
                                    ),
                                    const SizedBox(width: 10),
                                    TextButton(
                                      onPressed: () {
                                        final homeViewModel = context.read<HomeViewModel>();
                                        homeViewModel.toggleSignUpForm(); // Appelle la méthode du ViewModel pour basculer les formulaires
                                      },
                                      child: const Text(Strings.createAccountLink),
                                    ),
                                  ],
                                ),
                              ],
                            )
                          : const Text(Strings.notConnected)
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("${Strings.connectedAs} ${user.email}"),
                        const SizedBox(height: 20),
                      ],
                    ),
            ),
          ),
        );
      },
    );
  }
}

class DeliveryMethodDropdown extends StatelessWidget {
  final ValueNotifier<DeliveryMethod> notifier;

  const DeliveryMethodDropdown({
    Key? key,
    required this.notifier,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<DeliveryMethod>(
      valueListenable: notifier,
      builder: (context, value, child) {
        return SizedBox(
          width: 300, // Ajuste la largeur pour aligner avec les autres champs
          child: DropdownButtonFormField<DeliveryMethod>(
            value: value,
            items: DeliveryMethod.values
                .map((m) => DropdownMenuItem(
                      value: m,
                      child: Text(m.label),
                    ))
                .toList(),
            onChanged: (v) {
              if (v != null) {
                notifier.value = v;
              }
            },
            decoration: const InputDecoration(labelText: Strings.deliveryMethodLabel),
          ),
        );
      },
    );
  }
}

class PushNotificationSwitch extends StatelessWidget {
  final ValueNotifier<bool> notifier;

  const PushNotificationSwitch({
    Key? key,
    required this.notifier,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: notifier,
      builder: (context, value, child) {
        return SizedBox(
          width: 300, // Ajuste la largeur pour aligner avec les autres champs
          child: SwitchListTile(
            title: const Text(Strings.pushNotificationLabel),
            value: value,
            onChanged: (v) {
              notifier.value = v;
            },
          ),
        );
      },
    );
  }
}
