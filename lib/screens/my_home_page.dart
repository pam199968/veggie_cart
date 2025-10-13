import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../repositories/account_repository.dart';
import '../models/delivery_method.dart';
import '../viewmodels/home_view_model.dart'; // Correction du chemin d'importation

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
  final TextEditingController _profileController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController(); // Ajout d'un contrôleur pour la confirmation du mot de passe

  DeliveryMethod _selectedDeliveryMethod = DeliveryMethod.farmPickup;
  bool _pushNotifications = true;

  @override
  void dispose() {
    _confirmPasswordController.dispose(); // Libération du contrôleur lors de la destruction du widget
    super.dispose();
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
            title: Text(widget.title),
            backgroundColor: Colors.greenAccent,
            actions: [
              if (user != null && !user.isAnonymous)
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () => homeViewModel.signOut(context), // Fournit le contexte à la méthode signOut
                  tooltip: 'Déconnexion',
                ),
            ],
          ),
          body: Center(
            child: user == null
                ? homeViewModel.showSignUpForm
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 300, // Ajuste la largeur pour correspondre à la longueur maximale
                            child: TextField(
                              controller: _nameController,
                              decoration: const InputDecoration(labelText: 'Nom'),
                              maxLength: 40,
                              maxLines: 1,
                            ),
                          ),
                          SizedBox(
                            width: 300,
                            child: TextField(
                              controller: _givenNameController,
                              decoration: const InputDecoration(labelText: 'Prénom'),
                              maxLength: 40,
                              maxLines: 1,
                            ),
                          ),
                          SizedBox(
                            width: 300,
                            child: TextField(
                              controller: _emailController,
                              decoration: const InputDecoration(labelText: 'Email'),
                              maxLength: 40,
                              maxLines: 1,
                            ),
                          ),
                          SizedBox(
                            width: 300,
                            child: TextField(
                              controller: _passwordController,
                              obscureText: true,
                              decoration: const InputDecoration(labelText: 'Mot de passe'),
                              maxLength: 20,
                              maxLines: 1,
                            ),
                          ),
                          const SizedBox(height: 5),
                          const SizedBox(
                            width: 300,
                            child: Text(
                              'Le mot de passe doit contenir au moins 8 caractères, une majuscule et un chiffre.',
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
                              decoration: const InputDecoration(labelText: 'Confirmer le mot de passe'),
                              maxLength: 40,
                              maxLines: 1,
                            ),
                          ),
                          SizedBox(
                            width: 300,
                            child: TextField(
                              controller: _phoneController,
                              decoration: const InputDecoration(labelText: 'Téléphone'),
                              maxLength: 14,
                              maxLines: 1,
                            ),
                          ),
                          SizedBox(
                            width: 300,
                            child: TextField(
                              controller: _profileController,
                              decoration: const InputDecoration(labelText: 'Profil'),
                              maxLength: 40,
                              maxLines: 1,
                            ),
                          ),
                          SizedBox(
                            width: 300,
                            child: TextField(
                              controller: _addressController,
                              decoration: const InputDecoration(labelText: 'Adresse'),
                              maxLength: 120,
                              maxLines: 4,
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: 300, // Ajuste la largeur pour aligner avec les autres champs
                            child: DropdownButtonFormField<DeliveryMethod>(
                              value: _selectedDeliveryMethod,
                              items: DeliveryMethod.values
                                  .map((m) => DropdownMenuItem(
                                        value: m,
                                        child: Text(m.label),
                                      ))
                                  .toList(),
                              onChanged: (v) => setState(() => _selectedDeliveryMethod = v!),
                              decoration: const InputDecoration(labelText: 'Méthode de livraison'),
                            ),
                          ),
                          SizedBox(
                            width: 300, // Ajuste la largeur pour aligner avec les autres champs
                            child: SwitchListTile(
                              title: const Text("Activer les notifications push"),
                              value: _pushNotifications,
                              onChanged: (v) {
                                setState(() {
                                  _pushNotifications = v; // Met à jour uniquement l'état des notifications push
                                });
                              },
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                onPressed: () async {
                                  if (!homeViewModel.isEmailValid(_emailController.text.trim())) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Veuillez entrer une adresse email valide.'),
                                      ),
                                    );
                                    return;
                                  }

                                  if (!homeViewModel.isPasswordValid(_passwordController.text.trim())) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Le mot de passe doit contenir au moins 8 caractères, une majuscule et un chiffre.'),
                                      ),
                                    );
                                    return;
                                  }

                                  if (_passwordController.text.trim() != _confirmPasswordController.text.trim()) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Les mots de passe ne correspondent pas.')),
                                    );
                                    return;
                                  }

                                  await homeViewModel.signUp(context);
                                  if (mounted) {
                                    homeViewModel.toggleSignUpForm(); // Masque le formulaire après création
                                  }
                                },
                                child: const Text('Créer le compte'),
                              ),
                              const SizedBox(width: 10),
                              TextButton(
                                onPressed: () {
                                  final homeViewModel = context.read<HomeViewModel>();
                                  homeViewModel.toggleSignUpForm(); // Appelle la méthode du ViewModel pour basculer les formulaires
                                },
                                child: const Text('Annuler'),
                              ),
                            ],
                          ),
                        ],
                      )
                    : homeViewModel.showSignInForm
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 300,
                                child: TextField(
                                  controller: _emailController,
                                  decoration: const InputDecoration(labelText: 'Email'),
                                  maxLength: 40,
                                  maxLines: 1,
                                ),
                              ),
                              SizedBox(
                                width: 300,
                                child: TextField(
                                  controller: _passwordController,
                                  obscureText: true,
                                  decoration: const InputDecoration(labelText: 'Mot de passe'),
                                  maxLength: 40,
                                  maxLines: 1,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ElevatedButton(
                                    onPressed: () async {
                                      final accountService = context.read<AccountRepository>();
                                      await accountService.signInExistingAccount(
                                        context: context,
                                        email: _emailController.text.trim(),
                                        password: _passwordController.text.trim(),
                                      );
                                      final homeViewModel = context.read<HomeViewModel>();
                                      homeViewModel.toggleSignInForm(); // Masque le formulaire après connexion
                                    },
                                    child: const Text('Se connecter'),
                                  ),
                                  const SizedBox(width: 10),
                                  TextButton(
                                    onPressed: () {
                                      final homeViewModel = context.read<HomeViewModel>();
                                      homeViewModel.toggleSignUpForm(); // Appelle la méthode du ViewModel pour basculer les formulaires
                                    },
                                    child: const Text('Créer un compte'),
                                  ),
                                ],
                              ),
                            ],
                          )
                        : const Text("Utilisateur non connecté")
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Connecté en tant que ${user.email}"),
                      const SizedBox(height: 20),
                    ],
                  ),
          ),
        );
      },
    );
  }
}
